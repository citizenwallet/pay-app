import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('fr', 'BE'),
    Locale('nl'),
    Locale('nl', 'BE')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Brussels Pay'**
  String get appTitle;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Refresh text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Retry text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success text
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning text
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information text
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Log out text
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// Log out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// Delete data text
  ///
  /// In en, this message translates to:
  /// **'Delete data & log out'**
  String get deleteData;

  /// Delete data confirmation message
  ///
  /// In en, this message translates to:
  /// **'Your profile will be cleared and you will be logged out.'**
  String get deleteDataConfirm;

  /// Card added message
  ///
  /// In en, this message translates to:
  /// **'Card added'**
  String get cardAdded;

  /// Card already added message
  ///
  /// In en, this message translates to:
  /// **'Card already added'**
  String get cardAlreadyAdded;

  /// Card not configured message
  ///
  /// In en, this message translates to:
  /// **'Card not configured'**
  String get cardNotConfigured;

  /// Configure button text
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// Card configured message
  ///
  /// In en, this message translates to:
  /// **'Card configured'**
  String get cardConfigured;

  /// NFC not available message
  ///
  /// In en, this message translates to:
  /// **'NFC is not available on this device'**
  String get nfcNotAvailable;

  /// Topup on the way message
  ///
  /// In en, this message translates to:
  /// **'Your topup is on the way'**
  String get topupOnWay;

  /// No results found message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Release card text
  ///
  /// In en, this message translates to:
  /// **'Release Card'**
  String get releaseCard;

  /// Release button text
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No orders found message
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// Transaction failed message
  ///
  /// In en, this message translates to:
  /// **'Transaction failed'**
  String get transactionFailed;

  /// Items text
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Tokens text
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// Order number text
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumber(String orderId);

  /// QR code text
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// Terminal text
  ///
  /// In en, this message translates to:
  /// **'terminal'**
  String get terminal;

  /// App text
  ///
  /// In en, this message translates to:
  /// **'app'**
  String get app;

  /// Sending text
  ///
  /// In en, this message translates to:
  /// **'sending...'**
  String get sending;

  /// Manual entry text
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Enter text placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get enterText;

  /// By signing in text
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the '**
  String get bySigningIn;

  /// Terms and conditions text
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get termsAndConditions;

  /// Phone number placeholder
  ///
  /// In en, this message translates to:
  /// **'+32475123456'**
  String get phoneNumberPlaceholder;

  /// Language text
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language text
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language changed successfully message
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully!'**
  String get languageChangedSuccessfully;

  /// Enter login code placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter login code'**
  String get enterLoginCode;

  /// Invalid code error message
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// Sending SMS code message
  ///
  /// In en, this message translates to:
  /// **'Sending SMS Code...'**
  String get sendingSmsCode;

  /// Logging in message
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// Confirm code again button text
  ///
  /// In en, this message translates to:
  /// **'Confirm code again'**
  String get confirmCodeAgain;

  /// Confirm code button text
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get confirmCode;

  /// Send new code button text
  ///
  /// In en, this message translates to:
  /// **'Send new code'**
  String get sendNewCode;

  /// Display contacts permission text
  ///
  /// In en, this message translates to:
  /// **'Display contacts'**
  String get displayContacts;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Allow button text
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Settings text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Account text
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Fetching existing profile message
  ///
  /// In en, this message translates to:
  /// **'Fetching existing profile'**
  String get fetchingExistingProfile;

  /// Uploading new profile message
  ///
  /// In en, this message translates to:
  /// **'Uploading new profile'**
  String get uploadingNewProfile;

  /// Almost done message
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get almostDone;

  /// Saving message
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// Name text
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Enter your name placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Description text
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Username text
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Enter your username placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// Username already taken error message
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameAlreadyTaken;

  /// Order not found message
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// Confirm order button text
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No items message
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// Subtotal text
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// VAT text
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// Total text
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Pay button text
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// Menu text
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Enter amount placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// Add message placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a message'**
  String get addMessage;

  /// Top up button text
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// Share invite link button text
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get shareInviteLink;

  /// Order details text
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// Add card button text
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// App settings text
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// New card text
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get newCard;

  /// My card text
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get myCard;

  /// Claim card button text
  ///
  /// In en, this message translates to:
  /// **'Claim Card'**
  String get claimCard;

  /// Already claimed message
  ///
  /// In en, this message translates to:
  /// **'Already claimed'**
  String get alreadyClaimed;

  /// View menu button text
  ///
  /// In en, this message translates to:
  /// **'View Menu'**
  String get viewMenu;

  /// Inspect card button text
  ///
  /// In en, this message translates to:
  /// **'Inspect Card'**
  String get inspectCard;

  /// Notifications text
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications text
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// Search for people or places placeholder
  ///
  /// In en, this message translates to:
  /// **'Search for people or places'**
  String get searchForPeopleOrPlaces;

  /// About text
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Audio text
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Privacy policy text
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Brussels Pay text
  ///
  /// In en, this message translates to:
  /// **'Brussels Pay'**
  String get brusselsPay;

  /// Add funds button text
  ///
  /// In en, this message translates to:
  /// **'top up'**
  String get addFunds;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'BE':
            return AppLocalizationsFrBe();
        }
        break;
      }
    case 'nl':
      {
        switch (locale.countryCode) {
          case 'BE':
            return AppLocalizationsNlBe();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
