// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PlayWithMe';

  @override
  String get welcomeMessage => 'Welcome to PlayWithMe!';

  @override
  String get beachVolleyballOrganizer => 'Beach volleyball games organizer';

  @override
  String get firebaseConnected => 'Connected';

  @override
  String get firebaseDisconnected => 'Disconnected';

  @override
  String get firebase => 'Firebase';

  @override
  String get environment => 'Environment';

  @override
  String get project => 'Project';

  @override
  String get loading => 'Loading...';

  @override
  String get profile => 'Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get displayName => 'Display Name';

  @override
  String get language => 'Language';

  @override
  String get country => 'Country';

  @override
  String get timezone => 'Time Zone';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get settingsUpdatedSuccessfully => 'Settings updated successfully';

  @override
  String get removeAvatar => 'Remove Avatar';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get confirmRemoveAvatar =>
      'Are you sure you want to remove your avatar?';

  @override
  String get remove => 'Remove';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get discard => 'Discard';

  @override
  String get displayNameHint => 'Enter your display name';

  @override
  String get preferredLanguage => 'Preferred Language';

  @override
  String get saving => 'Saving...';

  @override
  String get stay => 'Stay';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get verify => 'Verify';

  @override
  String get accountType => 'Account Type';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get regular => 'Regular';

  @override
  String get memberSince => 'Member Since';

  @override
  String get lastActive => 'Last Active';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get pleaseLogIn => 'Please log in to view your profile';

  @override
  String get userId => 'User ID';

  @override
  String get myGroups => 'My Groups';

  @override
  String get pleaseLogInToViewGroups => 'Please log in to view your groups';

  @override
  String get errorLoadingGroups => 'Error Loading Groups';

  @override
  String get retry => 'Retry';

  @override
  String get createGroup => 'Create Group';

  @override
  String get groupDetailsComingSoon => 'Group details page coming soon!';

  @override
  String get noGroupsYet => 'You\'re not part of any group yet';

  @override
  String get noGroupsMessage =>
      'Create or join groups to start organizing beach volleyball games with your friends!';

  @override
  String memberCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get publicGroup => 'Public';

  @override
  String get inviteOnlyGroup => 'Invite Only';

  @override
  String get privateGroup => 'Private';

  @override
  String get createYourFirstGroup => 'Create Your First Group';

  @override
  String get useCreateGroupButton =>
      'Use the Create Group button below to get started.';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Groups';
}
