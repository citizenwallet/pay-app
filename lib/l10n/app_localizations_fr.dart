// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Brussels Pay';

  @override
  String get loading => 'Chargement...';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Terminé';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get close => 'Fermer';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get refresh => 'Actualiser';

  @override
  String get retry => 'Réessayer';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Information';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get deleteData => 'Supprimer les données et se déconnecter';

  @override
  String get deleteDataConfirm =>
      'Votre profil sera effacé et vous serez déconnecté.';

  @override
  String get cardAdded => 'Carte ajoutée';

  @override
  String get cardAlreadyAdded => 'Carte déjà ajoutée';

  @override
  String get cardNotConfigured => 'Carte non configurée';

  @override
  String get configure => 'Configurer';

  @override
  String get cardConfigured => 'Carte configurée';

  @override
  String get nfcNotAvailable => 'NFC n\'est pas disponible sur cet appareil';

  @override
  String get topupOnWay => 'Votre recharge est en cours';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get releaseCard => 'Libérer la carte';

  @override
  String get release => 'Libérer';

  @override
  String get noOrdersFound => 'Aucune commande trouvée';

  @override
  String get transactionFailed => 'Transaction échouée';

  @override
  String get items => 'Articles';

  @override
  String get tokens => 'Tokens';

  @override
  String orderNumber(String orderId) {
    return 'Commande #$orderId';
  }

  @override
  String get qrCode => 'Code QR';

  @override
  String get terminal => 'terminal';

  @override
  String get app => 'application';

  @override
  String get sending => 'envoi...';

  @override
  String get manualEntry => 'Saisie manuelle';

  @override
  String get submit => 'Soumettre';

  @override
  String get enterText => 'Entrer du texte';

  @override
  String get bySigningIn => 'En vous connectant, vous acceptez les ';

  @override
  String get termsAndConditions => 'conditions d\'utilisation';

  @override
  String get phoneNumberPlaceholder => '+32475123456';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get languageChangedSuccessfully => 'Langue changée avec succès !';

  @override
  String get enterLoginCode => 'Entrer le code de connexion';

  @override
  String get invalidCode => 'Code invalide';

  @override
  String get failedToSendCode =>
      'Échec de l\'envoi du code. Vous avez peut-être déjà un code en attente - veuillez vérifier vos messages ou attendre un moment avant de réessayer.';

  @override
  String get sendingSmsCode => 'Envoi du code SMS...';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get confirmCodeAgain => 'Confirmer le code à nouveau';

  @override
  String get confirmCode => 'Confirmer le code';

  @override
  String get sendNewCode => 'Envoyer un nouveau code';

  @override
  String get changePhoneNumber => 'Changer le numéro de téléphone';

  @override
  String get iAlreadyHaveCode => 'J\'ai déjà un code';

  @override
  String get noCodeFound => 'Aucun code en attente';

  @override
  String get noCodeFoundMessage =>
      'Nous n\'avons pas trouvé de code en attente pour ce numéro de téléphone. Veuillez demander un nouveau code ou attendre un moment avant de réessayer.';

  @override
  String get displayContacts => 'Afficher les contacts';

  @override
  String get skip => 'Passer';

  @override
  String get allow => 'Autoriser';

  @override
  String get settings => 'Paramètres';

  @override
  String get account => 'Compte';

  @override
  String get fetchingExistingProfile => 'Récupération du profil existant';

  @override
  String get uploadingNewProfile => 'Téléchargement du nouveau profil';

  @override
  String get almostDone => 'Presque terminé';

  @override
  String get saving => 'Enregistrement';

  @override
  String get name => 'Nom';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get description => 'Description';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get enterYourUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get usernameAlreadyTaken => 'Nom d\'utilisateur déjà pris';

  @override
  String get orderNotFound => 'Commande non trouvée';

  @override
  String get confirmOrder => 'Confirmer la commande';

  @override
  String get noItems => 'Aucun article';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get vat => 'TVA';

  @override
  String get total => 'Total';

  @override
  String get pay => 'Payer';

  @override
  String get menu => 'Menu';

  @override
  String get enterAmount => 'Entrez le montant';

  @override
  String get addMessage => 'Ajouter un message';

  @override
  String get topUp => 'Recharger';

  @override
  String get shareInviteLink => 'Partager le lien d\'invitation';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get newCard => 'Nouvelle carte';

  @override
  String get myCard => 'Ma carte';

  @override
  String get claimCard => 'Réclamer la carte';

  @override
  String get alreadyClaimed => 'Déjà réclamé';

  @override
  String get viewMenu => 'Voir le menu';

  @override
  String get inspectCard => 'Inspecter la carte';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get searchForPeopleOrPlaces => 'Rechercher des personnes ou des lieux';

  @override
  String get about => 'À propos';

  @override
  String get general => 'Général';

  @override
  String get audio => 'Audio';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get brusselsPay => 'Brussels Pay';

  @override
  String get addFunds => 'top up';
}

