// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Brussels Pay';

  @override
  String get loading => 'Laden...';

  @override
  String get cancel => 'Annuleren';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Klaar';

  @override
  String get next => 'Volgende';

  @override
  String get back => 'Terug';

  @override
  String get save => 'Opslaan';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get close => 'Sluiten';

  @override
  String get search => 'Zoeken';

  @override
  String get filter => 'Filteren';

  @override
  String get sort => 'Sorteren';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get error => 'Fout';

  @override
  String get success => 'Succes';

  @override
  String get warning => 'Waarschuwing';

  @override
  String get info => 'Informatie';

  @override
  String get logOut => 'Uitloggen';

  @override
  String get logOutConfirm => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get deleteData => 'Gegevens verwijderen en uitloggen';

  @override
  String get deleteDataConfirm =>
      'Je profiel wordt gewist en je wordt uitgelogd.';

  @override
  String get cardAdded => 'Kaart toegevoegd';

  @override
  String get cardAlreadyAdded => 'Kaart al toegevoegd';

  @override
  String get cardNotConfigured => 'Kaart niet geconfigureerd';

  @override
  String get configure => 'Configureren';

  @override
  String get cardConfigured => 'Kaart geconfigureerd';

  @override
  String get nfcNotAvailable => 'NFC is niet beschikbaar op dit apparaat';

  @override
  String get topupOnWay => 'Je opwaardering is onderweg';

  @override
  String get noResultsFound => 'Geen resultaten gevonden';

  @override
  String get releaseCard => 'Kaart vrijgeven';

  @override
  String get release => 'Vrijgeven';

  @override
  String get noOrdersFound => 'Geen bestellingen gevonden';

  @override
  String get transactionFailed => 'Transactie mislukt';

  @override
  String get items => 'Artikelen';

  @override
  String get tokens => 'Tokens';

  @override
  String orderNumber(String orderId) {
    return 'Bestelling #$orderId';
  }

  @override
  String get qrCode => 'QR-code';

  @override
  String get terminal => 'terminal';

  @override
  String get app => 'app';

  @override
  String get sending => 'verzenden...';

  @override
  String get manualEntry => 'Handmatige invoer';

  @override
  String get submit => 'Indienen';

  @override
  String get enterText => 'Tekst invoeren';

  @override
  String get bySigningIn => 'Door in te loggen ga je akkoord met de ';

  @override
  String get termsAndConditions => 'algemene voorwaarden';

  @override
  String get phoneNumberPlaceholder => '+32475123456';

  @override
  String get language => 'Taal';

  @override
  String get selectLanguage => 'Selecteer taal';

  @override
  String get languageChangedSuccessfully => 'Taal succesvol gewijzigd!';

  @override
  String get enterLoginCode => 'Voer inlogcode in';

  @override
  String get invalidCode => 'Ongeldige code';

  @override
  String get failedToSendCode => 'Code verzenden mislukt. Probeer het opnieuw.';

  @override
  String get sendingSmsCode => 'SMS-code verzenden...';

  @override
  String get loggingIn => 'Inloggen...';

  @override
  String get confirmCodeAgain => 'Code opnieuw bevestigen';

  @override
  String get confirmCode => 'Code bevestigen';

  @override
  String get sendNewCode => 'Nieuwe code verzenden';

  @override
  String get displayContacts => 'Contacten weergeven';

  @override
  String get skip => 'Overslaan';

  @override
  String get allow => 'Toestaan';

  @override
  String get settings => 'Instellingen';

  @override
  String get account => 'Account';

  @override
  String get fetchingExistingProfile => 'Bestaand profiel ophalen';

  @override
  String get uploadingNewProfile => 'Nieuw profiel uploaden';

  @override
  String get almostDone => 'Bijna klaar';

  @override
  String get saving => 'Opslaan';

  @override
  String get name => 'Naam';

  @override
  String get enterYourName => 'Voer je naam in';

  @override
  String get description => 'Beschrijving';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get enterYourUsername => 'Voer je gebruikersnaam in';

  @override
  String get usernameAlreadyTaken => 'Gebruikersnaam al in gebruik';

  @override
  String get orderNotFound => 'Bestelling niet gevonden';

  @override
  String get confirmOrder => 'Bestelling bevestigen';

  @override
  String get noItems => 'Geen artikelen';

  @override
  String get subtotal => 'Subtotaal';

  @override
  String get vat => 'BTW';

  @override
  String get total => 'Totaal';

  @override
  String get pay => 'Betalen';

  @override
  String get menu => 'Menu';

  @override
  String get enterAmount => 'Voer bedrag in';

  @override
  String get addMessage => 'Bericht toevoegen';

  @override
  String get topUp => 'Opwaarderen';

  @override
  String get shareInviteLink => 'Uitnodigingslink delen';

  @override
  String get orderDetails => 'Bestellingsdetails';

  @override
  String get addCard => 'Kaart toevoegen';

  @override
  String get appSettings => 'App-instellingen';

  @override
  String get newCard => 'Nieuwe kaart';

  @override
  String get myCard => 'Mijn kaart';

  @override
  String get claimCard => 'Kaart opeisen';

  @override
  String get alreadyClaimed => 'Al opgeëist';

  @override
  String get viewMenu => 'Menu bekijken';

  @override
  String get inspectCard => 'Kaart inspecteren';

  @override
  String get notifications => 'Meldingen';

  @override
  String get pushNotifications => 'Push-meldingen';

  @override
  String get searchForPeopleOrPlaces => 'Zoeken naar mensen of plaatsen';

  @override
  String get about => 'Over';

  @override
  String get general => 'Algemeen';

  @override
  String get audio => 'Audio';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get brusselsPay => 'Brussels Pay';

  @override
  String get addFunds => 'top up';
}

