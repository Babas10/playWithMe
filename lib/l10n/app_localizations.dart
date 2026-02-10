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

  /// Hint text for friend search input
  ///
  /// In en, this message translates to:
  /// **'Search friends by email...'**
  String get searchFriendsByEmail;

  /// Message when user searches for their own email
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself as a friend'**
  String get cannotAddYourself;

  /// Message when no user is found with the searched email
  ///
  /// In en, this message translates to:
  /// **'No user found with email: {email}'**
  String userNotFoundWithEmail(String email);

  /// Suggestion message for email not found
  ///
  /// In en, this message translates to:
  /// **'Make sure the email is correct'**
  String get makeSureEmailCorrect;

  /// Label for pending friend request
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestPending;

  /// Button text to accept a friend request
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest;

  /// Button text to send a friend request
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get sendFriendRequest;

  /// Search button label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Button to add a new friend
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// Empty state title on add friend page
  ///
  /// In en, this message translates to:
  /// **'Search for friends to add'**
  String get searchForFriendsToAdd;

  /// Empty state subtitle on add friend page
  ///
  /// In en, this message translates to:
  /// **'Enter an email address to find users'**
  String get enterEmailToFindFriends;

  /// Message shown when user needs to navigate to requests tab
  ///
  /// In en, this message translates to:
  /// **'Check the Requests tab to accept the friend request'**
  String get checkRequestsTab;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Text before sign up link on login page
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Reset password page title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Back to login button text
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Email sent dialog title
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get emailSent;

  /// Create account page title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Success message after account creation
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please check your email for verification.'**
  String get accountCreatedSuccess;

  /// Text before sign in link on registration page
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Display name optional field hint
  ///
  /// In en, this message translates to:
  /// **'Display Name (Optional)'**
  String get displayNameOptionalHint;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Create game page title and button
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get createGame;

  /// Success message after game creation
  ///
  /// In en, this message translates to:
  /// **'Game created successfully!'**
  String get gameCreatedSuccess;

  /// Message when user needs to log in to create game
  ///
  /// In en, this message translates to:
  /// **'Please log in to create a game'**
  String get pleaseLogInToCreateGame;

  /// Group field label
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// Date and time field label
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// Tap to select hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// Game details page title
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetails;

  /// Go back button text
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Organizer label
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// Enter results button label
  ///
  /// In en, this message translates to:
  /// **'Enter Results'**
  String get enterResults;

  /// Leave game menu option
  ///
  /// In en, this message translates to:
  /// **'Leave Game'**
  String get leaveGame;

  /// Leave waitlist menu option
  ///
  /// In en, this message translates to:
  /// **'Leave Waitlist'**
  String get leaveWaitlist;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Edit or dispute button label
  ///
  /// In en, this message translates to:
  /// **'Edit / Dispute'**
  String get editDispute;

  /// Filter games dialog title
  ///
  /// In en, this message translates to:
  /// **'Filter Games'**
  String get filterGames;

  /// All games filter option
  ///
  /// In en, this message translates to:
  /// **'All Games'**
  String get allGames;

  /// My games only filter option
  ///
  /// In en, this message translates to:
  /// **'My Games Only'**
  String get myGamesOnly;

  /// Game history page title
  ///
  /// In en, this message translates to:
  /// **'Game History'**
  String get gameHistory;

  /// Message to select filters
  ///
  /// In en, this message translates to:
  /// **'Select filters to view game history'**
  String get selectFiltersToView;

  /// Active filters label
  ///
  /// In en, this message translates to:
  /// **'Active filters: '**
  String get activeFilters;

  /// My games chip label
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get myGames;

  /// Game results page title
  ///
  /// In en, this message translates to:
  /// **'Game Results'**
  String get gameResults;

  /// Games list page title with group name
  ///
  /// In en, this message translates to:
  /// **'{groupName} Games'**
  String groupNameGames(String groupName);

  /// Record results page title
  ///
  /// In en, this message translates to:
  /// **'Record Results'**
  String get recordResults;

  /// Success message when teams are saved
  ///
  /// In en, this message translates to:
  /// **'Teams saved successfully'**
  String get teamsSavedSuccess;

  /// Team A label
  ///
  /// In en, this message translates to:
  /// **'Team A'**
  String get teamA;

  /// Team B label
  ///
  /// In en, this message translates to:
  /// **'Team B'**
  String get teamB;

  /// Enter scores page title
  ///
  /// In en, this message translates to:
  /// **'Enter Scores'**
  String get enterScores;

  /// Success message when scores are saved
  ///
  /// In en, this message translates to:
  /// **'Scores saved successfully!'**
  String get scoresSavedSuccess;

  /// Saving scores loading text
  ///
  /// In en, this message translates to:
  /// **'Saving scores...'**
  String get savingScores;

  /// One set option
  ///
  /// In en, this message translates to:
  /// **'1 Set'**
  String get oneSet;

  /// Best of 2 sets option
  ///
  /// In en, this message translates to:
  /// **'Best of 2'**
  String get bestOfTwo;

  /// Best of 3 sets option
  ///
  /// In en, this message translates to:
  /// **'Best of 3'**
  String get bestOfThree;

  /// Game title field label
  ///
  /// In en, this message translates to:
  /// **'Game Title'**
  String get gameTitle;

  /// Game title hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Beach Volleyball'**
  String get gameTitleHint;

  /// Optional description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Game description hint text
  ///
  /// In en, this message translates to:
  /// **'Add details about the game...'**
  String get gameDescriptionHint;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Location hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Venice Beach'**
  String get locationHint;

  /// Optional address field label
  ///
  /// In en, this message translates to:
  /// **'Address (Optional)'**
  String get addressOptional;

  /// Address hint text
  ///
  /// In en, this message translates to:
  /// **'Full address...'**
  String get addressHint;

  /// Filter tooltip
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Date range tooltip
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// Remove from team tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove from team'**
  String get removeFromTeam;

  /// Clear filter tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// Filter by date tooltip
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// Required group name field label
  ///
  /// In en, this message translates to:
  /// **'Group Name *'**
  String get groupNameRequired;

  /// Group name hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Beach Volleyball Crew'**
  String get groupNameHint;

  /// Group description hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Weekly beach volleyball games at Santa Monica'**
  String get groupDescriptionHint;

  /// Message when end time selected before start time
  ///
  /// In en, this message translates to:
  /// **'Please select start time first'**
  String get pleaseSelectStartTimeFirst;

  /// Validation message for start time
  ///
  /// In en, this message translates to:
  /// **'Please select start time'**
  String get pleaseSelectStartTime;

  /// Validation message for end time
  ///
  /// In en, this message translates to:
  /// **'Please select end time'**
  String get pleaseSelectEndTime;

  /// Success message after training creation
  ///
  /// In en, this message translates to:
  /// **'Training session created successfully!'**
  String get trainingCreatedSuccess;

  /// Create training session page title and button
  ///
  /// In en, this message translates to:
  /// **'Create Training Session'**
  String get createTrainingSession;

  /// Message when user needs to log in to create training
  ///
  /// In en, this message translates to:
  /// **'Please log in to create a training session'**
  String get pleaseLogInToCreateTraining;

  /// Start time field label
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// End time field label
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Training session page title
  ///
  /// In en, this message translates to:
  /// **'Training Session'**
  String get trainingSession;

  /// Message when training session is not found
  ///
  /// In en, this message translates to:
  /// **'Training session not found'**
  String get trainingNotFound;

  /// Message when training session is cancelled
  ///
  /// In en, this message translates to:
  /// **'Training session cancelled'**
  String get trainingCancelled;

  /// Error message when participants fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading participants'**
  String get errorLoadingParticipants;

  /// Success message when joining training
  ///
  /// In en, this message translates to:
  /// **'Successfully joined training session!'**
  String get joinedTrainingSuccess;

  /// Message when leaving training
  ///
  /// In en, this message translates to:
  /// **'You have left the training session'**
  String get leftTraining;

  /// Join training dialog title
  ///
  /// In en, this message translates to:
  /// **'Join Training Session'**
  String get joinTrainingSession;

  /// Join button text
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Leave training dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave Training Session'**
  String get leaveTrainingSession;

  /// Leave button text
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Cancel training dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Training Session?'**
  String get cancelTrainingSession;

  /// Keep session button text
  ///
  /// In en, this message translates to:
  /// **'Keep Session'**
  String get keepSession;

  /// Cancel session button text
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get cancelSession;

  /// Session feedback page title
  ///
  /// In en, this message translates to:
  /// **'Session Feedback'**
  String get sessionFeedback;

  /// Thank you message after feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// Back to session button text
  ///
  /// In en, this message translates to:
  /// **'Back to Session'**
  String get backToSession;

  /// Feedback rating label - needs work
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get needsWork;

  /// Feedback rating label - top level
  ///
  /// In en, this message translates to:
  /// **'Top-level training'**
  String get topLevelTraining;

  /// Validation message for feedback
  ///
  /// In en, this message translates to:
  /// **'Please rate all three categories before submitting'**
  String get pleaseRateAllCategories;

  /// Email verification page title
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// Success message when verification email is sent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}'**
  String verificationEmailSent(String email);

  /// Back to profile button text
  ///
  /// In en, this message translates to:
  /// **'Back to Profile'**
  String get backToProfile;

  /// Send verification email button text
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get sendVerificationEmail;

  /// Refresh status button text
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// ELO history page title
  ///
  /// In en, this message translates to:
  /// **'ELO History'**
  String get eloHistory;

  /// Coming soon message for game details
  ///
  /// In en, this message translates to:
  /// **'Game details coming soon!'**
  String get gameDetailsComingSoon;

  /// Head to head page title
  ///
  /// In en, this message translates to:
  /// **'Head-to-Head'**
  String get headToHead;

  /// Partner details page title
  ///
  /// In en, this message translates to:
  /// **'Partner Details'**
  String get partnerDetails;

  /// Invitations page title
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// Message when user needs to log in to view invitations
  ///
  /// In en, this message translates to:
  /// **'Please log in to view invitations'**
  String get pleaseLogInToViewInvitations;

  /// Pending invitations page title
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// Notification settings page title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Initializing state text
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Group invitations notification setting title
  ///
  /// In en, this message translates to:
  /// **'Group Invitations'**
  String get groupInvitations;

  /// Group invitations notification setting description
  ///
  /// In en, this message translates to:
  /// **'When someone invites you to a group'**
  String get groupInvitationsDesc;

  /// Invitation accepted notification setting title
  ///
  /// In en, this message translates to:
  /// **'Invitation Accepted'**
  String get invitationAccepted;

  /// Invitation accepted notification setting description
  ///
  /// In en, this message translates to:
  /// **'When someone accepts your invitation'**
  String get invitationAcceptedDesc;

  /// New games notification setting title
  ///
  /// In en, this message translates to:
  /// **'New Games'**
  String get newGames;

  /// New games notification setting description
  ///
  /// In en, this message translates to:
  /// **'When a new game is created in your groups'**
  String get newGamesDesc;

  /// Role changes notification setting title
  ///
  /// In en, this message translates to:
  /// **'Role Changes'**
  String get roleChanges;

  /// Role changes notification setting description
  ///
  /// In en, this message translates to:
  /// **'When you are promoted to admin'**
  String get roleChangesDesc;

  /// New training sessions notification setting title
  ///
  /// In en, this message translates to:
  /// **'New Training Sessions'**
  String get newTrainingSessions;

  /// New training sessions notification setting description
  ///
  /// In en, this message translates to:
  /// **'When a training session is created in your groups'**
  String get newTrainingSessionsDesc;

  /// Min participants reached notification setting title
  ///
  /// In en, this message translates to:
  /// **'Minimum Participants Reached'**
  String get minParticipantsReached;

  /// Min participants reached notification setting description
  ///
  /// In en, this message translates to:
  /// **'When a training session has enough participants'**
  String get minParticipantsReachedDesc;

  /// Feedback received notification setting title
  ///
  /// In en, this message translates to:
  /// **'Feedback Received'**
  String get feedbackReceived;

  /// Feedback received notification setting description
  ///
  /// In en, this message translates to:
  /// **'When someone leaves feedback on a training session'**
  String get feedbackReceivedDesc;

  /// Session cancelled notification setting title
  ///
  /// In en, this message translates to:
  /// **'Session Cancelled'**
  String get sessionCancelled;

  /// Session cancelled notification setting description
  ///
  /// In en, this message translates to:
  /// **'When a training session you joined is cancelled'**
  String get sessionCancelledDesc;

  /// Member joined notification setting title
  ///
  /// In en, this message translates to:
  /// **'Member Joined'**
  String get memberJoined;

  /// Member joined notification setting description
  ///
  /// In en, this message translates to:
  /// **'When someone joins your group'**
  String get memberJoinedDesc;

  /// Member left notification setting title
  ///
  /// In en, this message translates to:
  /// **'Member Left'**
  String get memberLeft;

  /// Member left notification setting description
  ///
  /// In en, this message translates to:
  /// **'When someone leaves your group'**
  String get memberLeftDesc;

  /// Enable quiet hours toggle title
  ///
  /// In en, this message translates to:
  /// **'Enable Quiet Hours'**
  String get enableQuietHours;

  /// Quiet hours toggle description
  ///
  /// In en, this message translates to:
  /// **'Pause notifications during specific times'**
  String get quietHoursDesc;

  /// Adjust quiet hours button title
  ///
  /// In en, this message translates to:
  /// **'Adjust Quiet Hours'**
  String get adjustQuietHours;

  /// Set quiet hours dialog title
  ///
  /// In en, this message translates to:
  /// **'Set Quiet Hours'**
  String get setQuietHours;

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// Message when user needs to log in to add friends
  ///
  /// In en, this message translates to:
  /// **'Please log in to add friends'**
  String get pleaseLogInToAddFriends;

  /// Welcome back heading on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Subtitle on login page
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue organizing your volleyball games'**
  String get signInToContinue;

  /// Validation error when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Validation error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailRequired;

  /// Validation error when password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Button to continue without account
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Heading on registration page
  ///
  /// In en, this message translates to:
  /// **'Join PlayWithMe!'**
  String get joinPlayWithMe;

  /// Subtitle on registration page
  ///
  /// In en, this message translates to:
  /// **'Create your account to start organizing volleyball games'**
  String get createAccountSubtitle;

  /// Validation error when display name is too long
  ///
  /// In en, this message translates to:
  /// **'Display name must be less than 50 characters'**
  String get displayNameTooLong;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Validation error when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Validation error when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Terms agreement text on registration page
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our Terms of Service and Privacy Policy.'**
  String get termsAgreement;

  /// Heading on password reset page
  ///
  /// In en, this message translates to:
  /// **'Forgot Your Password?'**
  String get forgotYourPassword;

  /// Instructions on password reset page
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get forgotPasswordInstructions;

  /// Button to send password reset email
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmail;

  /// Message in password reset success dialog
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to:'**
  String get resetLinkSentTo;

  /// Instructions in password reset success dialog
  ///
  /// In en, this message translates to:
  /// **'Please check your email and follow the instructions to reset your password.'**
  String get checkEmailResetInstructions;

  /// Heading when no game results
  ///
  /// In en, this message translates to:
  /// **'No results available yet'**
  String get noResultsAvailable;

  /// Description when no game results
  ///
  /// In en, this message translates to:
  /// **'Scores will appear here once they are entered'**
  String get scoresWillAppear;

  /// Section title for individual games
  ///
  /// In en, this message translates to:
  /// **'Individual Games'**
  String get individualGames;

  /// Question on score entry page
  ///
  /// In en, this message translates to:
  /// **'How many games did you play?'**
  String get howManyGamesPlayed;

  /// Heading on record results page
  ///
  /// In en, this message translates to:
  /// **'Assign Players to Teams'**
  String get assignPlayersToTeams;

  /// Instructions on record results page
  ///
  /// In en, this message translates to:
  /// **'Drag players to assign them to Team A or Team B'**
  String get dragPlayersToAssign;

  /// Status badge for pending verification
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// Status badge for confirmed participation
  ///
  /// In en, this message translates to:
  /// **'You\'re In'**
  String get youreIn;

  /// Status badge for waitlist
  ///
  /// In en, this message translates to:
  /// **'On Waitlist'**
  String get onWaitlist;

  /// Status badge when game is full
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// Button to join a game
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGame;

  /// Date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Date label for tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Player fallback name
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// Placeholder when no scores
  ///
  /// In en, this message translates to:
  /// **'No scores recorded'**
  String get noScoresRecorded;

  /// Badge text for ELO update
  ///
  /// In en, this message translates to:
  /// **'ELO Updated'**
  String get eloUpdated;

  /// Versus separator
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// Status badge for cancelled
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelled;

  /// Status badge for joined
  ///
  /// In en, this message translates to:
  /// **'JOINED'**
  String get joined;

  /// Training badge
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// Game badge label
  ///
  /// In en, this message translates to:
  /// **'GAME'**
  String get gameLabel;

  /// Minimum participants label
  ///
  /// In en, this message translates to:
  /// **'Min: {count}'**
  String minParticipants(int count);

  /// Help text for game date picker
  ///
  /// In en, this message translates to:
  /// **'Select Game Date'**
  String get selectGameDate;

  /// Help text for game time picker
  ///
  /// In en, this message translates to:
  /// **'Select Game Time'**
  String get selectGameTime;

  /// Validation error when game title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a game title'**
  String get pleaseTitleRequired;

  /// Validation error when title is too short
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get titleMinLength;

  /// Validation error when title is too long
  ///
  /// In en, this message translates to:
  /// **'Title must be less than 100 characters'**
  String get titleMaxLength;

  /// Validation error when title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Validation error when location is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get pleaseEnterLocation;

  /// Default text when nothing selected
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Help text for start date picker
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// Help text for start time picker
  ///
  /// In en, this message translates to:
  /// **'Select Start Time'**
  String get selectStartTime;

  /// Help text for end time picker
  ///
  /// In en, this message translates to:
  /// **'Select End Time'**
  String get selectEndTime;

  /// Participants tab label
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Exercises tab label
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// Feedback tab label
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Players label
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Description for create game option
  ///
  /// In en, this message translates to:
  /// **'Competitive game with ELO ratings'**
  String get competitiveGameWithElo;

  /// Description for create training option
  ///
  /// In en, this message translates to:
  /// **'Practice session without ELO impact'**
  String get practiceSessionNoElo;

  /// Dialog title for promoting member
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get promoteToAdmin;

  /// Promote button text
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// Dialog title for demoting admin
  ///
  /// In en, this message translates to:
  /// **'Demote to Member'**
  String get demoteToMember;

  /// Demote button text
  ///
  /// In en, this message translates to:
  /// **'Demote'**
  String get demote;

  /// Dialog title for removing member
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// Dialog title for leaving group
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// Select all button
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Upload button
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Success message for avatar upload
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded successfully'**
  String get avatarUploadedSuccess;

  /// Success message for avatar removal
  ///
  /// In en, this message translates to:
  /// **'Avatar removed successfully'**
  String get avatarRemovedSuccess;

  /// Best teammate card title
  ///
  /// In en, this message translates to:
  /// **'Best Teammate'**
  String get bestTeammate;

  /// Error heading when game not found
  ///
  /// In en, this message translates to:
  /// **'Game Not Found'**
  String get gameNotFound;

  /// Empty state title for game history
  ///
  /// In en, this message translates to:
  /// **'No completed games yet'**
  String get noCompletedGamesYet;

  /// Empty state description for game history
  ///
  /// In en, this message translates to:
  /// **'Games will appear here after they are completed'**
  String get gamesWillAppearAfterCompleted;

  /// Final score heading
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// ELO rating changes section title
  ///
  /// In en, this message translates to:
  /// **'ELO Rating Changes'**
  String get eloRatingChanges;

  /// Fallback name for unknown player
  ///
  /// In en, this message translates to:
  /// **'Unknown Player'**
  String get unknownPlayer;

  /// Game number label
  ///
  /// In en, this message translates to:
  /// **'Game {number}'**
  String gameNumber(int number);

  /// Sets score display
  ///
  /// In en, this message translates to:
  /// **'Sets: {teamA} - {teamB}'**
  String setsScore(int teamA, int teamB);

  /// Set number label
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(int number);

  /// Format label
  ///
  /// In en, this message translates to:
  /// **'Format:'**
  String get format;

  /// Validation error for invalid score
  ///
  /// In en, this message translates to:
  /// **'Invalid score'**
  String get invalidScore;

  /// Overall winner message for Team A
  ///
  /// In en, this message translates to:
  /// **'Overall Winner: Team A'**
  String get overallWinnerTeamA;

  /// Overall winner message for Team B
  ///
  /// In en, this message translates to:
  /// **'Overall Winner: Team B'**
  String get overallWinnerTeamB;

  /// Message shown when game result is a tie
  ///
  /// In en, this message translates to:
  /// **'Result: Tie'**
  String get resultTie;

  /// Save scores button
  ///
  /// In en, this message translates to:
  /// **'Save Scores'**
  String get saveScores;

  /// Message to complete games before saving
  ///
  /// In en, this message translates to:
  /// **'Complete {current}/{total} games to continue'**
  String completeGamesToContinue(int current, int total);

  /// Section header for upcoming activities
  ///
  /// In en, this message translates to:
  /// **'Upcoming Activities'**
  String get upcomingActivities;

  /// Section header for past activities
  ///
  /// In en, this message translates to:
  /// **'Past Activities'**
  String get pastActivities;

  /// Empty state title for games list
  ///
  /// In en, this message translates to:
  /// **'No upcoming games yet'**
  String get noUpcomingGamesYet;

  /// Empty state call to action
  ///
  /// In en, this message translates to:
  /// **'Create the first game!'**
  String get createFirstGame;

  /// Empty state title for activities list
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivitiesYet;

  /// Empty state call to action for activities
  ///
  /// In en, this message translates to:
  /// **'Create the first activity!'**
  String get createFirstActivity;

  /// Games won label
  ///
  /// In en, this message translates to:
  /// **'games won'**
  String get gamesWon;

  /// Single player count
  ///
  /// In en, this message translates to:
  /// **'1 player'**
  String get playerCountSingular;

  /// Multiple players count
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playerCountPlural(int count);

  /// Winner and score description
  ///
  /// In en, this message translates to:
  /// **'{winner} won {score}'**
  String wonScoreDescription(String winner, String score);

  /// Number of players waitlisted
  ///
  /// In en, this message translates to:
  /// **'{count} waitlisted'**
  String playersWaitlisted(int count);

  /// Current vs max players
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} players'**
  String playersCount(int current, int max);

  /// Label for minimum participants field
  ///
  /// In en, this message translates to:
  /// **'Min Participants'**
  String get minParticipantsLabel;

  /// Label for maximum participants field
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get maxParticipantsLabel;

  /// Message shown when user is the organizer
  ///
  /// In en, this message translates to:
  /// **'You are organizing'**
  String get youAreOrganizing;

  /// Message showing who organized the session
  ///
  /// In en, this message translates to:
  /// **'Organized by {name}'**
  String organizedBy(String name);

  /// Status label for scheduled sessions
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// Status label for completed sessions
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Empty state message when no participants
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get noParticipantsYet;

  /// Call to action to join empty session
  ///
  /// In en, this message translates to:
  /// **'Be the first to join!'**
  String get beFirstToJoin;

  /// Participation section title
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get participation;

  /// Current count label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Minimum count label
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// Maximum count label
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// Available spots label
  ///
  /// In en, this message translates to:
  /// **'Available Spots'**
  String get availableSpots;

  /// Label indicating current user
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Joining in progress text
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get joining;

  /// Leaving in progress text
  ///
  /// In en, this message translates to:
  /// **'Leaving...'**
  String get leaving;

  /// Message when user cannot join
  ///
  /// In en, this message translates to:
  /// **'Cannot Join'**
  String get cannotJoin;

  /// Info about notifying participants
  ///
  /// In en, this message translates to:
  /// **'All participants will be notified.'**
  String get allParticipantsNotified;

  /// Title when feedback was already submitted
  ///
  /// In en, this message translates to:
  /// **'Feedback Already Submitted'**
  String get feedbackAlreadySubmitted;

  /// Message when feedback was already provided
  ///
  /// In en, this message translates to:
  /// **'You have already provided feedback for \"{sessionTitle}\".'**
  String alreadyProvidedFeedback(String sessionTitle);

  /// Title for feedback form
  ///
  /// In en, this message translates to:
  /// **'Provide Anonymous Feedback'**
  String get provideAnonymousFeedback;

  /// Info about anonymous feedback
  ///
  /// In en, this message translates to:
  /// **'Your feedback is anonymous and helps improve future training sessions.'**
  String get feedbackIsAnonymous;

  /// Feedback category for exercise quality
  ///
  /// In en, this message translates to:
  /// **'Exercises Quality'**
  String get exercisesQuality;

  /// Subtitle for exercises quality rating
  ///
  /// In en, this message translates to:
  /// **'Were the drills effective?'**
  String get wereDrillsEffective;

  /// Feedback category for training intensity
  ///
  /// In en, this message translates to:
  /// **'Training Intensity'**
  String get trainingIntensity;

  /// Subtitle for training intensity rating
  ///
  /// In en, this message translates to:
  /// **'Physical demand level'**
  String get physicalDemandLevel;

  /// Feedback category for coaching clarity
  ///
  /// In en, this message translates to:
  /// **'Coaching Clarity'**
  String get coachingClarity;

  /// Subtitle for coaching clarity rating
  ///
  /// In en, this message translates to:
  /// **'Instructions & corrections?'**
  String get instructionsAndCorrections;

  /// Label for optional comments field
  ///
  /// In en, this message translates to:
  /// **'Additional Comments (Optional)'**
  String get additionalCommentsOptional;

  /// Hint text for feedback comments
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about the session, exercises, or suggestions for improvement...'**
  String get shareYourThoughts;

  /// Submit feedback button text
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// Privacy notice for feedback
  ///
  /// In en, this message translates to:
  /// **'Your feedback is completely anonymous and cannot be traced back to you.'**
  String get feedbackPrivacyNotice;

  /// Invite label
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Invite members tooltip
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// Admin only restriction message
  ///
  /// In en, this message translates to:
  /// **'Admin only'**
  String get adminOnly;

  /// Create label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Tooltip for create button
  ///
  /// In en, this message translates to:
  /// **'Create game or training session'**
  String get createGameOrTraining;

  /// Activities label
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// Tooltip for activities button
  ///
  /// In en, this message translates to:
  /// **'View all activities'**
  String get viewAllActivities;

  /// Remove from group menu item
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get removeFromGroup;

  /// Confirmation message for promoting member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote {name} to admin?\n\nAdmins can:\n• Manage group members\n• Invite new members\n• Modify group settings'**
  String promoteConfirmMessage(String name);

  /// Confirmation message for demoting admin
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote {name} to regular member?\n\nThey will lose admin privileges.'**
  String demoteConfirmMessage(String name);

  /// Confirmation message for removing member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the group?\n\nThis action cannot be undone. They will need to be re-invited to rejoin.'**
  String removeConfirmMessage(String name);

  /// Confirmation message for leaving group
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{groupName}\"?\n\nYou will need to be re-invited to rejoin this group.'**
  String leaveGroupConfirmMessage(String groupName);

  /// Performance stats section title
  ///
  /// In en, this message translates to:
  /// **'Performance Stats'**
  String get performanceStats;

  /// ELO rating stat label
  ///
  /// In en, this message translates to:
  /// **'ELO Rating'**
  String get eloRatingLabel;

  /// Peak rating label
  ///
  /// In en, this message translates to:
  /// **'Peak: {value}'**
  String peak(String value);

  /// Win rate stat label
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Wins and losses display
  ///
  /// In en, this message translates to:
  /// **'{wins}W - {losses}L'**
  String winsLosses(int wins, int losses);

  /// Streak stat label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// Winning streak label
  ///
  /// In en, this message translates to:
  /// **'Winning'**
  String get winning;

  /// Losing streak label
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get losingStreak;

  /// No streak label
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noStreak;

  /// Games played stat label
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayedLabel;

  /// Empty state for team with no players
  ///
  /// In en, this message translates to:
  /// **'No players assigned'**
  String get noPlayersAssigned;

  /// Section title for unassigned players
  ///
  /// In en, this message translates to:
  /// **'Unassigned Players'**
  String get unassignedPlayers;

  /// Success message when all players assigned
  ///
  /// In en, this message translates to:
  /// **'All players assigned!'**
  String get allPlayersAssigned;

  /// Save teams button text
  ///
  /// In en, this message translates to:
  /// **'Save Teams'**
  String get saveTeams;

  /// Message when not all players assigned
  ///
  /// In en, this message translates to:
  /// **'Assign All Players to Continue'**
  String get assignAllPlayersToContinue;

  /// Invitation info showing inviter name
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String invitedBy(String name);

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Participants count display
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} participants'**
  String participantsCount(int current, int max);

  /// Join confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Do you want to join \"{sessionTitle}\"?\n\nDate: {dateTime}\nLocation: {location}'**
  String doYouWantToJoin(String sessionTitle, String dateTime, String location);

  /// Leave confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{sessionTitle}\"?'**
  String areYouSureLeave(String sessionTitle);

  /// Cancel session confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel \"{sessionTitle}\"?\n\nAll participants will be notified.'**
  String cancelSessionConfirm(String sessionTitle);

  /// Duration display format
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationFormat(int hours, int minutes);

  /// Duration in hours only
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(int hours);

  /// Duration in minutes only
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @bestPartner.
  ///
  /// In en, this message translates to:
  /// **'Best Partner'**
  String get bestPartner;

  /// No description provided for @noPartnerDataYet.
  ///
  /// In en, this message translates to:
  /// **'No partner data yet'**
  String get noPartnerDataYet;

  /// No description provided for @playGamesWithTeammate.
  ///
  /// In en, this message translates to:
  /// **'Play 5+ games with a teammate'**
  String get playGamesWithTeammate;

  /// No description provided for @winRatePercent.
  ///
  /// In en, this message translates to:
  /// **'{rate}% Win Rate'**
  String winRatePercent(String rate);

  /// No description provided for @gamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} games'**
  String gamesCount(int count);

  /// No description provided for @winsLossesGames.
  ///
  /// In en, this message translates to:
  /// **'{wins}W - {losses}L • {total} games'**
  String winsLossesGames(int wins, int losses, int total);

  /// No description provided for @momentumAndConsistency.
  ///
  /// In en, this message translates to:
  /// **'Momentum & Consistency'**
  String get momentumAndConsistency;

  /// No description provided for @eloProgress.
  ///
  /// In en, this message translates to:
  /// **'ELO Progress'**
  String get eloProgress;

  /// No description provided for @winStreak.
  ///
  /// In en, this message translates to:
  /// **'Win Streak'**
  String get winStreak;

  /// No description provided for @lossStreak.
  ///
  /// In en, this message translates to:
  /// **'Loss Streak'**
  String get lossStreak;

  /// No description provided for @noActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'No Active Streak'**
  String get noActiveStreak;

  /// No description provided for @winNextGameToStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Win your next game to start a streak!'**
  String get winNextGameToStartStreak;

  /// No description provided for @rival.
  ///
  /// In en, this message translates to:
  /// **'Rival'**
  String get rival;

  /// No description provided for @matchups.
  ///
  /// In en, this message translates to:
  /// **'{count} matchups'**
  String matchups(int count);

  /// No description provided for @winRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Win Rate: {rate}%'**
  String winRateLabel(String rate);

  /// No description provided for @tapForFullBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Tap for full breakdown'**
  String get tapForFullBreakdown;

  /// No description provided for @noNemesisYet.
  ///
  /// In en, this message translates to:
  /// **'No Nemesis Yet'**
  String get noNemesisYet;

  /// No description provided for @playGamesAgainstSameOpponent.
  ///
  /// In en, this message translates to:
  /// **'Play at least 3 games against the same opponent to track your toughest matchup.'**
  String get playGamesAgainstSameOpponent;

  /// No description provided for @faceOpponentThreeTimes.
  ///
  /// In en, this message translates to:
  /// **'Face the same opponent 3+ times'**
  String get faceOpponentThreeTimes;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No Performance Data'**
  String get noPerformanceData;

  /// No description provided for @playFirstGameToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Play your first game to see your performance statistics!'**
  String get playFirstGameToSeeStats;

  /// No description provided for @playAtLeastOneGame.
  ///
  /// In en, this message translates to:
  /// **'Play at least 1 game to unlock'**
  String get playAtLeastOneGame;

  /// No description provided for @performanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// No description provided for @currentElo.
  ///
  /// In en, this message translates to:
  /// **'Current ELO'**
  String get currentElo;

  /// No description provided for @peakElo.
  ///
  /// In en, this message translates to:
  /// **'Peak ELO'**
  String get peakElo;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @bestWin.
  ///
  /// In en, this message translates to:
  /// **'Best Win'**
  String get bestWin;

  /// No description provided for @winGameToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Win a game to unlock'**
  String get winGameToUnlock;

  /// No description provided for @beatOpponentsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Beat opponents to track your best victory'**
  String get beatOpponentsToTrack;

  /// No description provided for @avgPointDiff.
  ///
  /// In en, this message translates to:
  /// **'Avg Point Diff'**
  String get avgPointDiff;

  /// No description provided for @completeGameToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Complete a game to unlock'**
  String get completeGameToUnlock;

  /// No description provided for @winAndLoseSetsToSee.
  ///
  /// In en, this message translates to:
  /// **'Win and lose sets to see your margins'**
  String get winAndLoseSetsToSee;

  /// No description provided for @avgPointDifferential.
  ///
  /// In en, this message translates to:
  /// **'Avg Point Differential'**
  String get avgPointDifferential;

  /// No description provided for @inWins.
  ///
  /// In en, this message translates to:
  /// **'In Wins'**
  String get inWins;

  /// No description provided for @inLosses.
  ///
  /// In en, this message translates to:
  /// **'In Losses'**
  String get inLosses;

  /// No description provided for @setsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCount(int count);

  /// No description provided for @teamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team: {names}'**
  String teamLabel(String names);

  /// No description provided for @teamEloLabel.
  ///
  /// In en, this message translates to:
  /// **'Team ELO: {elo}'**
  String teamEloLabel(String elo);

  /// No description provided for @eloGained.
  ///
  /// In en, this message translates to:
  /// **'{amount} ELO gained'**
  String eloGained(String amount);

  /// No description provided for @adaptabilityStats.
  ///
  /// In en, this message translates to:
  /// **'Adaptability Stats'**
  String get adaptabilityStats;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @seeHowYouPerform.
  ///
  /// In en, this message translates to:
  /// **'See how you perform in different team roles'**
  String get seeHowYouPerform;

  /// No description provided for @leadingTheTeam.
  ///
  /// In en, this message translates to:
  /// **'Leading the Team'**
  String get leadingTheTeam;

  /// No description provided for @whenHighestRated.
  ///
  /// In en, this message translates to:
  /// **'When you\'re the highest-rated player'**
  String get whenHighestRated;

  /// No description provided for @playingWithStrongerPartners.
  ///
  /// In en, this message translates to:
  /// **'Playing with Stronger Partners'**
  String get playingWithStrongerPartners;

  /// No description provided for @whenMoreExperiencedTeammates.
  ///
  /// In en, this message translates to:
  /// **'When playing with more experienced teammates'**
  String get whenMoreExperiencedTeammates;

  /// No description provided for @balancedTeams.
  ///
  /// In en, this message translates to:
  /// **'Balanced Teams'**
  String get balancedTeams;

  /// No description provided for @whenSimilarlyRatedTeammates.
  ///
  /// In en, this message translates to:
  /// **'When playing with similarly-rated teammates'**
  String get whenSimilarlyRatedTeammates;

  /// No description provided for @adaptabilityStatsLocked.
  ///
  /// In en, this message translates to:
  /// **'Adaptability Stats Locked'**
  String get adaptabilityStatsLocked;

  /// No description provided for @playMoreGamesToSeeRoles.
  ///
  /// In en, this message translates to:
  /// **'Play more games to see how you perform in different team roles'**
  String get playMoreGamesToSeeRoles;

  /// No description provided for @noStatsYet.
  ///
  /// In en, this message translates to:
  /// **'No Stats Yet'**
  String get noStatsYet;

  /// No description provided for @startPlayingToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Start playing games to see your statistics!'**
  String get startPlayingToSeeStats;

  /// No description provided for @playGamesToUnlockRankings.
  ///
  /// In en, this message translates to:
  /// **'Play games to unlock rankings'**
  String get playGamesToUnlockRankings;

  /// No description provided for @globalRank.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get globalRank;

  /// No description provided for @percentile.
  ///
  /// In en, this message translates to:
  /// **'Percentile'**
  String get percentile;

  /// No description provided for @friendsRank.
  ///
  /// In en, this message translates to:
  /// **'Friends Rank'**
  String get friendsRank;

  /// No description provided for @addFriendsAction.
  ///
  /// In en, this message translates to:
  /// **'Add friends'**
  String get addFriendsAction;

  /// No description provided for @period30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get period30d;

  /// No description provided for @period90d.
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get period90d;

  /// No description provided for @period1y.
  ///
  /// In en, this message translates to:
  /// **'1y'**
  String get period1y;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// No description provided for @monthlyProgressChart.
  ///
  /// In en, this message translates to:
  /// **'Monthly Progress Chart'**
  String get monthlyProgressChart;

  /// No description provided for @playAtLeastNGames.
  ///
  /// In en, this message translates to:
  /// **'Play at least {count} games'**
  String playAtLeastNGames(int count);

  /// No description provided for @nOfNGames.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} games'**
  String nOfNGames(int current, int total);

  /// No description provided for @startPlayingToTrackProgress.
  ///
  /// In en, this message translates to:
  /// **'Start playing to track your progress!'**
  String get startPlayingToTrackProgress;

  /// No description provided for @keepPlayingToUnlockChart.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to unlock this chart!'**
  String get keepPlayingToUnlockChart;

  /// No description provided for @playGamesOverLongerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Play games over a longer period'**
  String get playGamesOverLongerPeriod;

  /// No description provided for @keepPlayingToSeeProgress.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to see your progress!'**
  String get keepPlayingToSeeProgress;

  /// No description provided for @noGamesInThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'No Games in This Period'**
  String get noGamesInThisPeriod;

  /// No description provided for @noGamesPlayedInLast.
  ///
  /// In en, this message translates to:
  /// **'No games played in the last {period}'**
  String noGamesPlayedInLast(String period);

  /// No description provided for @trySelectingLongerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a longer time period'**
  String get trySelectingLongerPeriod;

  /// No description provided for @periodLabel30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get periodLabel30Days;

  /// No description provided for @periodLabel90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get periodLabel90Days;

  /// No description provided for @periodLabelYear.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get periodLabelYear;

  /// No description provided for @periodLabelAllTime.
  ///
  /// In en, this message translates to:
  /// **'all time'**
  String get periodLabelAllTime;

  /// No description provided for @bestEloThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Best ELO This Month'**
  String get bestEloThisMonth;

  /// No description provided for @bestEloPast90Days.
  ///
  /// In en, this message translates to:
  /// **'Best ELO Past 90 Days'**
  String get bestEloPast90Days;

  /// No description provided for @bestEloThisYear.
  ///
  /// In en, this message translates to:
  /// **'Best ELO This Year'**
  String get bestEloThisYear;

  /// No description provided for @bestEloAllTime.
  ///
  /// In en, this message translates to:
  /// **'Best ELO All Time'**
  String get bestEloAllTime;

  /// No description provided for @lastNGames.
  ///
  /// In en, this message translates to:
  /// **'Last {count} games'**
  String lastNGames(int count);

  /// No description provided for @noGamesPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesPlayedYet;

  /// No description provided for @winsStreakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} wins'**
  String winsStreakCount(int count);

  /// No description provided for @lossesStreakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} losses'**
  String lossesStreakCount(int count);

  /// No description provided for @partnerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Details'**
  String get partnerDetailsTitle;

  /// No description provided for @overallRecord.
  ///
  /// In en, this message translates to:
  /// **'Overall Record'**
  String get overallRecord;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @pointDifferential.
  ///
  /// In en, this message translates to:
  /// **'Point Differential'**
  String get pointDifferential;

  /// No description provided for @avgPerGame.
  ///
  /// In en, this message translates to:
  /// **'Avg Per Game'**
  String get avgPerGame;

  /// No description provided for @pointsFor.
  ///
  /// In en, this message translates to:
  /// **'Points For'**
  String get pointsFor;

  /// No description provided for @pointsAgainst.
  ///
  /// In en, this message translates to:
  /// **'Points Against'**
  String get pointsAgainst;

  /// No description provided for @eloPerformance.
  ///
  /// In en, this message translates to:
  /// **'ELO Performance'**
  String get eloPerformance;

  /// No description provided for @totalChange.
  ///
  /// In en, this message translates to:
  /// **'Total Change'**
  String get totalChange;

  /// No description provided for @recentForm.
  ///
  /// In en, this message translates to:
  /// **'Recent Form'**
  String get recentForm;

  /// No description provided for @streakWins.
  ///
  /// In en, this message translates to:
  /// **'{count} W Streak'**
  String streakWins(int count);

  /// No description provided for @streakLosses.
  ///
  /// In en, this message translates to:
  /// **'{count} L Streak'**
  String streakLosses(int count);

  /// No description provided for @noRecentGames.
  ///
  /// In en, this message translates to:
  /// **'No recent games'**
  String get noRecentGames;

  /// No description provided for @eloLabel.
  ///
  /// In en, this message translates to:
  /// **'ELO: {value}'**
  String eloLabel(String value);

  /// Header for next upcoming game section on homepage
  ///
  /// In en, this message translates to:
  /// **'Next Game'**
  String get nextGame;

  /// Message shown when user has no upcoming games
  ///
  /// In en, this message translates to:
  /// **'No games organized yet'**
  String get noGamesScheduled;

  /// Header for next upcoming training session section on homepage
  ///
  /// In en, this message translates to:
  /// **'Next Training Session'**
  String get nextTrainingSession;

  /// Message shown when user has no upcoming training sessions
  ///
  /// In en, this message translates to:
  /// **'No training sessions scheduled'**
  String get noTrainingSessionsScheduled;
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
