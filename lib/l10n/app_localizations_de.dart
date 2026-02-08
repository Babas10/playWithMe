// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PlayWithMe';

  @override
  String get welcomeMessage => 'Willkommen bei PlayWithMe!';

  @override
  String get beachVolleyballOrganizer => 'Beachvolleyball-Spiele-Organisator';

  @override
  String get firebaseConnected => 'Verbunden';

  @override
  String get firebaseDisconnected => 'Getrennt';

  @override
  String get firebase => 'Firebase';

  @override
  String get environment => 'Umgebung';

  @override
  String get project => 'Projekt';

  @override
  String get loading => 'Laden...';

  @override
  String get profile => 'Profil';

  @override
  String get signOut => 'Abmelden';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get language => 'Sprache';

  @override
  String get country => 'Land';

  @override
  String get timezone => 'Zeitzone';

  @override
  String get saveChanges => 'Änderungen Speichern';

  @override
  String get settingsUpdatedSuccessfully =>
      'Einstellungen erfolgreich aktualisiert';

  @override
  String get removeAvatar => 'Avatar Entfernen';

  @override
  String get takePhoto => 'Foto Aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie Wählen';

  @override
  String get confirmRemoveAvatar =>
      'Möchten Sie Ihren Avatar wirklich entfernen?';

  @override
  String get remove => 'Entfernen';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get forgotPassword => 'Passwort Vergessen?';

  @override
  String get unsavedChangesTitle => 'Nicht Gespeicherte Änderungen';

  @override
  String get unsavedChangesMessage =>
      'Sie haben nicht gespeicherte Änderungen. Möchten Sie wirklich fortfahren?';

  @override
  String get discard => 'Verwerfen';

  @override
  String get displayNameHint => 'Geben Sie Ihren Anzeigenamen ein';

  @override
  String get preferredLanguage => 'Bevorzugte Sprache';

  @override
  String get saving => 'Speichern...';

  @override
  String get stay => 'Bleiben';

  @override
  String get accountInformation => 'Kontoinformationen';

  @override
  String get verify => 'Verifizieren';

  @override
  String get accountType => 'Kontotyp';

  @override
  String get anonymous => 'Anonym';

  @override
  String get regular => 'Normal';

  @override
  String get memberSince => 'Mitglied Seit';

  @override
  String get lastActive => 'Zuletzt Aktiv';

  @override
  String get signOutConfirm => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get pleaseLogIn => 'Bitte melden Sie sich an, um Ihr Profil zu sehen';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get myGroups => 'Meine Gruppen';

  @override
  String get pleaseLogInToViewGroups =>
      'Bitte melden Sie sich an, um Ihre Gruppen zu sehen';

  @override
  String get errorLoadingGroups => 'Fehler beim Laden der Gruppen';

  @override
  String get retry => 'Erneut Versuchen';

  @override
  String get createGroup => 'Gruppe Erstellen';

  @override
  String get groupDetailsComingSoon => 'Gruppenseite bald verfügbar!';

  @override
  String get noGroupsYet => 'Sie sind noch in keiner Gruppe';

  @override
  String get noGroupsMessage =>
      'Erstellen oder treten Sie Gruppen bei, um Beachvolleyball-Spiele mit Ihren Freunden zu organisieren!';

  @override
  String memberCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get publicGroup => 'Öffentlich';

  @override
  String get inviteOnlyGroup => 'Nur auf Einladung';

  @override
  String get privateGroup => 'Privat';

  @override
  String get createYourFirstGroup => 'Erstellen Sie Ihre Erste Gruppe';

  @override
  String get useCreateGroupButton =>
      'Verwenden Sie die Schaltfläche Gruppe Erstellen unten, um loszulegen.';

  @override
  String get home => 'Startseite';

  @override
  String get groups => 'Gruppen';

  @override
  String get community => 'Gemeinschaft';

  @override
  String get myCommunity => 'Meine Gemeinschaft';

  @override
  String get friends => 'Freunde';

  @override
  String get requests => 'Anfragen';

  @override
  String get noFriendsYet => 'Sie haben noch keine Freunde';

  @override
  String get searchForFriends => 'Suchen Sie nach Freunden, um loszulegen!';

  @override
  String get noPendingRequests => 'Keine ausstehenden Freundschaftsanfragen';

  @override
  String get receivedRequests => 'Empfangene Anfragen';

  @override
  String get sentRequests => 'Gesendete Anfragen';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get decline => 'Ablehnen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get removeFriend => 'Freund Entfernen?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Möchten Sie $name wirklich aus Ihrer Freundesliste entfernen?';
  }

  @override
  String get errorLoadingFriends => 'Fehler beim Laden der Freunde';

  @override
  String get searchFriendsByEmail => 'Freunde per E-Mail suchen...';

  @override
  String get cannotAddYourself =>
      'Sie können sich nicht selbst als Freund hinzufügen';

  @override
  String userNotFoundWithEmail(String email) {
    return 'Kein Benutzer mit der E-Mail gefunden: $email';
  }

  @override
  String get makeSureEmailCorrect =>
      'Stellen Sie sicher, dass die E-Mail korrekt ist';

  @override
  String get requestPending => 'Ausstehend';

  @override
  String get acceptRequest => 'Anfrage Akzeptieren';

  @override
  String get sendFriendRequest => 'Hinzufügen';

  @override
  String get search => 'Suchen';

  @override
  String get addFriend => 'Freund Hinzufügen';

  @override
  String get searchForFriendsToAdd => 'Suche nach Freunden zum Hinzufügen';

  @override
  String get enterEmailToFindFriends =>
      'Geben Sie eine E-Mail-Adresse ein, um Benutzer zu finden';

  @override
  String get checkRequestsTab =>
      'Überprüfen Sie die Registerkarte Anfragen, um die Freundschaftsanfrage anzunehmen';

  @override
  String get ok => 'OK';

  @override
  String get dontHaveAccount => 'Kein Konto? ';

  @override
  String get signUp => 'Registrieren';

  @override
  String get resetPassword => 'Passwort Zurücksetzen';

  @override
  String get backToLogin => 'Zurück zur Anmeldung';

  @override
  String get emailSent => 'E-Mail Gesendet!';

  @override
  String get createAccount => 'Konto Erstellen';

  @override
  String get accountCreatedSuccess =>
      'Konto erfolgreich erstellt! Bitte überprüfen Sie Ihre E-Mail.';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto? ';

  @override
  String get signIn => 'Anmelden';

  @override
  String get emailHint => 'E-Mail';

  @override
  String get passwordHint => 'Passwort';

  @override
  String get displayNameOptionalHint => 'Anzeigename (Optional)';

  @override
  String get confirmPassword => 'Passwort Bestätigen';

  @override
  String get createGame => 'Spiel Erstellen';

  @override
  String get gameCreatedSuccess => 'Spiel erfolgreich erstellt!';

  @override
  String get pleaseLogInToCreateGame =>
      'Bitte melden Sie sich an, um ein Spiel zu erstellen';

  @override
  String get group => 'Gruppe';

  @override
  String get dateTime => 'Datum & Uhrzeit';

  @override
  String get tapToSelect => 'Tippen zum Auswählen';

  @override
  String get gameDetails => 'Spieldetails';

  @override
  String get goBack => 'Zurück';

  @override
  String get organizer => 'Organisator';

  @override
  String get enterResults => 'Ergebnisse Eingeben';

  @override
  String get leaveGame => 'Spiel Verlassen';

  @override
  String get leaveWaitlist => 'Warteliste Verlassen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get editDispute => 'Bearbeiten / Anfechten';

  @override
  String get filterGames => 'Spiele Filtern';

  @override
  String get allGames => 'Alle Spiele';

  @override
  String get myGamesOnly => 'Nur Meine Spiele';

  @override
  String get gameHistory => 'Spielverlauf';

  @override
  String get selectFiltersToView =>
      'Filter auswählen, um den Verlauf anzuzeigen';

  @override
  String get activeFilters => 'Aktive Filter: ';

  @override
  String get myGames => 'Meine Spiele';

  @override
  String get gameResults => 'Spielergebnisse';

  @override
  String groupNameGames(String groupName) {
    return '$groupName Spiele';
  }

  @override
  String get recordResults => 'Ergebnisse Aufzeichnen';

  @override
  String get teamsSavedSuccess => 'Teams erfolgreich gespeichert';

  @override
  String get teamA => 'Team A';

  @override
  String get teamB => 'Team B';

  @override
  String get enterScores => 'Punkte Eingeben';

  @override
  String get scoresSavedSuccess => 'Punkte erfolgreich gespeichert!';

  @override
  String get savingScores => 'Punkte werden gespeichert...';

  @override
  String get oneSet => '1 Satz';

  @override
  String get bestOfTwo => 'Best of 2';

  @override
  String get bestOfThree => 'Best of 3';

  @override
  String get gameTitle => 'Spieltitel';

  @override
  String get gameTitleHint => 'z.B. Beachvolleyball';

  @override
  String get descriptionOptional => 'Beschreibung (Optional)';

  @override
  String get gameDescriptionHint => 'Details zum Spiel hinzufügen...';

  @override
  String get location => 'Ort';

  @override
  String get locationHint => 'z.B. Strandpromenade';

  @override
  String get addressOptional => 'Adresse (Optional)';

  @override
  String get addressHint => 'Vollständige Adresse...';

  @override
  String get filter => 'Filter';

  @override
  String get dateRange => 'Datumsbereich';

  @override
  String get removeFromTeam => 'Aus Team entfernen';

  @override
  String get clearFilter => 'Filter löschen';

  @override
  String get filterByDate => 'Nach Datum filtern';

  @override
  String get groupNameRequired => 'Gruppenname *';

  @override
  String get groupNameHint => 'z.B. Beachvolley Team';

  @override
  String get groupDescriptionHint => 'z.B. Wöchentliche Beachvolleyball-Spiele';

  @override
  String get pleaseSelectStartTimeFirst =>
      'Bitte wählen Sie zuerst die Startzeit';

  @override
  String get pleaseSelectStartTime => 'Bitte wählen Sie die Startzeit';

  @override
  String get pleaseSelectEndTime => 'Bitte wählen Sie die Endzeit';

  @override
  String get trainingCreatedSuccess => 'Training erfolgreich erstellt!';

  @override
  String get createTrainingSession => 'Training Erstellen';

  @override
  String get pleaseLogInToCreateTraining =>
      'Bitte melden Sie sich an, um ein Training zu erstellen';

  @override
  String get startTime => 'Startzeit';

  @override
  String get endTime => 'Endzeit';

  @override
  String get title => 'Titel';

  @override
  String get trainingSession => 'Training';

  @override
  String get trainingNotFound => 'Training nicht gefunden';

  @override
  String get trainingCancelled => 'Training abgesagt';

  @override
  String get errorLoadingParticipants => 'Fehler beim Laden der Teilnehmer';

  @override
  String get joinedTrainingSuccess => 'Training erfolgreich beigetreten!';

  @override
  String get leftTraining => 'Sie haben das Training verlassen';

  @override
  String get joinTrainingSession => 'Training Beitreten';

  @override
  String get join => 'Beitreten';

  @override
  String get leaveTrainingSession => 'Training Verlassen';

  @override
  String get leave => 'Verlassen';

  @override
  String get cancelTrainingSession => 'Training Absagen?';

  @override
  String get keepSession => 'Training Behalten';

  @override
  String get cancelSession => 'Training Absagen';

  @override
  String get sessionFeedback => 'Training-Feedback';

  @override
  String get thankYouFeedback => 'Danke für Ihr Feedback!';

  @override
  String get backToSession => 'Zurück zum Training';

  @override
  String get needsWork => 'Verbesserungswürdig';

  @override
  String get topLevelTraining => 'Spitzentraining';

  @override
  String get pleaseRateAllCategories =>
      'Bitte bewerten Sie alle drei Kategorien';

  @override
  String get emailVerification => 'E-Mail Verifizierung';

  @override
  String verificationEmailSent(String email) {
    return 'Bestätigungs-E-Mail an $email gesendet';
  }

  @override
  String get backToProfile => 'Zurück zum Profil';

  @override
  String get sendVerificationEmail => 'Bestätigungs-E-Mail Senden';

  @override
  String get refreshStatus => 'Status Aktualisieren';

  @override
  String get tryAgain => 'Erneut Versuchen';

  @override
  String get eloHistory => 'ELO-Verlauf';

  @override
  String get gameDetailsComingSoon => 'Spieldetails bald verfügbar!';

  @override
  String get headToHead => 'Direktvergleich';

  @override
  String get partnerDetails => 'Partnerdetails';

  @override
  String get invitations => 'Einladungen';

  @override
  String get pleaseLogInToViewInvitations =>
      'Bitte melden Sie sich an, um Einladungen zu sehen';

  @override
  String get pendingInvitations => 'Ausstehende Einladungen';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get initializing => 'Initialisierung...';

  @override
  String get groupInvitations => 'Gruppeneinladungen';

  @override
  String get groupInvitationsDesc => 'Wenn Sie jemand in eine Gruppe einlädt';

  @override
  String get invitationAccepted => 'Einladung Angenommen';

  @override
  String get invitationAcceptedDesc => 'Wenn jemand Ihre Einladung annimmt';

  @override
  String get newGames => 'Neue Spiele';

  @override
  String get newGamesDesc =>
      'Wenn ein neues Spiel in Ihren Gruppen erstellt wird';

  @override
  String get roleChanges => 'Rollenänderungen';

  @override
  String get roleChangesDesc => 'Wenn Sie zum Admin befördert werden';

  @override
  String get newTrainingSessions => 'Neue Trainings';

  @override
  String get newTrainingSessionsDesc =>
      'Wenn ein Training in Ihren Gruppen erstellt wird';

  @override
  String get minParticipantsReached => 'Mindestteilnehmerzahl Erreicht';

  @override
  String get minParticipantsReachedDesc =>
      'Wenn ein Training genug Teilnehmer hat';

  @override
  String get feedbackReceived => 'Feedback Erhalten';

  @override
  String get feedbackReceivedDesc =>
      'Wenn jemand Feedback zu einem Training gibt';

  @override
  String get sessionCancelled => 'Training Abgesagt';

  @override
  String get sessionCancelledDesc =>
      'Wenn ein Training, dem Sie beigetreten sind, abgesagt wird';

  @override
  String get memberJoined => 'Mitglied Beigetreten';

  @override
  String get memberJoinedDesc => 'Wenn jemand Ihrer Gruppe beitritt';

  @override
  String get memberLeft => 'Mitglied Verlassen';

  @override
  String get memberLeftDesc => 'Wenn jemand Ihre Gruppe verlässt';

  @override
  String get enableQuietHours => 'Ruhezeiten Aktivieren';

  @override
  String get quietHoursDesc =>
      'Benachrichtigungen zu bestimmten Zeiten pausieren';

  @override
  String get adjustQuietHours => 'Ruhezeiten Anpassen';

  @override
  String get setQuietHours => 'Ruhezeiten Festlegen';

  @override
  String error(String message) {
    return 'Fehler: $message';
  }

  @override
  String get pleaseLogInToAddFriends =>
      'Bitte melden Sie sich an, um Freunde hinzuzufügen';

  @override
  String get welcomeBack => 'Willkommen Zurück!';

  @override
  String get signInToContinue =>
      'Melden Sie sich an, um Ihre Volleyball-Spiele zu organisieren';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get validEmailRequired => 'Bitte geben Sie eine gültige E-Mail ein';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get continueAsGuest => 'Als Gast Fortfahren';

  @override
  String get joinPlayWithMe => 'PlayWithMe Beitreten!';

  @override
  String get createAccountSubtitle =>
      'Erstellen Sie Ihr Konto, um Volleyball-Spiele zu organisieren';

  @override
  String get displayNameTooLong =>
      'Der Anzeigename muss weniger als 50 Zeichen haben';

  @override
  String get passwordTooShort => 'Das Passwort muss mindestens 6 Zeichen haben';

  @override
  String get pleaseConfirmPassword => 'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get termsAgreement =>
      'Mit der Erstellung eines Kontos stimmen Sie unseren Nutzungsbedingungen und Datenschutzrichtlinien zu.';

  @override
  String get forgotYourPassword => 'Passwort Vergessen?';

  @override
  String get forgotPasswordInstructions =>
      'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen des Passworts.';

  @override
  String get sendResetEmail => 'Reset-E-Mail Senden';

  @override
  String get resetLinkSentTo =>
      'Wir haben einen Link zum Zurücksetzen gesendet an:';

  @override
  String get checkEmailResetInstructions =>
      'Bitte überprüfen Sie Ihre E-Mail und folgen Sie den Anweisungen zum Zurücksetzen.';

  @override
  String get noResultsAvailable => 'Noch keine Ergebnisse verfügbar';

  @override
  String get scoresWillAppear =>
      'Punkte werden hier angezeigt, sobald sie eingegeben wurden';

  @override
  String get individualGames => 'Einzelspiele';

  @override
  String get howManyGamesPlayed => 'Wie viele Spiele haben Sie gespielt?';

  @override
  String get assignPlayersToTeams => 'Spieler den Teams Zuweisen';

  @override
  String get dragPlayersToAssign =>
      'Ziehen Sie Spieler, um sie Team A oder B zuzuweisen';

  @override
  String get pendingVerification => 'Überprüfung Ausstehend';

  @override
  String get youreIn => 'Sie sind dabei';

  @override
  String get onWaitlist => 'Auf Warteliste';

  @override
  String get full => 'Voll';

  @override
  String get joinGame => 'Spiel Beitreten';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get player => 'Spieler';

  @override
  String get noScoresRecorded => 'Keine Punkte aufgezeichnet';

  @override
  String get eloUpdated => 'ELO Aktualisiert';

  @override
  String get vs => 'VS';

  @override
  String get cancelled => 'ABGESAGT';

  @override
  String get joined => 'BEIGETRETEN';

  @override
  String get training => 'Training';

  @override
  String get gameLabel => 'SPIEL';

  @override
  String minParticipants(int count) {
    return 'Min: $count';
  }

  @override
  String get selectGameDate => 'Spieldatum Auswählen';

  @override
  String get selectGameTime => 'Spielzeit Auswählen';

  @override
  String get pleaseTitleRequired => 'Bitte geben Sie einen Spieltitel ein';

  @override
  String get titleMinLength => 'Der Titel muss mindestens 3 Zeichen haben';

  @override
  String get titleMaxLength => 'Der Titel muss weniger als 100 Zeichen haben';

  @override
  String get pleaseEnterTitle => 'Bitte geben Sie einen Titel ein';

  @override
  String get pleaseEnterLocation => 'Bitte geben Sie einen Ort ein';

  @override
  String get notSelected => 'Nicht ausgewählt';

  @override
  String get selectStartDate => 'Startdatum Auswählen';

  @override
  String get selectStartTime => 'Startzeit Auswählen';

  @override
  String get selectEndTime => 'Endzeit Auswählen';

  @override
  String get participants => 'Teilnehmer';

  @override
  String get exercises => 'Übungen';

  @override
  String get feedback => 'Feedback';

  @override
  String get date => 'Datum';

  @override
  String get time => 'Uhrzeit';

  @override
  String get players => 'Spieler';

  @override
  String get competitiveGameWithElo => 'Wettkampfspiel mit ELO-Wertung';

  @override
  String get practiceSessionNoElo => 'Übungseinheit ohne ELO-Auswirkung';

  @override
  String get promoteToAdmin => 'Zum Admin Befördern';

  @override
  String get promote => 'Befördern';

  @override
  String get demoteToMember => 'Zum Mitglied Zurückstufen';

  @override
  String get demote => 'Zurückstufen';

  @override
  String get removeMember => 'Mitglied Entfernen';

  @override
  String get leaveGroup => 'Gruppe Verlassen';

  @override
  String get selectAll => 'Alle Auswählen';

  @override
  String get clearAll => 'Alle Löschen';

  @override
  String get upload => 'Hochladen';

  @override
  String get avatarUploadedSuccess => 'Avatar erfolgreich hochgeladen';

  @override
  String get avatarRemovedSuccess => 'Avatar erfolgreich entfernt';

  @override
  String get bestTeammate => 'Bester Teamkollege';

  @override
  String get gameNotFound => 'Spiel Nicht Gefunden';

  @override
  String get noCompletedGamesYet => 'Noch keine abgeschlossenen Spiele';

  @override
  String get gamesWillAppearAfterCompleted =>
      'Spiele erscheinen hier nach Abschluss';

  @override
  String get finalScore => 'Endstand';

  @override
  String get eloRatingChanges => 'ELO-Wertungsänderungen';

  @override
  String get unknownPlayer => 'Unbekannter Spieler';

  @override
  String gameNumber(int number) {
    return 'Spiel $number';
  }

  @override
  String setsScore(int teamA, int teamB) {
    return 'Sätze: $teamA - $teamB';
  }

  @override
  String setNumber(int number) {
    return 'Satz $number';
  }

  @override
  String get format => 'Format:';

  @override
  String get invalidScore => 'Ungültiger Punktestand';

  @override
  String get overallWinnerTeamA => 'Gesamtsieger: Team A';

  @override
  String get overallWinnerTeamB => 'Gesamtsieger: Team B';

  @override
  String get saveScores => 'Punkte Speichern';

  @override
  String completeGamesToContinue(int current, int total) {
    return 'Beenden Sie $current/$total Spiele zum Fortfahren';
  }

  @override
  String get upcomingActivities => 'Kommende Aktivitäten';

  @override
  String get pastActivities => 'Vergangene Aktivitäten';

  @override
  String get noUpcomingGamesYet => 'Noch keine kommenden Spiele';

  @override
  String get createFirstGame => 'Erstellen Sie das erste Spiel!';

  @override
  String get noActivitiesYet => 'Noch keine Aktivitäten';

  @override
  String get createFirstActivity => 'Erstellen Sie die erste Aktivität!';

  @override
  String get gamesWon => 'Spiele gewonnen';

  @override
  String get playerCountSingular => '1 Spieler';

  @override
  String playerCountPlural(int count) {
    return '$count Spieler';
  }

  @override
  String wonScoreDescription(String winner, String score) {
    return '$winner gewann $score';
  }

  @override
  String playersWaitlisted(int count) {
    return '$count auf Warteliste';
  }

  @override
  String playersCount(int current, int max) {
    return '$current/$max Spieler';
  }

  @override
  String get minParticipantsLabel => 'Min Teilnehmer';

  @override
  String get maxParticipantsLabel => 'Max Teilnehmer';

  @override
  String get youAreOrganizing => 'Sie organisieren';

  @override
  String organizedBy(String name) {
    return 'Organisiert von $name';
  }

  @override
  String get scheduled => 'Geplant';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get noParticipantsYet => 'Noch keine Teilnehmer';

  @override
  String get beFirstToJoin => 'Seien Sie der Erste, der beitritt!';

  @override
  String get participation => 'Teilnahme';

  @override
  String get current => 'Aktuell';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get availableSpots => 'Verfügbare Plätze';

  @override
  String get you => 'Sie';

  @override
  String get joining => 'Beitritt...';

  @override
  String get leaving => 'Verlassen...';

  @override
  String get cannotJoin => 'Beitritt nicht möglich';

  @override
  String get allParticipantsNotified =>
      'Alle Teilnehmer werden benachrichtigt.';

  @override
  String get feedbackAlreadySubmitted => 'Feedback Bereits Eingereicht';

  @override
  String alreadyProvidedFeedback(String sessionTitle) {
    return 'Sie haben bereits Feedback für \"$sessionTitle\" abgegeben.';
  }

  @override
  String get provideAnonymousFeedback => 'Anonymes Feedback Geben';

  @override
  String get feedbackIsAnonymous =>
      'Ihr Feedback ist anonym und hilft, zukünftige Trainings zu verbessern.';

  @override
  String get exercisesQuality => 'Übungsqualität';

  @override
  String get wereDrillsEffective => 'Waren die Übungen effektiv?';

  @override
  String get trainingIntensity => 'Trainingsintensität';

  @override
  String get physicalDemandLevel => 'Körperliche Anforderung';

  @override
  String get coachingClarity => 'Coaching-Klarheit';

  @override
  String get instructionsAndCorrections => 'Anweisungen und Korrekturen?';

  @override
  String get additionalCommentsOptional => 'Zusätzliche Kommentare (Optional)';

  @override
  String get shareYourThoughts =>
      'Teilen Sie Ihre Gedanken über das Training, die Übungen oder Verbesserungsvorschläge...';

  @override
  String get submitFeedback => 'Feedback Absenden';

  @override
  String get feedbackPrivacyNotice =>
      'Ihr Feedback ist vollständig anonym und kann nicht zu Ihnen zurückverfolgt werden.';

  @override
  String get invite => 'Einladen';

  @override
  String get inviteMembers => 'Mitglieder Einladen';

  @override
  String get adminOnly => 'Nur für Admins';

  @override
  String get create => 'Erstellen';

  @override
  String get createGameOrTraining => 'Spiel oder Training erstellen';

  @override
  String get activities => 'Aktivitäten';

  @override
  String get viewAllActivities => 'Alle Aktivitäten anzeigen';

  @override
  String get removeFromGroup => 'Aus Gruppe Entfernen';

  @override
  String promoteConfirmMessage(String name) {
    return 'Möchten Sie $name wirklich zum Admin befördern?\n\nAdmins können:\n• Gruppenmitglieder verwalten\n• Neue Mitglieder einladen\n• Gruppeneinstellungen ändern';
  }

  @override
  String demoteConfirmMessage(String name) {
    return 'Möchten Sie $name wirklich zum normalen Mitglied zurückstufen?\n\nEr verliert seine Admin-Rechte.';
  }

  @override
  String removeConfirmMessage(String name) {
    return 'Möchten Sie $name wirklich aus der Gruppe entfernen?\n\nDiese Aktion kann nicht rückgängig gemacht werden. Er muss erneut eingeladen werden.';
  }

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return 'Möchten Sie \"$groupName\" wirklich verlassen?\n\nSie müssen erneut eingeladen werden, um dieser Gruppe beizutreten.';
  }

  @override
  String get performanceStats => 'Leistungsstatistiken';

  @override
  String get eloRatingLabel => 'ELO-Wertung';

  @override
  String peak(String value) {
    return 'Höchstwert: $value';
  }

  @override
  String get winRate => 'Siegquote';

  @override
  String winsLosses(int wins, int losses) {
    return '${wins}S - ${losses}N';
  }

  @override
  String get streakLabel => 'Serie';

  @override
  String get winning => 'Gewinne';

  @override
  String get losingStreak => 'Niederlagen';

  @override
  String get noStreak => 'Keine';

  @override
  String get gamesPlayedLabel => 'Gespielte Spiele';

  @override
  String get noPlayersAssigned => 'Keine Spieler zugewiesen';

  @override
  String get unassignedPlayers => 'Nicht Zugewiesene Spieler';

  @override
  String get allPlayersAssigned => 'Alle Spieler zugewiesen!';

  @override
  String get saveTeams => 'Teams Speichern';

  @override
  String get assignAllPlayersToContinue =>
      'Alle Spieler zuweisen zum Fortfahren';

  @override
  String invitedBy(String name) {
    return 'Eingeladen von $name';
  }

  @override
  String get errorTitle => 'Fehler';

  @override
  String participantsCount(int current, int max) {
    return '$current/$max Teilnehmer';
  }

  @override
  String doYouWantToJoin(
    String sessionTitle,
    String dateTime,
    String location,
  ) {
    return 'Möchten Sie \"$sessionTitle\" beitreten?\n\nDatum: $dateTime\nOrt: $location';
  }

  @override
  String areYouSureLeave(String sessionTitle) {
    return 'Möchten Sie \"$sessionTitle\" wirklich verlassen?';
  }

  @override
  String cancelSessionConfirm(String sessionTitle) {
    return 'Möchten Sie \"$sessionTitle\" wirklich absagen?\n\nAlle Teilnehmer werden benachrichtigt.';
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
  String get bestPartner => 'Bester Partner';

  @override
  String get noPartnerDataYet => 'Noch keine Partnerdaten';

  @override
  String get playGamesWithTeammate =>
      'Spielen Sie 5+ Spiele mit einem Teamkollegen';

  @override
  String winRatePercent(String rate) {
    return '$rate% Siegquote';
  }

  @override
  String gamesCount(int count) {
    return '$count Spiele';
  }

  @override
  String winsLossesGames(int wins, int losses, int total) {
    return '${wins}S - ${losses}N • $total Spiele';
  }

  @override
  String get momentumAndConsistency => 'Momentum & Konstanz';

  @override
  String get eloProgress => 'ELO-Fortschritt';

  @override
  String get winStreak => 'Siegesserie';

  @override
  String get lossStreak => 'Niederlagenserie';

  @override
  String get noActiveStreak => 'Keine aktive Serie';

  @override
  String get winNextGameToStartStreak =>
      'Gewinnen Sie Ihr nächstes Spiel, um eine Serie zu starten!';

  @override
  String get rival => 'Rivale';

  @override
  String matchups(int count) {
    return '$count Begegnungen';
  }

  @override
  String winRateLabel(String rate) {
    return 'Siegquote: $rate%';
  }

  @override
  String get tapForFullBreakdown => 'Tippen für Details';

  @override
  String get noNemesisYet => 'Noch kein Erzfeind';

  @override
  String get playGamesAgainstSameOpponent =>
      'Spielen Sie mindestens 3 Spiele gegen denselben Gegner, um Ihre härteste Begegnung zu verfolgen.';

  @override
  String get faceOpponentThreeTimes =>
      'Treffen Sie 3+ Mal auf denselben Gegner';

  @override
  String get noPerformanceData => 'Keine Leistungsdaten';

  @override
  String get playFirstGameToSeeStats =>
      'Spielen Sie Ihr erstes Spiel, um Ihre Statistiken zu sehen!';

  @override
  String get playAtLeastOneGame =>
      'Spielen Sie mindestens 1 Spiel zum Freischalten';

  @override
  String get performanceOverview => 'Leistungsübersicht';

  @override
  String get currentElo => 'Aktuelles ELO';

  @override
  String get peakElo => 'Höchstes ELO';

  @override
  String get gamesPlayed => 'Gespielte Spiele';

  @override
  String get bestWin => 'Bester Sieg';

  @override
  String get winGameToUnlock => 'Gewinnen Sie ein Spiel zum Freischalten';

  @override
  String get beatOpponentsToTrack =>
      'Besiegen Sie Gegner, um Ihre besten Siege zu verfolgen';

  @override
  String get avgPointDiff => 'Durchschn. Punktediff.';

  @override
  String get completeGameToUnlock => 'Beenden Sie ein Spiel zum Freischalten';

  @override
  String get winAndLoseSetsToSee =>
      'Gewinnen und verlieren Sie Sätze, um Ihre Margen zu sehen';

  @override
  String get avgPointDifferential => 'Durchschnittliche Punktedifferenz';

  @override
  String get inWins => 'Bei Siegen';

  @override
  String get inLosses => 'Bei Niederlagen';

  @override
  String setsCount(int count) {
    return '$count Sätze';
  }

  @override
  String teamLabel(String names) {
    return 'Team: $names';
  }

  @override
  String teamEloLabel(String elo) {
    return 'Team-ELO: $elo';
  }

  @override
  String eloGained(String amount) {
    return '$amount ELO gewonnen';
  }

  @override
  String get adaptabilityStats => 'Anpassungsfähigkeits-Stats';

  @override
  String get advanced => 'Erweitert';

  @override
  String get seeHowYouPerform =>
      'Sehen Sie, wie Sie in verschiedenen Teamrollen abschneiden';

  @override
  String get leadingTheTeam => 'Team anführen';

  @override
  String get whenHighestRated => 'Wenn Sie der bestbewertete Spieler sind';

  @override
  String get playingWithStrongerPartners => 'Mit stärkeren Partnern spielen';

  @override
  String get whenMoreExperiencedTeammates =>
      'Wenn Sie mit erfahreneren Teamkollegen spielen';

  @override
  String get balancedTeams => 'Ausgeglichene Teams';

  @override
  String get whenSimilarlyRatedTeammates =>
      'Wenn Sie mit ähnlich bewerteten Teamkollegen spielen';

  @override
  String get adaptabilityStatsLocked => 'Anpassungsfähigkeits-Stats gesperrt';

  @override
  String get playMoreGamesToSeeRoles =>
      'Spielen Sie mehr Spiele, um zu sehen, wie Sie in verschiedenen Rollen abschneiden';

  @override
  String get noStatsYet => 'Noch keine Stats';

  @override
  String get startPlayingToSeeStats =>
      'Beginnen Sie zu spielen, um Ihre Statistiken zu sehen!';

  @override
  String get playGamesToUnlockRankings =>
      'Spielen Sie, um Ranglisten freizuschalten';

  @override
  String get globalRank => 'Globaler Rang';

  @override
  String get percentile => 'Perzentil';

  @override
  String get friendsRank => 'Freunde Rang';

  @override
  String get addFriendsAction => 'Freunde hinzufügen';

  @override
  String get period30d => '30T';

  @override
  String get period90d => '90T';

  @override
  String get period1y => '1J';

  @override
  String get periodAllTime => 'Gesamt';

  @override
  String get monthlyProgressChart => 'Monatlicher Fortschritt';

  @override
  String playAtLeastNGames(int count) {
    return 'Spielen Sie mindestens $count Spiele';
  }

  @override
  String nOfNGames(int current, int total) {
    return '$current/$total Spiele';
  }

  @override
  String get startPlayingToTrackProgress =>
      'Beginnen Sie zu spielen, um Ihren Fortschritt zu verfolgen!';

  @override
  String get keepPlayingToUnlockChart =>
      'Spielen Sie weiter, um dieses Diagramm freizuschalten!';

  @override
  String get playGamesOverLongerPeriod =>
      'Spielen Sie über einen längeren Zeitraum';

  @override
  String get keepPlayingToSeeProgress =>
      'Spielen Sie weiter, um Ihren Fortschritt zu sehen!';

  @override
  String get noGamesInThisPeriod => 'Keine Spiele in diesem Zeitraum';

  @override
  String noGamesPlayedInLast(String period) {
    return 'Keine Spiele in den letzten $period';
  }

  @override
  String get trySelectingLongerPeriod =>
      'Versuchen Sie, einen längeren Zeitraum auszuwählen';

  @override
  String get periodLabel30Days => '30 Tagen';

  @override
  String get periodLabel90Days => '90 Tagen';

  @override
  String get periodLabelYear => 'Jahr';

  @override
  String get periodLabelAllTime => 'Gesamtzeit';

  @override
  String get bestEloThisMonth => 'Bestes ELO diesen Monat';

  @override
  String get bestEloPast90Days => 'Bestes ELO letzte 90 Tage';

  @override
  String get bestEloThisYear => 'Bestes ELO dieses Jahr';

  @override
  String get bestEloAllTime => 'Bestes ELO aller Zeiten';

  @override
  String lastNGames(int count) {
    return 'Letzte $count Spiele';
  }

  @override
  String get noGamesPlayedYet => 'Noch keine Spiele gespielt';

  @override
  String winsStreakCount(int count) {
    return '$count Siege';
  }

  @override
  String lossesStreakCount(int count) {
    return '$count Niederlagen';
  }

  @override
  String get partnerDetailsTitle => 'Partner Details';

  @override
  String get overallRecord => 'Gesamtbilanz';

  @override
  String get games => 'Spiele';

  @override
  String get record => 'Bilanz';

  @override
  String get pointDifferential => 'Punktedifferenz';

  @override
  String get avgPerGame => 'Durchschn. pro Spiel';

  @override
  String get pointsFor => 'Punkte erzielt';

  @override
  String get pointsAgainst => 'Punkte kassiert';

  @override
  String get eloPerformance => 'ELO Leistung';

  @override
  String get totalChange => 'Gesamtänderung';

  @override
  String get recentForm => 'Aktuelle Form';

  @override
  String streakWins(int count) {
    return '$count S Serie';
  }

  @override
  String streakLosses(int count) {
    return '$count N Serie';
  }

  @override
  String get noRecentGames => 'Keine aktuellen Spiele';

  @override
  String eloLabel(String value) {
    return 'ELO: $value';
  }

  @override
  String get nextGame => 'Nächstes Spiel';

  @override
  String get noGamesScheduled => 'Noch keine Spiele organisiert';

  @override
  String get nextTrainingSession => 'Nächste Trainingseinheit';

  @override
  String get noTrainingSessionsScheduled => 'Keine Trainingseinheiten geplant';
}