/// The translations for French, as used in Belgium (`fr_BE`).
class AppLocalizationsFrBe extends AppLocalizationsFr {
  AppLocalizationsFrBe() : super('fr_BE');

  @override
  String get appTitle => 'Brussels Pay';

  @override
  String get loading => 'Chargement...';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Terminé';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get close => 'Fermer';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get refresh => 'Actualiser';

  @override
  String get retry => 'Réessayer';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Information';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get deleteData => 'Supprimer les données et se déconnecter';

  @override
  String get deleteDataConfirm =>
      'Votre profil sera effacé et vous serez déconnecté.';

  @override
  String get cardAdded => 'Carte ajoutée';

  @override
  String get cardAlreadyAdded => 'Carte déjà ajoutée';

  @override
  String get cardNotConfigured => 'Carte non configurée';

  @override
  String get configure => 'Configurer';

  @override
  String get cardConfigured => 'Carte configurée';

  @override
  String get nfcNotAvailable => 'NFC n\'est pas disponible sur cet appareil';

  @override
  String get topupOnWay => 'Votre recharge est en cours';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get releaseCard => 'Libérer la carte';

  @override
  String get release => 'Libérer';

  @override
  String get noOrdersFound => 'Aucune commande trouvée';

  @override
  String get transactionFailed => 'Transaction échouée';

  @override
  String get items => 'Articles';

  @override
  String get tokens => 'Tokens';

  @override
  String orderNumber(String orderId) {
    return 'Commande #$orderId';
  }

  @override
  String get qrCode => 'Code QR';

  @override
  String get terminal => 'terminal';

  @override
  String get app => 'application';

  @override
  String get sending => 'envoi...';

  @override
  String get manualEntry => 'Saisie manuelle';

  @override
  String get submit => 'Soumettre';

  @override
  String get enterText => 'Entrer du texte';

  @override
  String get bySigningIn => 'En vous connectant, vous acceptez les ';

  @override
  String get termsAndConditions => 'conditions d\'utilisation';

  @override
  String get phoneNumberPlaceholder => '+32475123456';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get languageChangedSuccessfully => 'Langue changée avec succès !';

  @override
  String get enterLoginCode => 'Entrer le code de connexion';

  @override
  String get invalidCode => 'Code invalide';

  @override
  String get failedToSendCode =>
      'Échec de l\'envoi du code. Vous avez peut-être déjà un code en attente - veuillez vérifier vos messages ou attendre un moment avant de réessayer.';

  @override
  String get sendingSmsCode => 'Envoi du code SMS...';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get confirmCodeAgain => 'Confirmer le code à nouveau';

  @override
  String get confirmCode => 'Confirmer le code';

  @override
  String get sendNewCode => 'Envoyer un nouveau code';

  @override
  String get changePhoneNumber => 'Changer le numéro de téléphone';

  @override
  String get iAlreadyHaveCode => 'J\'ai déjà un code';

  @override
  String get noCodeFound => 'Aucun code en attente';

  @override
  String get noCodeFoundMessage =>
      'Nous n\'avons pas trouvé de code en attente pour ce numéro de téléphone. Veuillez demander un nouveau code ou attendre un moment avant de réessayer.';

  @override
  String get displayContacts => 'Afficher les contacts';

  @override
  String get skip => 'Passer';

  @override
  String get allow => 'Autoriser';

  @override
  String get settings => 'Paramètres';

  @override
  String get account => 'Compte';

  @override
  String get fetchingExistingProfile => 'Récupération du profil existant';

  @override
  String get uploadingNewProfile => 'Téléchargement du nouveau profil';

  @override
  String get almostDone => 'Presque terminé';

  @override
  String get saving => 'Enregistrement';

  @override
  String get name => 'Nom';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get description => 'Description';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get enterYourUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get usernameAlreadyTaken => 'Nom d\'utilisateur déjà pris';

  @override
  String get orderNotFound => 'Commande non trouvée';

  @override
  String get confirmOrder => 'Confirmer la commande';

  @override
  String get noItems => 'Aucun article';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get vat => 'TVA';

  @override
  String get total => 'Total';

  @override
  String get pay => 'Payer';

  @override
  String get menu => 'Menu';

  @override
  String get enterAmount => 'Entrez le montant';

  @override
  String get addMessage => 'Ajouter un message';

  @override
  String get topUp => 'Recharger';

  @override
  String get shareInviteLink => 'Partager le lien d\'invitation';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get newCard => 'Nouvelle carte';

  @override
  String get myCard => 'Ma carte';

  @override
  String get claimCard => 'Réclamer la carte';

  @override
  String get alreadyClaimed => 'Déjà réclamé';

  @override
  String get viewMenu => 'Voir le menu';

  @override
  String get inspectCard => 'Inspecter la carte';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get searchForPeopleOrPlaces => 'Rechercher des personnes ou des lieux';

  @override
  String get about => 'À propos';

  @override
  String get general => 'Général';

  @override
  String get audio => 'Audio';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get brusselsPay => 'Brussels Pay';

  @override
  String get addFunds => 'top up';
}
