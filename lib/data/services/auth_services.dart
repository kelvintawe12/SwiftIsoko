import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';
import '../core/failures.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Either<Failure, UserCredential>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
      } else {
        return const Left(AuthFailure('Failed to create user'));
      }

      // Create Firestore user document
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to create user'));
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Sign in with email and password
  Future<Either<Failure, UserCredential>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to sign in'));
      }

      if (!firebaseUser.emailVerified) {
        await _auth.signOut();
        return const Left(AuthFailure(
            'Email not verified. Please check your inbox and verify your email.'));
      }

      // Update isEmailVerified in Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).update({'isEmailVerified': true});

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Sign in with Google
  Future<Either<Failure, UserCredential>> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(AuthFailure('Google sign in was cancelled'));
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to sign in with Google'));
      }

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Create new user document for first-time Google sign-in
        final userModel = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          isEmailVerified: true, // Google emails are verified
          profileImageUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toFirestore());
      }

      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(AuthFailure('Google sign in failed: ${e.toString()}'));
    }
  }

  // Resend verification email
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(
          AuthFailure('Failed to resend verification email: ${e.toString()}'));
    }
  }

  // Sign out
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  // Reset password
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(
          AuthFailure('Failed to send password reset email: ${e.toString()}'));
    }
  }

  // Update user profile
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
