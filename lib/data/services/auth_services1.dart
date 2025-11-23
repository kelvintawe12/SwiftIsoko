// // ignore_for_file: non_constant_identifier_names, await_only_futures

// import 'package:google_sign_in/google_sign_in.dart';

// // Import person model
// import '../models/person.dart';

// // Import firebase auth, google signin and Firestore database
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// /// Authentication service handling user signup, login, and password reset for email/password auth
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Get current User
//   User? get currentUser => _auth.currentUser;

//   // Auth state changes stream
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   /// EMAIL / PASSWORD SIGN UP
//   Future<UserCredential> signUp({
//     required String email,
//     required String password,
//     required String name,
//     required String phoneNumber,
//     required String bio,
//     required String location,
//   }) async {
//     try {
//       // Create user in Firebase Auth
//       final UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Get the UID for the new user
//       final uid = userCredential.user!.uid;

//       // Send email verification
//       await userCredential.user?.sendEmailVerification();

//       // CREATE FIRESTORE PERSON(USER) PROFILE
//       await _firestore.collection('users').doc(uid).set({
//         'name': name,
//         'email': email,
//         'isEmailVerified': false,
//         'phoneNumber': phoneNumber,
//         'profileImageUrl': null,
//         'bio': bio,
//         'location': location,
//         'ratingAverage': 0.0,
//         'numRatings': 0,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// EMAIL / PASSWORD SIGN-IN
//   Future<void> signIn({required String email, required String password}) async {
//     try {
//       // Sign in
//       final userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);

//       final user = userCredential.user;

//       if (user == null) {
//         throw FirebaseAuthException(
//           code: 'user-not-found',
//           message: 'User not found',
//         );
//       }

//       // Reload to get latest verification status
//       await user.reload();

//       // Check if email is Verified and Immediately sign out if email not verified
//       if (!user.emailVerified) {
//         // Immediately sign out if email not verified
//         await _auth.signOut();

//         throw FirebaseAuthException(
//           code: 'email-not-verified',
//           message:
//               'Your email is not verified. Please check your inbox to verify your account before logging in.',
//         );
//       }

//       // Email is verified — update Firestore
//       await _firestore.collection('users').doc(user.uid).update({
//         'isEmailVerified': true,
//       });
//     } on FirebaseAuthException {
//       rethrow;
//     } catch (e) {
//       throw FirebaseAuthException(code: 'unknown-error', message: e.toString());
//     }
//   }

//   // Sign in with Google
//   Future<User?> signInWithGoogle() async {
//     try {
//       // Launch Google login flow
//       final GoogleSignInAccount? googleUser =
//           await _googleSignIn.authenticate();

//       // If null, user cancelled the Google sign-in popup
//       if (googleUser == null) return null;

//       // Retrieve Google authentication tokens
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       // Build Firebase Auth credential from Google tokens
//       final credential = GoogleAuthProvider.credential(
//         accessToken: null,
//         idToken: googleAuth.idToken,
//       );

//       // Sign the user in with Firebase
//       final userCredential = await _auth.signInWithCredential(credential);

//       final user = userCredential.user!;

//       // Get the uid created by auth to use in user's creation
//       final uid = user.uid;

//       // Check if the Firestore user record already exists
//       final userDoc = await _firestore.collection("users").doc(uid).get();

//       // If logging in for the first time — create a Person document
//       if (!userDoc.exists) {
//         final person = Person(
//           uid: uid,
//           name: user.displayName ?? "",
//           email: user.email ?? "",
//           isEmailVerified: true, // Google emails are always verified
//           phoneNumber: user.phoneNumber,
//           profileImageUrl: user.photoURL, // Google account photo
//           bio: '',
//           location: '',
//           ratingAverage: 0.0,
//           numRatings: 0,
//           createdAt: DateTime.now(),
//         );

//         await _firestore.collection('users').doc(uid).set(person.toMap());
//       }

//       return user;
//     } catch (e) {
//       // Wrap Google errors in FirebaseAuthException for consistency
//       throw FirebaseAuthException(
//         code: "google-signin-error",
//         message: e.toString(),
//       );
//     }
//   }

//   // SIGN OUT
//   /// Signs the user out from both Firebase Authentication
//   /// AND Google (if they used Google Sign-In).
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }

//   // PASSWORD RESET
//   /// Sends a password reset email to the user.
//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }

//   /// Returns true if the currently authenticated email is verified
//   bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

//   /// Reloads the current Firebase user to update their authentication data
//   Future<void> reloadUser() async => await _auth.currentUser?.reload();

//   /// Resend the verification email if the user has not completed verification
//   Future<void> resendVerificationEmail() async {
//     final user = _auth.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//     }
//   }
// }
