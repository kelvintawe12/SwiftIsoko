/// Simple localization helper for the app
/// Maps language codes to translated strings
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  // Settings Screen
  String get settings => _translate(
        en: 'Settings',
        fr: 'Paramètres',
        es: 'Configuración',
      );

  String get appearance => _translate(
        en: 'Appearance',
        fr: 'Apparence',
        es: 'Apariencia',
      );

  String get lightMode => _translate(
        en: 'Light Mode',
        fr: 'Mode Clair',
        es: 'Modo Claro',
      );

  String get darkMode => _translate(
        en: 'Dark Mode',
        fr: 'Mode Sombre',
        es: 'Modo Oscuro',
      );

  String get systemDefault => _translate(
        en: 'System Default',
        fr: 'Système par Défaut',
        es: 'Predeterminado del Sistema',
      );

  String get language => _translate(
        en: 'Language',
        fr: 'Langue',
        es: 'Idioma',
      );

  String get english => _translate(
        en: 'English',
        fr: 'Anglais',
        es: 'Inglés',
      );

  String get french => _translate(
        en: 'French',
        fr: 'Français',
        es: 'Francés',
      );

  String get spanish => _translate(
        en: 'Spanish',
        fr: 'Espagnol',
        es: 'Español',
      );

  String get notifications => _translate(
        en: 'Notifications',
        fr: 'Notifications',
        es: 'Notificaciones',
      );

  String get enableNotifications => _translate(
        en: 'Enable Notifications',
        fr: 'Activer les Notifications',
        es: 'Habilitar Notificaciones',
      );

  String get receiveAppNotifications => _translate(
        en: 'Receive app notifications',
        fr: 'Recevoir les notifications',
        es: 'Recibir notificaciones',
      );

  String get emailNotifications => _translate(
        en: 'Email Notifications',
        fr: 'Notifications par Email',
        es: 'Notificaciones por Correo',
      );

  String get receiveUpdatesViaEmail => _translate(
        en: 'Receive updates via email',
        fr: 'Recevoir des mises à jour par email',
        es: 'Recibir actualizaciones por correo',
      );

  String get pushNotifications => _translate(
        en: 'Push Notifications',
        fr: 'Notifications Push',
        es: 'Notificaciones Push',
      );

  String get receivePushNotifications => _translate(
        en: 'Receive push notifications',
        fr: 'Recevoir les notifications push',
        es: 'Recibir notificaciones push',
      );

  String get audio => _translate(
        en: 'Audio',
        fr: 'Audio',
        es: 'Audio',
      );

  String get soundEffects => _translate(
        en: 'Sound Effects',
        fr: 'Effets Sonores',
        es: 'Efectos de Sonido',
      );

  String get playSoundsForInteractions => _translate(
        en: 'Play sounds for interactions',
        fr: 'Jouer des sons pour les interactions',
        es: 'Reproducir sonidos para interacciones',
      );

  String get appVersion => _translate(
        en: 'App Version',
        fr: 'Version de l\'Application',
        es: 'Versión de la Aplicación',
      );

  String get privacyPolicy => _translate(
        en: 'Privacy Policy',
        fr: 'Politique de Confidentialité',
        es: 'Política de Privacidad',
      );

  String get viewOurPrivacyPolicy => _translate(
        en: 'View our privacy policy',
        fr: 'Voir notre politique de confidentialité',
        es: 'Ver nuestra política de privacidad',
      );

  String get termsOfService => _translate(
        en: 'Terms of Service',
        fr: 'Conditions d\'Utilisation',
        es: 'Términos de Servicio',
      );

  String get viewTermsOfService => _translate(
        en: 'View terms of service',
        fr: 'Voir les conditions d\'utilisation',
        es: 'Ver términos de servicio',
      );

  // Messages
  String get lightModeEnabled => _translate(
        en: 'Light mode enabled',
        fr: 'Mode clair activé',
        es: 'Modo claro habilitado',
      );

  String get darkModeEnabled => _translate(
        en: 'Dark mode enabled',
        fr: 'Mode sombre activé',
        es: 'Modo oscuro habilitado',
      );

  String get usingSystemTheme => _translate(
        en: 'Using system theme',
        fr: 'Utilisation du thème système',
        es: 'Usando tema del sistema',
      );

  String get languageSelected => _translate(
        en: 'Language selected',
        fr: 'Langue sélectionnée',
        es: 'Idioma seleccionado',
      );

  String get notificationsEnabled => _translate(
        en: 'Notifications enabled',
        fr: 'Notifications activées',
        es: 'Notificaciones habilitadas',
      );

  String get notificationsDisabled => _translate(
        en: 'Notifications disabled',
        fr: 'Notifications désactivées',
        es: 'Notificaciones deshabilitadas',
      );

  String get emailNotificationsEnabled => _translate(
        en: 'Email notifications enabled',
        fr: 'Notifications email activées',
        es: 'Notificaciones por correo habilitadas',
      );

  String get emailNotificationsDisabled => _translate(
        en: 'Email notifications disabled',
        fr: 'Notifications email désactivées',
        es: 'Notificaciones por correo deshabilitadas',
      );

  String get pushNotificationsEnabled => _translate(
        en: 'Push notifications enabled',
        fr: 'Notifications push activées',
        es: 'Notificaciones push habilitadas',
      );

  String get pushNotificationsDisabled => _translate(
        en: 'Push notifications disabled',
        fr: 'Notifications push désactivées',
        es: 'Notificaciones push deshabilitadas',
      );

  String get soundEffectsEnabled => _translate(
        en: 'Sound effects enabled',
        fr: 'Effets sonores activés',
        es: 'Efectos de sonido habilitados',
      );

  String get soundEffectsDisabled => _translate(
        en: 'Sound effects disabled',
        fr: 'Effets sonores désactivés',
        es: 'Efectos de sonido deshabilitados',
      );

  String get privacyPolicyComingSoon => _translate(
        en: 'Privacy Policy - Coming Soon',
        fr: 'Politique de Confidentialité - À Venir',
        es: 'Política de Privacidad - Próximamente',
      );

  String get termsOfServiceComingSoon => _translate(
        en: 'Terms of Service - Coming Soon',
        fr: 'Conditions d\'Utilisation - À Venir',
        es: 'Términos de Servicio - Próximamente',
      );

  // Profile Screen
  String get profile => _translate(
        en: 'Profile',
        fr: 'Profil',
        es: 'Perfil',
      );

  String get signOut => _translate(
        en: 'Sign Out',
        fr: 'Se Déconnecter',
        es: 'Cerrar Sesión',
      );

  String get confirmSignOut => _translate(
        en: 'Are you sure you want to sign out?',
        fr: 'Êtes-vous sûr de vouloir vous déconnecter?',
        es: '¿Estás seguro de que quieres cerrar sesión?',
      );

  String get cancel => _translate(
        en: 'Cancel',
        fr: 'Annuler',
        es: 'Cancelar',
      );

  String get myListings => _translate(
        en: 'My Listings',
        fr: 'Mes Annonces',
        es: 'Mis Anuncios',
      );

  String get myOrders => _translate(
        en: 'My Orders',
        fr: 'Mes Commandes',
        es: 'Mis Pedidos',
      );

  String get messages => _translate(
        en: 'Messages',
        fr: 'Messages',
        es: 'Mensajes',
      );

  String get editProfile => _translate(
        en: 'Edit Profile',
        fr: 'Modifier le Profil',
        es: 'Editar Perfil',
      );

  String get accountSettings => _translate(
        en: 'Account Settings',
        fr: 'Paramètres du Compte',
        es: 'Configuración de la Cuenta',
      );

  String get helpSupport => _translate(
        en: 'Help & Support',
        fr: 'Aide & Support',
        es: 'Ayuda y Soporte',
      );

  String get about => _translate(
        en: 'About',
        fr: 'À Propos',
        es: 'Acerca de',
      );

  String get noListingsYet => _translate(
        en: 'No listings yet',
        fr: 'Aucune annonce pour le moment',
        es: 'Aún no hay anuncios',
      );

  String get noOrdersYet => _translate(
        en: 'No orders yet',
        fr: 'Aucune commande pour le moment',
        es: 'Aún no hay pedidos',
      );

  String get loading => _translate(
        en: 'Loading...',
        fr: 'Chargement...',
        es: 'Cargando...',
      );

  String get error => _translate(
        en: 'Error',
        fr: 'Erreur',
        es: 'Error',
      );

  // Home Screen
  String get home => _translate(
        en: 'Home',
        fr: 'Accueil',
        es: 'Inicio',
      );

  String get search => _translate(
        en: 'Search',
        fr: 'Rechercher',
        es: 'Buscar',
      );

  String get categories => _translate(
        en: 'Categories',
        fr: 'Catégories',
        es: 'Categorías',
      );

  String get all => _translate(
        en: 'All',
        fr: 'Tout',
        es: 'Todo',
      );

  String get newArrivals => _translate(
        en: 'New Arrivals',
        fr: 'Nouveautés',
        es: 'Novedades',
      );

  String get filter => _translate(
        en: 'Filter',
        fr: 'Filtrer',
        es: 'Filtrar',
      );

  // Auth Screens
  String get signIn => _translate(
        en: 'Sign In',
        fr: 'Se Connecter',
        es: 'Iniciar Sesión',
      );

  String get signUp => _translate(
        en: 'Sign Up',
        fr: 'S\'inscrire',
        es: 'Registrarse',
      );

  String get welcomeBack => _translate(
        en: 'Welcome Back!',
        fr: 'Bon Retour!',
        es: '¡Bienvenido de Nuevo!',
      );

  String get signInToContinue => _translate(
        en: 'Sign in to continue',
        fr: 'Connectez-vous pour continuer',
        es: 'Inicia sesión para continuar',
      );

  String get email => _translate(
        en: 'Email',
        fr: 'Email',
        es: 'Correo Electrónico',
      );

  String get password => _translate(
        en: 'Password',
        fr: 'Mot de Passe',
        es: 'Contraseña',
      );

  String get forgotPassword => _translate(
        en: 'Forgot Password?',
        fr: 'Mot de Passe Oublié?',
        es: '¿Olvidaste tu Contraseña?',
      );

  String get dontHaveAccount => _translate(
        en: "Don't have an account?",
        fr: "Vous n'avez pas de compte?",
        es: '¿No tienes una cuenta?',
      );

  String get alreadyHaveAccount => _translate(
        en: 'Already have an account?',
        fr: 'Vous avez déjà un compte?',
        es: '¿Ya tienes una cuenta?',
      );

  String get continueWithGoogle => _translate(
        en: 'Continue with Google',
        fr: 'Continuer avec Google',
        es: 'Continuar con Google',
      );

  // Helper method to translate based on language code
  String _translate({
    required String en,
    required String fr,
    required String es,
  }) {
    switch (languageCode) {
      case 'fr':
        return fr;
      case 'es':
        return es;
      case 'en':
      default:
        return en;
    }
  }
}