/// The translations for Dutch Flemish, as used in Belgium (`nl_BE`).
class AppLocalizationsNlBe extends AppLocalizationsNl {
  AppLocalizationsNlBe() : super('nl_BE');

  @override
  String get appTitle => 'Brussels Pay';

  @override
  String get loading => 'Laden...';

  @override
  String get cancel => 'Annuleren';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Klaar';

  @override
  String get next => 'Volgende';

  @override
  String get back => 'Terug';

  @override
  String get save => 'Opslaan';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get close => 'Sluiten';

  @override
  String get search => 'Zoeken';

  @override
  String get filter => 'Filteren';

  @override
  String get sort => 'Sorteren';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get error => 'Fout';

  @override
  String get success => 'Succes';

  @override
  String get warning => 'Waarschuwing';

  @override
  String get info => 'Informatie';

  @override
  String get logOut => 'Uitloggen';

  @override
  String get logOutConfirm => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get deleteData => 'Gegevens verwijderen en uitloggen';

  @override
  String get deleteDataConfirm =>
      'Je profiel wordt gewist en je wordt uitgelogd.';

  @override
  String get cardAdded => 'Kaart toegevoegd';

  @override
  String get cardAlreadyAdded => 'Kaart al toegevoegd';

  @override
  String get cardNotConfigured => 'Kaart niet geconfigureerd';

  @override
  String get configure => 'Configureren';

  @override
  String get cardConfigured => 'Kaart geconfigureerd';

  @override
  String get nfcNotAvailable => 'NFC is niet beschikbaar op dit apparaat';

  @override
  String get topupOnWay => 'Je opwaardering is onderweg';

  @override
  String get noResultsFound => 'Geen resultaten gevonden';

  @override
  String get releaseCard => 'Kaart vrijgeven';

  @override
  String get release => 'Vrijgeven';

  @override
  String get noOrdersFound => 'Geen bestellingen gevonden';

  @override
  String get transactionFailed => 'Transactie mislukt';

  @override
  String get items => 'Artikelen';

  @override
  String get tokens => 'Tokens';

