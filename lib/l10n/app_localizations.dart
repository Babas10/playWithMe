import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'PlayWithMe'**
  String get appTitle;

  /// Welcome message on home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlayWithMe!'**
  String get welcomeMessage;

  /// App description subtitle
  ///
  /// In en, this message translates to:
  /// **'Beach volleyball games organizer'**
  String get beachVolleyballOrganizer;

  /// Firebase connection status - connected
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get firebaseConnected;

  /// Firebase connection status - disconnected
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get firebaseDisconnected;

  /// Firebase label
  ///
  /// In en, this message translates to:
  /// **'Firebase'**
  String get firebase;

  /// Environment label
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// Project label
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Profile button tooltip and page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Sign out button tooltip
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Account settings page title
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Display name field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Language preference label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Country preference label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Time zone field label
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timezone;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Success message when settings are saved
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get settingsUpdatedSuccessfully;

  /// Remove avatar button text
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get removeAvatar;

  /// Take photo option in image picker
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option in image picker
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Confirmation dialog message for removing avatar
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your avatar?'**
  String get confirmRemoveAvatar;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Title for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// Message for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get unsavedChangesMessage;

  /// Discard button text
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Hint text for display name field
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get displayNameHint;

  /// Preferred language field label
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguage;

  /// Saving indicator text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Stay button in unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Account information section title
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Verify email button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Account type label
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// Anonymous account type
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Regular account type
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// Member since label
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// Last active label
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get lastActive;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// Message shown when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get pleaseLogIn;

  /// User ID label
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// My groups page title
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// Message shown when user is not logged in on groups page
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your groups'**
  String get pleaseLogInToViewGroups;

  /// Error message title when groups fail to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Groups'**
  String get errorLoadingGroups;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Create group button text
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// Coming soon message for group details
  ///
  /// In en, this message translates to:
  /// **'Group details page coming soon!'**
  String get groupDetailsComingSoon;

  /// Empty state title when user has no groups
  ///
  /// In en, this message translates to:
  /// **'You\'re not part of any group yet'**
  String get noGroupsYet;

  /// Empty state message when user has no groups
  ///
  /// In en, this message translates to:
  /// **'Create or join groups to start organizing beach volleyball games with your friends!'**
  String get noGroupsMessage;

  /// Member count label with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String memberCount(int count);

  /// Public group privacy label
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicGroup;

  /// Invite only group privacy label
  ///
  /// In en, this message translates to:
  /// **'Invite Only'**
  String get inviteOnlyGroup;

  /// Private group privacy label
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateGroup;

  /// Button text to create first group in empty state
  ///
  /// In en, this message translates to:
  /// **'Create Your First Group'**
  String get createYourFirstGroup;

  /// Instruction text for creating groups in empty state
  ///
  /// In en, this message translates to:
  /// **'Use the Create Group button below to get started.'**
  String get useCreateGroupButton;

  /// Home navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Groups navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Community navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// My Community page title
  ///
  /// In en, this message translates to:
  /// **'My Community'**
  String get myCommunity;

  /// Friends tab label
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Friend requests tab label
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// Empty state title when user has no friends
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any friends yet'**
  String get noFriendsYet;

  /// Empty state message when user has no friends
  ///
  /// In en, this message translates to:
  /// **'Search for friends to get started!'**
  String get searchForFriends;

  /// Empty state message when no pending requests
  ///
  /// In en, this message translates to:
  /// **'No pending friend requests'**
  String get noPendingRequests;

  /// Section title for received friend requests
  ///
  /// In en, this message translates to:
  /// **'Received Requests'**
  String get receivedRequests;

  /// Section title for sent friend requests
  ///
  /// In en, this message translates to:
  /// **'Sent Requests'**
  String get sentRequests;

  /// Accept friend request button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Decline friend request button
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Remove friend confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Friend?'**
  String get removeFriend;

  /// Remove friend confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from your friends?'**
  String removeFriendConfirmation(String name);

  /// Error message when friends fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading friends'**
  String get errorLoadingFriends;
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
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
