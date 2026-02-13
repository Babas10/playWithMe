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

  @override
  String get community => 'Community';

  @override
  String get myCommunity => 'My Community';

  @override
  String get friends => 'Friends';

  @override
  String get requests => 'Requests';

  @override
  String get noFriendsYet => 'You don\'t have any friends yet';

  @override
  String get searchForFriends => 'Search for friends to get started!';

  @override
  String get noPendingRequests => 'No pending friend requests';

  @override
  String get receivedRequests => 'Received Requests';

  @override
  String get sentRequests => 'Sent Requests';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get pending => 'Pending';

  @override
  String get removeFriend => 'Remove Friend?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Are you sure you want to remove $name from your friends?';
  }

  @override
  String get errorLoadingFriends => 'Error loading friends';

  @override
  String get searchFriendsByEmail => 'Search friends by email...';

  @override
  String get cannotAddYourself => 'You cannot add yourself as a friend';

  @override
  String userNotFoundWithEmail(String email) {
    return 'No user found with email: $email';
  }

  @override
  String get makeSureEmailCorrect => 'Make sure the email is correct';

  @override
  String get requestPending => 'Pending';

  @override
  String get acceptRequest => 'Accept Request';

  @override
  String get sendFriendRequest => 'Add';

  @override
  String get search => 'Search';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get searchForFriendsToAdd => 'Search for friends to add';

  @override
  String get enterEmailToFindFriends => 'Enter an email address to find users';

  @override
  String get checkRequestsTab =>
      'Check the Requests tab to accept the friend request';

  @override
  String get ok => 'OK';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get accountCreatedSuccess =>
      'Account created successfully! Please check your email for verification.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign In';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get displayNameOptionalHint => 'Display Name (Optional)';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get createGame => 'Create Game';

  @override
  String get gameCreatedSuccess => 'Game created successfully!';

  @override
  String get pleaseLogInToCreateGame => 'Please log in to create a game';

  @override
  String get group => 'Group';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get gameDetails => 'Game Details';

  @override
  String get goBack => 'Go Back';

  @override
  String get organizer => 'Organizer';

  @override
  String get enterResults => 'Enter Results';

  @override
  String get leaveGame => 'Leave Game';

  @override
  String get leaveWaitlist => 'Leave Waitlist';

  @override
  String get confirm => 'Confirm';

  @override
  String get editDispute => 'Edit / Dispute';

  @override
  String get filterGames => 'Filter Games';

  @override
  String get allGames => 'All Games';

  @override
  String get myGamesOnly => 'My Games Only';

  @override
  String get gameHistory => 'Game History';

  @override
  String get selectFiltersToView => 'Select filters to view game history';

  @override
  String get activeFilters => 'Active filters: ';

  @override
  String get myGames => 'My Games';

  @override
  String get gameResults => 'Game Results';

  @override
  String groupNameGames(String groupName) {
    return '$groupName Games';
  }

  @override
  String get recordResults => 'Record Results';

  @override
  String get teamsSavedSuccess => 'Teams saved successfully';

  @override
  String get teamA => 'Team A';

  @override
  String get teamB => 'Team B';

  @override
  String get enterScores => 'Enter Scores';

  @override
  String get scoresSavedSuccess => 'Scores saved successfully!';

  @override
  String get savingScores => 'Saving scores...';

  @override
  String get oneSet => '1 Set';

  @override
  String get bestOfTwo => 'Best of 2';

  @override
  String get bestOfThree => 'Best of 3';

  @override
  String get gameTitle => 'Game Title';

  @override
  String get gameTitleHint => 'e.g., Beach Volleyball';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get gameDescriptionHint => 'Add details about the game...';

  @override
  String get location => 'Location';

  @override
  String get locationHint => 'e.g., Venice Beach';

  @override
  String get addressOptional => 'Address (Optional)';

  @override
  String get addressHint => 'Full address...';

  @override
  String get filter => 'Filter';

  @override
  String get dateRange => 'Date Range';

  @override
  String get removeFromTeam => 'Remove from team';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get groupNameRequired => 'Group Name *';

  @override
  String get groupNameHint => 'e.g., Beach Volleyball Crew';

  @override
  String get groupDescriptionHint =>
      'e.g., Weekly beach volleyball games at Santa Monica';

  @override
  String get pleaseSelectStartTimeFirst => 'Please select start time first';

  @override
  String get pleaseSelectStartTime => 'Please select start time';

  @override
  String get pleaseSelectEndTime => 'Please select end time';

  @override
  String get trainingCreatedSuccess => 'Training session created successfully!';

  @override
  String get createTrainingSession => 'Create Training Session';

  @override
  String get pleaseLogInToCreateTraining =>
      'Please log in to create a training session';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get title => 'Title';

  @override
  String get trainingSession => 'Training Session';

  @override
  String get trainingNotFound => 'Training session not found';

  @override
  String get trainingCancelled => 'Training session cancelled';

  @override
  String get errorLoadingParticipants => 'Error loading participants';

  @override
  String get joinedTrainingSuccess => 'Successfully joined training session!';

  @override
  String get leftTraining => 'You have left the training session';

  @override
  String get joinTrainingSession => 'Join Training Session';

  @override
  String get join => 'Join';

  @override
  String get leaveTrainingSession => 'Leave Training Session';

  @override
  String get leave => 'Leave';

  @override
  String get cancelTrainingSession => 'Cancel Training Session?';

  @override
  String get keepSession => 'Keep Session';

  @override
  String get cancelSession => 'Cancel Session';

  @override
  String get sessionFeedback => 'Session Feedback';

  @override
  String get thankYouFeedback => 'Thank you for your feedback!';

  @override
  String get backToSession => 'Back to Session';

  @override
  String get needsWork => 'Needs work';

  @override
  String get topLevelTraining => 'Top-level training';

  @override
  String get pleaseRateAllCategories =>
      'Please rate all three categories before submitting';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String verificationEmailSent(String email) {
    return 'Verification email sent to $email';
  }

  @override
  String get backToProfile => 'Back to Profile';

  @override
  String get sendVerificationEmail => 'Send Verification Email';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get eloHistory => 'ELO History';

  @override
  String get gameDetailsComingSoon => 'Game details coming soon!';

  @override
  String get headToHead => 'Head-to-Head';

  @override
  String get partnerDetails => 'Partner Details';

  @override
  String get invitations => 'Invitations';

  @override
  String get pleaseLogInToViewInvitations =>
      'Please log in to view invitations';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get initializing => 'Initializing...';

  @override
  String get groupInvitations => 'Group Invitations';

  @override
  String get groupInvitationsDesc => 'When someone invites you to a group';

  @override
  String get invitationAccepted => 'Invitation Accepted';

  @override
  String get invitationAcceptedDesc => 'When someone accepts your invitation';

  @override
  String get newGames => 'New Games';

  @override
  String get newGamesDesc => 'When a new game is created in your groups';

  @override
  String get roleChanges => 'Role Changes';

  @override
  String get roleChangesDesc => 'When you are promoted to admin';

  @override
  String get newTrainingSessions => 'New Training Sessions';

  @override
  String get newTrainingSessionsDesc =>
      'When a training session is created in your groups';

  @override
  String get minParticipantsReached => 'Minimum Participants Reached';

  @override
  String get minParticipantsReachedDesc =>
      'When a training session has enough participants';

  @override
  String get feedbackReceived => 'Feedback Received';

  @override
  String get feedbackReceivedDesc =>
      'When someone leaves feedback on a training session';

  @override
  String get sessionCancelled => 'Session Cancelled';

  @override
  String get sessionCancelledDesc =>
      'When a training session you joined is cancelled';

  @override
  String get memberJoined => 'Member Joined';

  @override
  String get memberJoinedDesc => 'When someone joins your group';

  @override
  String get memberLeft => 'Member Left';

  @override
  String get memberLeftDesc => 'When someone leaves your group';

  @override
  String get enableQuietHours => 'Enable Quiet Hours';

  @override
  String get quietHoursDesc => 'Pause notifications during specific times';

  @override
  String get adjustQuietHours => 'Adjust Quiet Hours';

  @override
  String get setQuietHours => 'Set Quiet Hours';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get pleaseLogInToAddFriends => 'Please log in to add friends';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToContinue =>
      'Sign in to continue organizing your volleyball games';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmailRequired => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get joinPlayWithMe => 'Join PlayWithMe!';

  @override
  String get createAccountSubtitle =>
      'Create your account to start organizing volleyball games';

  @override
  String get displayNameTooLong =>
      'Display name must be less than 50 characters';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get termsAgreement =>
      'By creating an account, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get forgotYourPassword => 'Forgot Your Password?';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get resetLinkSentTo => 'We\'ve sent a password reset link to:';

  @override
  String get checkEmailResetInstructions =>
      'Please check your email and follow the instructions to reset your password.';

  @override
  String get noResultsAvailable => 'No results available yet';

  @override
  String get scoresWillAppear =>
      'Scores will appear here once they are entered';

  @override
  String get individualGames => 'Individual Games';

  @override
  String get howManyGamesPlayed => 'How many games did you play?';

  @override
  String get assignPlayersToTeams => 'Assign Players to Teams';

  @override
  String get dragPlayersToAssign =>
      'Drag players to assign them to Team A or Team B';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get youreIn => 'You\'re In';

  @override
  String get onWaitlist => 'On Waitlist';

  @override
  String get full => 'Full';

  @override
  String get joinGame => 'Join Game';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get player => 'Player';

  @override
  String get noScoresRecorded => 'No scores recorded';

  @override
  String get eloUpdated => 'ELO Updated';

  @override
  String get vs => 'VS';

  @override
  String get cancelled => 'CANCELLED';

  @override
  String get joined => 'JOINED';

  @override
  String get training => 'Training';

  @override
  String get gameLabel => 'GAME';

  @override
  String minParticipants(int count) {
    return 'Min: $count';
  }

  @override
  String get selectGameDate => 'Select Game Date';

  @override
  String get selectGameTime => 'Select Game Time';

  @override
  String get pleaseTitleRequired => 'Please enter a game title';

  @override
  String get titleMinLength => 'Title must be at least 3 characters';

  @override
  String get titleMaxLength => 'Title must be less than 100 characters';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterLocation => 'Please enter a location';

  @override
  String get notSelected => 'Not selected';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectStartTime => 'Select Start Time';

  @override
  String get selectEndTime => 'Select End Time';

  @override
  String get participants => 'Participants';

  @override
  String get exercises => 'Exercises';

  @override
  String get feedback => 'Feedback';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get players => 'Players';

  @override
  String get competitiveGameWithElo => 'Competitive game with ELO ratings';

  @override
  String get practiceSessionNoElo => 'Practice session without ELO impact';

  @override
  String get promoteToAdmin => 'Promote to Admin';

  @override
  String get promote => 'Promote';

  @override
  String get demoteToMember => 'Demote to Member';

  @override
  String get demote => 'Demote';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get selectAll => 'Select All';

  @override
  String get clearAll => 'Clear All';

  @override
  String get upload => 'Upload';

  @override
  String get avatarUploadedSuccess => 'Avatar uploaded successfully';

  @override
  String get avatarRemovedSuccess => 'Avatar removed successfully';

  @override
  String get bestTeammate => 'Best Teammate';

  @override
  String get gameNotFound => 'Game Not Found';

  @override
  String get noCompletedGamesYet => 'No completed games yet';

  @override
  String get gamesWillAppearAfterCompleted =>
      'Games will appear here after they are completed';

  @override
  String get finalScore => 'Final Score';

  @override
  String get eloRatingChanges => 'ELO Rating Changes';

  @override
  String get unknownPlayer => 'Unknown Player';

  @override
  String gameNumber(int number) {
    return 'Game $number';
  }

  @override
  String setsScore(int teamA, int teamB) {
    return 'Sets: $teamA - $teamB';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get format => 'Format:';

  @override
  String get invalidScore => 'Invalid score';

  @override
  String get overallWinnerTeamA => 'Overall Winner: Team A';

  @override
  String get overallWinnerTeamB => 'Overall Winner: Team B';

  @override
  String get resultTie => 'Result: Tie';

  @override
  String get saveScores => 'Save Scores';

  @override
  String completeGamesToContinue(int current, int total) {
    return 'Complete $current/$total games to continue';
  }

  @override
  String get upcomingActivities => 'Upcoming Activities';

  @override
  String get pastActivities => 'Past Activities';

  @override
  String get noUpcomingGamesYet => 'No upcoming games yet';

  @override
  String get createFirstGame => 'Create the first game!';

  @override
  String get noActivitiesYet => 'No activities yet';

  @override
  String get createFirstActivity => 'Create the first activity!';

  @override
  String get gamesWon => 'games won';

  @override
  String get playerCountSingular => '1 player';

  @override
  String playerCountPlural(int count) {
    return '$count players';
  }

  @override
  String wonScoreDescription(String winner, String score) {
    return '$winner won $score';
  }

  @override
  String playersWaitlisted(int count) {
    return '$count waitlisted';
  }

  @override
  String playersCount(int current, int max) {
    return '$current/$max players';
  }

  @override
  String get minParticipantsLabel => 'Min Participants';

  @override
  String get maxParticipantsLabel => 'Max Participants';

  @override
  String get youAreOrganizing => 'You are organizing';

  @override
  String organizedBy(String name) {
    return 'Organized by $name';
  }

  @override
  String get scheduled => 'Scheduled';

  @override
  String get completed => 'Completed';

  @override
  String get noParticipantsYet => 'No participants yet';

  @override
  String get beFirstToJoin => 'Be the first to join!';

  @override
  String get participation => 'Participation';

  @override
  String get current => 'Current';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get availableSpots => 'Available Spots';

  @override
  String get you => 'You';

  @override
  String get joining => 'Joining...';

  @override
  String get leaving => 'Leaving...';

  @override
  String get cannotJoin => 'Cannot Join';

  @override
  String get allParticipantsNotified => 'All participants will be notified.';

  @override
  String get feedbackAlreadySubmitted => 'Feedback Already Submitted';

  @override
  String alreadyProvidedFeedback(String sessionTitle) {
    return 'You have already provided feedback for \"$sessionTitle\".';
  }

  @override
  String get provideAnonymousFeedback => 'Provide Anonymous Feedback';

  @override
  String get feedbackIsAnonymous =>
      'Your feedback is anonymous and helps improve future training sessions.';

  @override
  String get exercisesQuality => 'Exercises Quality';

  @override
  String get wereDrillsEffective => 'Were the drills effective?';

  @override
  String get trainingIntensity => 'Training Intensity';

  @override
  String get physicalDemandLevel => 'Physical demand level';

  @override
  String get coachingClarity => 'Coaching Clarity';

  @override
  String get instructionsAndCorrections => 'Instructions & corrections?';

  @override
  String get additionalCommentsOptional => 'Additional Comments (Optional)';

  @override
  String get shareYourThoughts =>
      'Share your thoughts about the session, exercises, or suggestions for improvement...';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get feedbackPrivacyNotice =>
      'Your feedback is completely anonymous and cannot be traced back to you.';

  @override
  String get invite => 'Invite';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String get adminOnly => 'Admin only';

  @override
  String get create => 'Create';

  @override
  String get createGameOrTraining => 'Create game or training session';

  @override
  String get activities => 'Activities';

  @override
  String get viewAllActivities => 'View all activities';

  @override
  String get removeFromGroup => 'Remove from Group';

  @override
  String promoteConfirmMessage(String name) {
    return 'Are you sure you want to promote $name to admin?\n\nAdmins can:\n• Manage group members\n• Invite new members\n• Modify group settings';
  }

  @override
  String demoteConfirmMessage(String name) {
    return 'Are you sure you want to demote $name to regular member?\n\nThey will lose admin privileges.';
  }

  @override
  String removeConfirmMessage(String name) {
    return 'Are you sure you want to remove $name from the group?\n\nThis action cannot be undone. They will need to be re-invited to rejoin.';
  }

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return 'Are you sure you want to leave \"$groupName\"?\n\nYou will need to be re-invited to rejoin this group.';
  }

  @override
  String get performanceStats => 'Performance Stats';

  @override
  String get eloRatingLabel => 'ELO Rating';

  @override
  String peak(String value) {
    return 'Peak: $value';
  }

  @override
  String get winRate => 'Win Rate';

  @override
  String winsLosses(int wins, int losses) {
    return '${wins}W - ${losses}L';
  }

  @override
  String get streakLabel => 'Streak';

  @override
  String get winning => 'Winning';

  @override
  String get losingStreak => 'Losing';

  @override
  String get noStreak => 'None';

  @override
  String get gamesPlayedLabel => 'Games Played';

  @override
  String get noPlayersAssigned => 'No players assigned';

  @override
  String get unassignedPlayers => 'Unassigned Players';

  @override
  String get allPlayersAssigned => 'All players assigned!';

  @override
  String get saveTeams => 'Save Teams';

  @override
  String get assignAllPlayersToContinue => 'Assign All Players to Continue';

  @override
  String invitedBy(String name) {
    return 'Invited by $name';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String participantsCount(int current, int max) {
    return '$current/$max participants';
  }

  @override
  String doYouWantToJoin(
    String sessionTitle,
    String dateTime,
    String location,
  ) {
    return 'Do you want to join \"$sessionTitle\"?\n\nDate: $dateTime\nLocation: $location';
  }

  @override
  String areYouSureLeave(String sessionTitle) {
    return 'Are you sure you want to leave \"$sessionTitle\"?';
  }

  @override
  String cancelSessionConfirm(String sessionTitle) {
    return 'Are you sure you want to cancel \"$sessionTitle\"?\n\nAll participants will be notified.';
  }

  @override
  String durationFormat(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get bestPartner => 'Best Partner';

  @override
  String get noPartnerDataYet => 'No partner data yet';

  @override
  String get playGamesWithTeammate => 'Play 5+ games with a teammate';

  @override
  String winRatePercent(String rate) {
    return '$rate% Win Rate';
  }

  @override
  String gamesCount(int count) {
    return '$count games';
  }

  @override
  String winsLossesGames(int wins, int losses, int total) {
    return '${wins}W - ${losses}L • $total games';
  }

  @override
  String get momentumAndConsistency => 'Momentum & Consistency';

  @override
  String get eloProgress => 'ELO Progress';

  @override
  String get winStreak => 'Win Streak';

  @override
  String get lossStreak => 'Loss Streak';

  @override
  String get noActiveStreak => 'No Active Streak';

  @override
  String get winNextGameToStartStreak =>
      'Win your next game to start a streak!';

  @override
  String get rival => 'Rival';

  @override
  String matchups(int count) {
    return '$count matchups';
  }

  @override
  String winRateLabel(String rate) {
    return 'Win Rate: $rate%';
  }

  @override
  String get tapForFullBreakdown => 'Tap for full breakdown';

  @override
  String get noNemesisYet => 'No Nemesis Yet';

  @override
  String get playGamesAgainstSameOpponent =>
      'Play at least 3 games against the same opponent to track your toughest matchup.';

  @override
  String get faceOpponentThreeTimes => 'Face the same opponent 3+ times';

  @override
  String get noPerformanceData => 'No Performance Data';

  @override
  String get playFirstGameToSeeStats =>
      'Play your first game to see your performance statistics!';

  @override
  String get playAtLeastOneGame => 'Play at least 1 game to unlock';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get currentElo => 'Current ELO';

  @override
  String get peakElo => 'Peak ELO';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get bestWin => 'Best Win';

  @override
  String get winGameToUnlock => 'Win a game to unlock';

  @override
  String get beatOpponentsToTrack =>
      'Beat opponents to track your best victory';

  @override
  String get avgPointDiff => 'Avg Point Diff';

  @override
  String get completeGameToUnlock => 'Complete a game to unlock';

  @override
  String get winAndLoseSetsToSee => 'Win and lose sets to see your margins';

  @override
  String get avgPointDifferential => 'Avg Point Differential';

  @override
  String get inWins => 'In Wins';

  @override
  String get inLosses => 'In Losses';

  @override
  String setsCount(int count) {
    return '$count sets';
  }

  @override
  String teamLabel(String names) {
    return 'Team: $names';
  }

  @override
  String teamEloLabel(String elo) {
    return 'Team ELO: $elo';
  }

  @override
  String eloGained(String amount) {
    return '$amount ELO gained';
  }

  @override
  String get adaptabilityStats => 'Adaptability Stats';

  @override
  String get advanced => 'Advanced';

  @override
  String get seeHowYouPerform => 'See how you perform in different team roles';

  @override
  String get leadingTheTeam => 'Leading the Team';

  @override
  String get whenHighestRated => 'When you\'re the highest-rated player';

  @override
  String get playingWithStrongerPartners => 'Playing with Stronger Partners';

  @override
  String get whenMoreExperiencedTeammates =>
      'When playing with more experienced teammates';

  @override
  String get balancedTeams => 'Balanced Teams';

  @override
  String get whenSimilarlyRatedTeammates =>
      'When playing with similarly-rated teammates';

  @override
  String get adaptabilityStatsLocked => 'Adaptability Stats Locked';

  @override
  String get playMoreGamesToSeeRoles =>
      'Play more games to see how you perform in different team roles';

  @override
  String get noStatsYet => 'No Stats Yet';

  @override
  String get startPlayingToSeeStats =>
      'Start playing games to see your statistics!';

  @override
  String get playGamesToUnlockRankings => 'Play games to unlock rankings';

  @override
  String get globalRank => 'Global Rank';

  @override
  String get percentile => 'Percentile';

  @override
  String get friendsRank => 'Friends Rank';

  @override
  String get addFriendsAction => 'Add friends';

  @override
  String get period30d => '30d';

  @override
  String get period90d => '90d';

  @override
  String get period1y => '1y';

  @override
  String get periodAllTime => 'All Time';

  @override
  String get monthlyProgressChart => 'Monthly Progress Chart';

  @override
  String playAtLeastNGames(int count) {
    return 'Play at least $count games';
  }

  @override
  String nOfNGames(int current, int total) {
    return '$current/$total games';
  }

  @override
  String get startPlayingToTrackProgress =>
      'Start playing to track your progress!';

  @override
  String get keepPlayingToUnlockChart => 'Keep playing to unlock this chart!';

  @override
  String get playGamesOverLongerPeriod => 'Play games over a longer period';

  @override
  String get keepPlayingToSeeProgress => 'Keep playing to see your progress!';

  @override
  String get noGamesInThisPeriod => 'No Games in This Period';

  @override
  String noGamesPlayedInLast(String period) {
    return 'No games played in the last $period';
  }

  @override
  String get trySelectingLongerPeriod => 'Try selecting a longer time period';

  @override
  String get periodLabel30Days => '30 days';

  @override
  String get periodLabel90Days => '90 days';

  @override
  String get periodLabelYear => 'year';

  @override
  String get periodLabelAllTime => 'all time';

  @override
  String get bestEloThisMonth => 'Best ELO This Month';

  @override
  String get bestEloPast90Days => 'Best ELO Past 90 Days';

  @override
  String get bestEloThisYear => 'Best ELO This Year';

  @override
  String get bestEloAllTime => 'Best ELO All Time';

  @override
  String lastNGames(int count) {
    return 'Last $count games';
  }

  @override
  String get noGamesPlayedYet => 'No games played yet';

  @override
  String winsStreakCount(int count) {
    return '$count wins';
  }

  @override
  String lossesStreakCount(int count) {
    return '$count losses';
  }

  @override
  String get partnerDetailsTitle => 'Partner Details';

  @override
  String get overallRecord => 'Overall Record';

  @override
  String get games => 'Games';

  @override
  String get record => 'Record';

  @override
  String get pointDifferential => 'Point Differential';

  @override
  String get avgPerGame => 'Avg Per Game';

  @override
  String get pointsFor => 'Points For';

  @override
  String get pointsAgainst => 'Points Against';

  @override
  String get eloPerformance => 'ELO Performance';

  @override
  String get totalChange => 'Total Change';

  @override
  String get recentForm => 'Recent Form';

  @override
  String streakWins(int count) {
    return '$count W Streak';
  }

  @override
  String streakLosses(int count) {
    return '$count L Streak';
  }

  @override
  String get noRecentGames => 'No recent games';

  @override
  String eloLabel(String value) {
    return 'ELO: $value';
  }

  @override
  String get nextGame => 'Next Game';

  @override
  String get noGamesScheduled => 'No games organized yet';

  @override
  String get nextTrainingSession => 'Next Training Session';

  @override
  String get noTrainingSessionsScheduled => 'No training sessions scheduled';

  @override
  String get stats => 'Stats';

  @override
  String get myStats => 'My Stats';

  @override
  String get generateInviteLink => 'Generate Invite Link';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get shareLink => 'Share';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get inviteLinkSectionTitle => 'Invite Members';

  @override
  String get inviteLinkDescription =>
      'Share this link to invite people to join the group.';

  @override
  String get revokeInvite => 'Revoke Invite';

  @override
  String get inviteRevoked => 'Invite link revoked';

  @override
  String get generateInviteError => 'Failed to generate invite link';

  @override
  String get revokeInviteError => 'Failed to revoke invite link';

  @override
  String inviteLinkShareMessage(String url) {
    return 'Join my group on PlayWithMe! $url';
  }

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get pageNotFoundMessage => 'The requested page could not be found.';
}