  @override
  String orderNumber(String orderId) {
    return 'Bestelling #$orderId';
  }

  @override
  String get qrCode => 'QR-code';

  @override
  String get terminal => 'terminal';

  @override
  String get app => 'app';

  @override
  String get sending => 'verzenden...';

  @override
  String get manualEntry => 'Handmatige invoer';

  @override
  String get submit => 'Indienen';

  @override
  String get enterText => 'Tekst invoeren';

  @override
  String get bySigningIn => 'Door in te loggen ga je akkoord met de ';

  @override
  String get termsAndConditions => 'algemene voorwaarden';

  @override
  String get phoneNumberPlaceholder => '+32475123456';

  @override
  String get language => 'Taal';

  @override
  String get selectLanguage => 'Selecteer taal';

  @override
  String get languageChangedSuccessfully => 'Taal succesvol gewijzigd!';

  @override
  String get enterLoginCode => 'Voer inlogcode in';

  @override
  String get invalidCode => 'Ongeldige code';

  @override
  String get failedToSendCode => 'Code verzenden mislukt. Probeer het opnieuw.';

  @override
  String get sendingSmsCode => 'SMS-code verzenden...';

  @override
  String get loggingIn => 'Inloggen...';

  @override
  String get confirmCodeAgain => 'Code opnieuw bevestigen';

  @override
  String get confirmCode => 'Code bevestigen';

  @override
  String get sendNewCode => 'Nieuwe code verzenden';

  @override
  String get displayContacts => 'Contacten weergeven';

  @override
  String get skip => 'Overslaan';

  @override
  String get allow => 'Toestaan';

  @override
  String get settings => 'Instellingen';

  @override
  String get account => 'Account';

  @override
  String get fetchingExistingProfile => 'Bestaand profiel ophalen';

  @override
  String get uploadingNewProfile => 'Nieuw profiel uploaden';

  @override
  String get almostDone => 'Bijna klaar';

  @override
  String get saving => 'Opslaan';

  @override
  String get name => 'Naam';

  @override
  String get enterYourName => 'Voer je naam in';

  @override
  String get description => 'Beschrijving';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get enterYourUsername => 'Voer je gebruikersnaam in';

  @override
  String get usernameAlreadyTaken => 'Gebruikersnaam al in gebruik';

  @override
  String get orderNotFound => 'Bestelling niet gevonden';

  @override
  String get confirmOrder => 'Bestelling bevestigen';

  @override
  String get noItems => 'Geen artikelen';

  @override
  String get subtotal => 'Subtotaal';

  @override
  String get vat => 'BTW';

  @override
  String get total => 'Totaal';

  @override
  String get pay => 'Betalen';

  @override
  String get menu => 'Menu';

  @override
  String get enterAmount => 'Voer bedrag in';

  @override
  String get addMessage => 'Bericht toevoegen';

  @override
  String get topUp => 'Opwaarderen';

  @override
  String get shareInviteLink => 'Uitnodigingslink delen';

  @override
  String get orderDetails => 'Bestellingsdetails';

  @override
  String get addCard => 'Kaart toevoegen';

  @override
  String get appSettings => 'App-instellingen';

  @override
  String get newCard => 'Nieuwe kaart';

  @override
  String get myCard => 'Mijn kaart';

  @override
  String get claimCard => 'Kaart opeisen';

  @override
  String get alreadyClaimed => 'Al opgeëist';

  @override
  String get viewMenu => 'Menu bekijken';

  @override
  String get inspectCard => 'Kaart inspecteren';

  @override
  String get notifications => 'Meldingen';

  @override
  String get pushNotifications => 'Push-meldingen';

  @override
  String get searchForPeopleOrPlaces => 'Zoeken naar mensen of plaatsen';

  @override
  String get about => 'Over';

  @override
  String get general => 'Algemeen';

  @override
  String get audio => 'Audio';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get brusselsPay => 'Brussels Pay';

  @override
  String get addFunds => 'top up';
}
