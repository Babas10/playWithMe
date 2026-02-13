// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PlayWithMe';

  @override
  String get welcomeMessage => 'Benvenuto su PlayWithMe!';

  @override
  String get beachVolleyballOrganizer =>
      'Organizzatore di partite di beach volley';

  @override
  String get firebaseConnected => 'Connesso';

  @override
  String get firebaseDisconnected => 'Disconnesso';

  @override
  String get firebase => 'Firebase';

  @override
  String get environment => 'Ambiente';

  @override
  String get project => 'Progetto';

  @override
  String get loading => 'Caricamento...';

  @override
  String get profile => 'Profilo';

  @override
  String get signOut => 'Disconnetti';

  @override
  String get accountSettings => 'Impostazioni Account';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get displayName => 'Nome Visualizzato';

  @override
  String get language => 'Lingua';

  @override
  String get country => 'Paese';

  @override
  String get timezone => 'Fuso Orario';

  @override
  String get saveChanges => 'Salva Modifiche';

  @override
  String get settingsUpdatedSuccessfully =>
      'Impostazioni aggiornate con successo';

  @override
  String get removeAvatar => 'Rimuovi Avatar';

  @override
  String get takePhoto => 'Scatta Foto';

  @override
  String get chooseFromGallery => 'Scegli dalla Galleria';

  @override
  String get confirmRemoveAvatar =>
      'Sei sicuro di voler rimuovere il tuo avatar?';

  @override
  String get remove => 'Rimuovi';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Registrati';

  @override
  String get forgotPassword => 'Password Dimenticata?';

  @override
  String get unsavedChangesTitle => 'Modifiche Non Salvate';

  @override
  String get unsavedChangesMessage =>
      'Hai modifiche non salvate. Sei sicuro di voler uscire?';

  @override
  String get discard => 'Scarta';

  @override
  String get displayNameHint => 'Inserisci il tuo nome visualizzato';

  @override
  String get preferredLanguage => 'Lingua Preferita';

  @override
  String get saving => 'Salvataggio...';

  @override
  String get stay => 'Rimani';

  @override
  String get accountInformation => 'Informazioni Account';

  @override
  String get verify => 'Verifica';

  @override
  String get accountType => 'Tipo di Account';

  @override
  String get anonymous => 'Anonimo';

  @override
  String get regular => 'Normale';

  @override
  String get memberSince => 'Membro Dal';

  @override
  String get lastActive => 'Ultima Attività';

  @override
  String get signOutConfirm => 'Sei sicuro di voler disconnetterti?';

  @override
  String get pleaseLogIn =>
      'Effettua l\'accesso per visualizzare il tuo profilo';

  @override
  String get userId => 'ID Utente';

  @override
  String get myGroups => 'I Miei Gruppi';

  @override
  String get pleaseLogInToViewGroups =>
      'Effettua l\'accesso per visualizzare i tuoi gruppi';

  @override
  String get errorLoadingGroups => 'Errore nel Caricamento dei Gruppi';

  @override
  String get retry => 'Riprova';

  @override
  String get createGroup => 'Crea Gruppo';

  @override
  String get groupDetailsComingSoon =>
      'Pagina dei dettagli del gruppo in arrivo!';

  @override
  String get noGroupsYet => 'Non fai ancora parte di nessun gruppo';

  @override
  String get noGroupsMessage =>
      'Crea o unisciti a gruppi per iniziare a organizzare partite di beach volley con i tuoi amici!';

  @override
  String memberCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString membri',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get publicGroup => 'Pubblico';

  @override
  String get inviteOnlyGroup => 'Solo su Invito';

  @override
  String get privateGroup => 'Privato';

  @override
  String get createYourFirstGroup => 'Crea Il Tuo Primo Gruppo';

  @override
  String get useCreateGroupButton =>
      'Usa il pulsante Crea Gruppo qui sotto per iniziare.';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Gruppi';

  @override
  String get community => 'Comunità';

  @override
  String get myCommunity => 'La Mia Comunità';

  @override
  String get friends => 'Amici';

  @override
  String get requests => 'Richieste';

  @override
  String get noFriendsYet => 'Non hai ancora amici';

  @override
  String get searchForFriends => 'Cerca amici per iniziare!';

  @override
  String get noPendingRequests => 'Nessuna richiesta di amicizia in sospeso';

  @override
  String get receivedRequests => 'Richieste Ricevute';

  @override
  String get sentRequests => 'Richieste Inviate';

  @override
  String get accept => 'Accetta';

  @override
  String get decline => 'Rifiuta';

  @override
  String get pending => 'In Sospeso';

  @override
  String get removeFriend => 'Rimuovere Amico?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Sei sicuro di voler rimuovere $name dai tuoi amici?';
  }

  @override
  String get errorLoadingFriends => 'Errore nel caricamento degli amici';

  @override
  String get searchFriendsByEmail => 'Cerca amici per email...';

  @override
  String get cannotAddYourself => 'Non puoi aggiungere te stesso come amico';

  @override
  String userNotFoundWithEmail(String email) {
    return 'Nessun utente trovato con l\'email: $email';
  }

  @override
  String get makeSureEmailCorrect => 'Assicurati che l\'email sia corretta';

  @override
  String get requestPending => 'In Sospeso';

  @override
  String get acceptRequest => 'Accetta Richiesta';

  @override
  String get sendFriendRequest => 'Aggiungi';

  @override
  String get search => 'Cerca';

  @override
  String get addFriend => 'Aggiungi Amico';

  @override
  String get searchForFriendsToAdd => 'Cerca amici da aggiungere';

  @override
  String get enterEmailToFindFriends =>
      'Inserisci un indirizzo email per trovare utenti';

  @override
  String get checkRequestsTab =>
      'Controlla la scheda Richieste per accettare la richiesta di amicizia';

  @override
  String get ok => 'OK';

  @override
  String get dontHaveAccount => 'Non hai un account? ';

  @override
  String get signUp => 'Registrati';

  @override
  String get resetPassword => 'Reimposta Password';

  @override
  String get backToLogin => 'Torna al Login';

  @override
  String get emailSent => 'Email Inviata!';

  @override
  String get createAccount => 'Crea un account';

  @override
  String get accountCreatedSuccess =>
      'Account creato con successo! Controlla la tua email per la verifica.';

  @override
  String get alreadyHaveAccount => 'Hai già un account? ';

  @override
  String get signIn => 'Accedi';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get displayNameOptionalHint => 'Nome Visualizzato (Opzionale)';

  @override
  String get confirmPassword => 'Conferma Password';

  @override
  String get createGame => 'Crea Partita';

  @override
  String get gameCreatedSuccess => 'Partita creata con successo!';

  @override
  String get pleaseLogInToCreateGame => 'Accedi per creare una partita';

  @override
  String get group => 'Gruppo';

  @override
  String get dateTime => 'Data e Ora';

  @override
  String get tapToSelect => 'Tocca per selezionare';

  @override
  String get gameDetails => 'Dettagli Partita';

  @override
  String get goBack => 'Indietro';

  @override
  String get organizer => 'Organizzatore';

  @override
  String get enterResults => 'Inserisci Risultati';

  @override
  String get leaveGame => 'Abbandona Partita';

  @override
  String get leaveWaitlist => 'Abbandona Lista d\'Attesa';

  @override
  String get confirm => 'Conferma';

  @override
  String get editDispute => 'Modifica / Contesta';

  @override
  String get filterGames => 'Filtra Partite';

  @override
  String get allGames => 'Tutte le Partite';

  @override
  String get myGamesOnly => 'Solo le Mie Partite';

  @override
  String get gameHistory => 'Storico Partite';

  @override
  String get selectFiltersToView =>
      'Seleziona filtri per visualizzare lo storico';

  @override
  String get activeFilters => 'Filtri attivi: ';

  @override
  String get myGames => 'Le Mie Partite';

  @override
  String get gameResults => 'Risultati Partita';

  @override
  String groupNameGames(String groupName) {
    return 'Partite di $groupName';
  }

  @override
  String get recordResults => 'Registra Risultati';

  @override
  String get teamsSavedSuccess => 'Squadre salvate con successo';

  @override
  String get teamA => 'Squadra A';

  @override
  String get teamB => 'Squadra B';

  @override
  String get enterScores => 'Inserisci Punteggi';

  @override
  String get scoresSavedSuccess => 'Punteggi salvati con successo!';

  @override
  String get savingScores => 'Salvataggio punteggi...';

  @override
  String get oneSet => '1 Set';

  @override
  String get bestOfTwo => 'Meglio di 2';

  @override
  String get bestOfThree => 'Meglio di 3';

  @override
  String get gameTitle => 'Titolo Partita';

  @override
  String get gameTitleHint => 'es. Beach Volley';

  @override
  String get descriptionOptional => 'Descrizione (Opzionale)';

  @override
  String get gameDescriptionHint => 'Aggiungi dettagli sulla partita...';

  @override
  String get location => 'Luogo';

  @override
  String get locationHint => 'es. Spiaggia di Rimini';

  @override
  String get addressOptional => 'Indirizzo (Opzionale)';

  @override
  String get addressHint => 'Indirizzo completo...';

  @override
  String get filter => 'Filtro';

  @override
  String get dateRange => 'Intervallo Date';

  @override
  String get removeFromTeam => 'Rimuovi dalla squadra';

  @override
  String get clearFilter => 'Cancella filtro';

  @override
  String get filterByDate => 'Filtra per data';

  @override
  String get groupNameRequired => 'Nome Gruppo *';

  @override
  String get groupNameHint => 'es. Team Beach Volley';

  @override
  String get groupDescriptionHint => 'es. Partite settimanali di beach volley';

  @override
  String get pleaseSelectStartTimeFirst => 'Prima seleziona l\'ora di inizio';

  @override
  String get pleaseSelectStartTime => 'Seleziona l\'ora di inizio';

  @override
  String get pleaseSelectEndTime => 'Seleziona l\'ora di fine';

  @override
  String get trainingCreatedSuccess => 'Allenamento creato con successo!';

  @override
  String get createTrainingSession => 'Crea Allenamento';

  @override
  String get pleaseLogInToCreateTraining => 'Accedi per creare un allenamento';

  @override
  String get startTime => 'Ora Inizio';

  @override
  String get endTime => 'Ora Fine';

  @override
  String get title => 'Titolo';

  @override
  String get trainingSession => 'Allenamento';

  @override
  String get trainingNotFound => 'Allenamento non trovato';

  @override
  String get trainingCancelled => 'Allenamento annullato';

  @override
  String get errorLoadingParticipants =>
      'Errore nel caricamento dei partecipanti';

  @override
  String get joinedTrainingSuccess =>
      'Ti sei unito all\'allenamento con successo!';

  @override
  String get leftTraining => 'Hai lasciato l\'allenamento';

  @override
  String get joinTrainingSession => 'Unisciti all\'Allenamento';

  @override
  String get join => 'Unisciti';

  @override
  String get leaveTrainingSession => 'Lascia Allenamento';

  @override
  String get leave => 'Lascia';

  @override
  String get cancelTrainingSession => 'Annullare Allenamento?';

  @override
  String get keepSession => 'Mantieni Allenamento';

  @override
  String get cancelSession => 'Annulla Allenamento';

  @override
  String get sessionFeedback => 'Feedback Allenamento';

  @override
  String get thankYouFeedback => 'Grazie per il tuo feedback!';

  @override
  String get backToSession => 'Torna all\'Allenamento';

  @override
  String get needsWork => 'Da migliorare';

  @override
  String get topLevelTraining => 'Allenamento di alto livello';

  @override
  String get pleaseRateAllCategories =>
      'Valuta tutte e tre le categorie prima di inviare';

  @override
  String get emailVerification => 'Verifica Email';

  @override
  String verificationEmailSent(String email) {
    return 'Email di verifica inviata a $email';
  }

  @override
  String get backToProfile => 'Torna al Profilo';

  @override
  String get sendVerificationEmail => 'Invia Email di Verifica';

  @override
  String get refreshStatus => 'Aggiorna Stato';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get eloHistory => 'Storico ELO';

  @override
  String get gameDetailsComingSoon => 'Dettagli partita in arrivo!';

  @override
  String get headToHead => 'Testa a Testa';

  @override
  String get partnerDetails => 'Dettagli Partner';

  @override
  String get invitations => 'Inviti';

  @override
  String get pleaseLogInToViewInvitations =>
      'Accedi per visualizzare gli inviti';

  @override
  String get pendingInvitations => 'Inviti in Sospeso';

  @override
  String get notificationSettings => 'Impostazioni Notifiche';

  @override
  String get initializing => 'Inizializzazione...';

  @override
  String get groupInvitations => 'Inviti di Gruppo';

  @override
  String get groupInvitationsDesc => 'Quando qualcuno ti invita in un gruppo';

  @override
  String get invitationAccepted => 'Invito Accettato';

  @override
  String get invitationAcceptedDesc => 'Quando qualcuno accetta il tuo invito';

  @override
  String get newGames => 'Nuove Partite';

  @override
  String get newGamesDesc =>
      'Quando viene creata una nuova partita nei tuoi gruppi';

  @override
  String get roleChanges => 'Cambio Ruolo';

  @override
  String get roleChangesDesc => 'Quando vieni promosso ad amministratore';

  @override
  String get newTrainingSessions => 'Nuovi Allenamenti';

  @override
  String get newTrainingSessionsDesc =>
      'Quando viene creato un allenamento nei tuoi gruppi';

  @override
  String get minParticipantsReached => 'Minimo Partecipanti Raggiunto';

  @override
  String get minParticipantsReachedDesc =>
      'Quando un allenamento ha abbastanza partecipanti';

  @override
  String get feedbackReceived => 'Feedback Ricevuto';

  @override
  String get feedbackReceivedDesc =>
      'Quando qualcuno lascia un feedback su un allenamento';

  @override
  String get sessionCancelled => 'Allenamento Annullato';

  @override
  String get sessionCancelledDesc =>
      'Quando un allenamento a cui ti sei unito viene annullato';

  @override
  String get memberJoined => 'Membro Iscritto';

  @override
  String get memberJoinedDesc => 'Quando qualcuno si unisce al tuo gruppo';

  @override
  String get memberLeft => 'Membro Uscito';

  @override
  String get memberLeftDesc => 'Quando qualcuno lascia il tuo gruppo';

  @override
  String get enableQuietHours => 'Attiva Ore Silenziose';

  @override
  String get quietHoursDesc => 'Metti in pausa le notifiche in orari specifici';

  @override
  String get adjustQuietHours => 'Regola Ore Silenziose';

  @override
  String get setQuietHours => 'Imposta Ore Silenziose';

  @override
  String error(String message) {
    return 'Errore: $message';
  }

  @override
  String get pleaseLogInToAddFriends => 'Accedi per aggiungere amici';

  @override
  String get welcomeBack => 'Bentornato!';

  @override
  String get signInToContinue =>
      'Accedi per continuare a organizzare le tue partite di pallavolo';

  @override
  String get emailRequired => 'L\'email è obbligatoria';

  @override
  String get validEmailRequired => 'Inserisci un\'email valida';

  @override
  String get passwordRequired => 'La password è obbligatoria';

  @override
  String get continueAsGuest => 'Continua come Ospite';

  @override
  String get joinPlayWithMe => 'Unisciti a PlayWithMe!';

  @override
  String get createAccountSubtitle =>
      'Crea il tuo account per iniziare a organizzare partite di pallavolo';

  @override
  String get displayNameTooLong =>
      'Il nome visualizzato deve avere meno di 50 caratteri';

  @override
  String get passwordTooShort => 'La password deve avere almeno 6 caratteri';

  @override
  String get pleaseConfirmPassword => 'Conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get termsAgreement =>
      'Creando un account, accetti i nostri Termini di Servizio e l\'Informativa sulla Privacy.';

  @override
  String get forgotYourPassword => 'Password Dimenticata?';

  @override
  String get forgotPasswordInstructions =>
      'Inserisci il tuo indirizzo email e ti invieremo un link per reimpostare la password.';

  @override
  String get sendResetEmail => 'Invia Email di Reimpostazione';

  @override
  String get resetLinkSentTo => 'Abbiamo inviato un link di reimpostazione a:';

  @override
  String get checkEmailResetInstructions =>
      'Controlla la tua email e segui le istruzioni per reimpostare la password.';

  @override
  String get noResultsAvailable => 'Nessun risultato ancora disponibile';

  @override
  String get scoresWillAppear =>
      'I punteggi appariranno qui una volta inseriti';

  @override
  String get individualGames => 'Partite Individuali';

  @override
  String get howManyGamesPlayed => 'Quante partite hai giocato?';

  @override
  String get assignPlayersToTeams => 'Assegna Giocatori alle Squadre';

  @override
  String get dragPlayersToAssign =>
      'Trascina i giocatori per assegnarli alla Squadra A o B';

  @override
  String get pendingVerification => 'Verifica in Sospeso';

  @override
  String get youreIn => 'Sei Iscritto';

  @override
  String get onWaitlist => 'In Lista d\'Attesa';

  @override
  String get full => 'Completo';

  @override
  String get joinGame => 'Unisciti alla Partita';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get player => 'Giocatore';

  @override
  String get noScoresRecorded => 'Nessun punteggio registrato';

  @override
  String get eloUpdated => 'ELO Aggiornato';

  @override
  String get vs => 'VS';

  @override
  String get cancelled => 'ANNULLATO';

  @override
  String get joined => 'ISCRITTO';

  @override
  String get training => 'Allenamento';

  @override
  String get gameLabel => 'PARTITA';

  @override
  String minParticipants(int count) {
    return 'Min: $count';
  }

  @override
  String get selectGameDate => 'Seleziona Data Partita';

  @override
  String get selectGameTime => 'Seleziona Ora Partita';

  @override
  String get pleaseTitleRequired => 'Inserisci un titolo per la partita';

  @override
  String get titleMinLength => 'Il titolo deve avere almeno 3 caratteri';

  @override
  String get titleMaxLength => 'Il titolo deve avere meno di 100 caratteri';

  @override
  String get pleaseEnterTitle => 'Inserisci un titolo';

  @override
  String get pleaseEnterLocation => 'Inserisci un luogo';

  @override
  String get notSelected => 'Non selezionato';

  @override
  String get selectStartDate => 'Seleziona Data Inizio';

  @override
  String get selectStartTime => 'Seleziona Ora Inizio';

  @override
  String get selectEndTime => 'Seleziona Ora Fine';

  @override
  String get participants => 'Partecipanti';

  @override
  String get exercises => 'Esercizi';

  @override
  String get feedback => 'Feedback';

  @override
  String get date => 'Data';

  @override
  String get time => 'Ora';

  @override
  String get players => 'Giocatori';

  @override
  String get competitiveGameWithElo => 'Partita competitiva con classifica ELO';

  @override
  String get practiceSessionNoElo => 'Sessione di pratica senza impatto ELO';

  @override
  String get promoteToAdmin => 'Promuovi ad Amministratore';

  @override
  String get promote => 'Promuovi';

  @override
  String get demoteToMember => 'Retrocedi a Membro';

  @override
  String get demote => 'Retrocedi';

  @override
  String get removeMember => 'Rimuovi Membro';

  @override
  String get leaveGroup => 'Lascia Gruppo';

  @override
  String get selectAll => 'Seleziona Tutto';

  @override
  String get clearAll => 'Cancella Tutto';

  @override
  String get upload => 'Carica';

  @override
  String get avatarUploadedSuccess => 'Avatar caricato con successo';

  @override
  String get avatarRemovedSuccess => 'Avatar rimosso con successo';

  @override
  String get bestTeammate => 'Miglior Compagno';

  @override
  String get gameNotFound => 'Partita Non Trovata';

  @override
  String get noCompletedGamesYet => 'Nessuna partita completata ancora';

  @override
  String get gamesWillAppearAfterCompleted =>
      'Le partite appariranno qui una volta completate';

  @override
  String get finalScore => 'Punteggio Finale';

  @override
  String get eloRatingChanges => 'Variazioni Classifica ELO';

  @override
  String get unknownPlayer => 'Giocatore Sconosciuto';

  @override
  String gameNumber(int number) {
    return 'Partita $number';
  }

  @override
  String setsScore(int teamA, int teamB) {
    return 'Set: $teamA - $teamB';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get format => 'Formato:';

  @override
  String get invalidScore => 'Punteggio non valido';

  @override
  String get overallWinnerTeamA => 'Vincitore Generale: Squadra A';

  @override
  String get overallWinnerTeamB => 'Vincitore Generale: Squadra B';

  @override
  String get resultTie => 'Risultato: Pareggio';

  @override
  String get saveScores => 'Salva Punteggi';

  @override
  String completeGamesToContinue(int current, int total) {
    return 'Completa $current/$total partite per continuare';
  }

  @override
  String get upcomingActivities => 'Attività Imminenti';

  @override
  String get pastActivities => 'Attività Passate';

  @override
  String get noUpcomingGamesYet => 'Nessuna partita imminente ancora';

  @override
  String get createFirstGame => 'Crea la prima partita!';

  @override
  String get noActivitiesYet => 'Nessuna attività ancora';

  @override
  String get createFirstActivity => 'Crea la prima attività!';

  @override
  String get gamesWon => 'partite vinte';

  @override
  String get playerCountSingular => '1 giocatore';

  @override
  String playerCountPlural(int count) {
    return '$count giocatori';
  }

  @override
  String wonScoreDescription(String winner, String score) {
    return '$winner ha vinto $score';
  }

  @override
  String playersWaitlisted(int count) {
    return '$count in lista d\'attesa';
  }

  @override
  String playersCount(int current, int max) {
    return '$current/$max giocatori';
  }

  @override
  String get minParticipantsLabel => 'Min Partecipanti';

  @override
  String get maxParticipantsLabel => 'Max Partecipanti';

  @override
  String get youAreOrganizing => 'Stai organizzando';

  @override
  String organizedBy(String name) {
    return 'Organizzato da $name';
  }

  @override
  String get scheduled => 'Programmato';

  @override
  String get completed => 'Completato';

  @override
  String get noParticipantsYet => 'Nessun partecipante ancora';

  @override
  String get beFirstToJoin => 'Sii il primo ad unirti!';

  @override
  String get participation => 'Partecipazione';

  @override
  String get current => 'Attuale';

  @override
  String get minimum => 'Minimo';

  @override
  String get maximum => 'Massimo';

  @override
  String get availableSpots => 'Posti Disponibili';

  @override
  String get you => 'Tu';

  @override
  String get joining => 'Iscrizione...';

  @override
  String get leaving => 'Uscita...';

  @override
  String get cannotJoin => 'Impossibile unirsi';

  @override
  String get allParticipantsNotified =>
      'Tutti i partecipanti saranno notificati.';

  @override
  String get feedbackAlreadySubmitted => 'Feedback Già Inviato';

  @override
  String alreadyProvidedFeedback(String sessionTitle) {
    return 'Hai già fornito un feedback per \"$sessionTitle\".';
  }

  @override
  String get provideAnonymousFeedback => 'Fornisci Feedback Anonimo';

  @override
  String get feedbackIsAnonymous =>
      'Il tuo feedback è anonimo e aiuta a migliorare i futuri allenamenti.';

  @override
  String get exercisesQuality => 'Qualità degli Esercizi';

  @override
  String get wereDrillsEffective => 'Gli esercizi sono stati efficaci?';

  @override
  String get trainingIntensity => 'Intensità dell\'Allenamento';

  @override
  String get physicalDemandLevel => 'Livello di impegno fisico';

  @override
  String get coachingClarity => 'Chiarezza del Coaching';

  @override
  String get instructionsAndCorrections => 'Istruzioni e correzioni?';

  @override
  String get additionalCommentsOptional => 'Commenti Aggiuntivi (Opzionale)';

  @override
  String get shareYourThoughts =>
      'Condividi i tuoi pensieri sulla sessione, gli esercizi o suggerimenti per migliorare...';

  @override
  String get submitFeedback => 'Invia Feedback';

  @override
  String get feedbackPrivacyNotice =>
      'Il tuo feedback è completamente anonimo e non può essere ricondotto a te.';

  @override
  String get invite => 'Invita';

  @override
  String get inviteMembers => 'Invita Membri';

  @override
  String get adminOnly => 'Solo amministratori';

  @override
  String get create => 'Crea';

  @override
  String get createGameOrTraining => 'Crea partita o allenamento';

  @override
  String get activities => 'Attività';

  @override
  String get viewAllActivities => 'Visualizza tutte le attività';

  @override
  String get removeFromGroup => 'Rimuovi dal Gruppo';

  @override
  String promoteConfirmMessage(String name) {
    return 'Sei sicuro di voler promuovere $name ad amministratore?\n\nGli amministratori possono:\n• Gestire i membri del gruppo\n• Invitare nuovi membri\n• Modificare le impostazioni del gruppo';
  }

  @override
  String demoteConfirmMessage(String name) {
    return 'Sei sicuro di voler retrocedere $name a membro normale?\n\nPerderà i privilegi di amministratore.';
  }

  @override
  String removeConfirmMessage(String name) {
    return 'Sei sicuro di voler rimuovere $name dal gruppo?\n\nQuesta azione non può essere annullata. Dovrà essere invitato nuovamente.';
  }

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return 'Sei sicuro di voler lasciare \"$groupName\"?\n\nDovrai essere invitato nuovamente per unirti a questo gruppo.';
  }

  @override
  String get performanceStats => 'Statistiche di Prestazione';

  @override
  String get eloRatingLabel => 'Classifica ELO';

  @override
  String peak(String value) {
    return 'Picco: $value';
  }

  @override
  String get winRate => 'Percentuale vittorie';

  @override
  String winsLosses(int wins, int losses) {
    return '${wins}V - ${losses}S';
  }

  @override
  String get streakLabel => 'Serie';

  @override
  String get winning => 'Vittorie';

  @override
  String get losingStreak => 'Sconfitte';

  @override
  String get noStreak => 'Nessuna';

  @override
  String get gamesPlayedLabel => 'Partite Giocate';

  @override
  String get noPlayersAssigned => 'Nessun giocatore assegnato';

  @override
  String get unassignedPlayers => 'Giocatori Non Assegnati';

  @override
  String get allPlayersAssigned => 'Tutti i giocatori assegnati!';

  @override
  String get saveTeams => 'Salva Squadre';

  @override
  String get assignAllPlayersToContinue =>
      'Assegna tutti i giocatori per continuare';

  @override
  String invitedBy(String name) {
    return 'Invitato da $name';
  }

  @override
  String get errorTitle => 'Errore';

  @override
  String participantsCount(int current, int max) {
    return '$current/$max partecipanti';
  }

  @override
  String doYouWantToJoin(
    String sessionTitle,
    String dateTime,
    String location,
  ) {
    return 'Vuoi unirti a \"$sessionTitle\"?\n\nData: $dateTime\nLuogo: $location';
  }

  @override
  String areYouSureLeave(String sessionTitle) {
    return 'Sei sicuro di voler lasciare \"$sessionTitle\"?';
  }

  @override
  String cancelSessionConfirm(String sessionTitle) {
    return 'Sei sicuro di voler annullare \"$sessionTitle\"?\n\nTutti i partecipanti saranno notificati.';
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
  String get bestPartner => 'Miglior Partner';

  @override
  String get noPartnerDataYet => 'Nessun dato partner ancora';

  @override
  String get playGamesWithTeammate => 'Gioca 5+ partite con un compagno';

  @override
  String winRatePercent(String rate) {
    return '$rate% di vittorie';
  }

  @override
  String gamesCount(int count) {
    return '$count partite';
  }

  @override
  String winsLossesGames(int wins, int losses, int total) {
    return '${wins}V - ${losses}S • $total partite';
  }

  @override
  String get momentumAndConsistency => 'Momentum e Costanza';

  @override
  String get eloProgress => 'Progresso ELO';

  @override
  String get winStreak => 'Serie di vittorie';

  @override
  String get lossStreak => 'Serie di sconfitte';

  @override
  String get noActiveStreak => 'Nessuna serie attiva';

  @override
  String get winNextGameToStartStreak =>
      'Vinci la prossima partita per iniziare una serie!';

  @override
  String get rival => 'Rivale';

  @override
  String matchups(int count) {
    return '$count scontri';
  }

  @override
  String winRateLabel(String rate) {
    return 'Percentuale vittorie: $rate%';
  }

  @override
  String get tapForFullBreakdown => 'Tocca per i dettagli';

  @override
  String get noNemesisYet => 'Nessun Nemico ancora';

  @override
  String get playGamesAgainstSameOpponent =>
      'Gioca almeno 3 partite contro lo stesso avversario per tracciare il tuo scontro più difficile.';

  @override
  String get faceOpponentThreeTimes => 'Affronta lo stesso avversario 3+ volte';

  @override
  String get noPerformanceData => 'Nessun dato prestazioni';

  @override
  String get playFirstGameToSeeStats =>
      'Gioca la tua prima partita per vedere le tue statistiche!';

  @override
  String get playAtLeastOneGame => 'Gioca almeno 1 partita per sbloccare';

  @override
  String get performanceOverview => 'Panoramica prestazioni';

  @override
  String get currentElo => 'ELO attuale';

  @override
  String get peakElo => 'ELO massimo';

  @override
  String get gamesPlayed => 'Partite giocate';

  @override
  String get bestWin => 'Migliore vittoria';

  @override
  String get winGameToUnlock => 'Vinci una partita per sbloccare';

  @override
  String get beatOpponentsToTrack =>
      'Batti gli avversari per tracciare le tue migliori vittorie';

  @override
  String get avgPointDiff => 'Diff. punti media';

  @override
  String get completeGameToUnlock => 'Completa una partita per sbloccare';

  @override
  String get winAndLoseSetsToSee =>
      'Vinci e perdi set per vedere i tuoi margini';

  @override
  String get avgPointDifferential => 'Differenza punti media';

  @override
  String get inWins => 'Nelle vittorie';

  @override
  String get inLosses => 'Nelle sconfitte';

  @override
  String setsCount(int count) {
    return '$count set';
  }

  @override
  String teamLabel(String names) {
    return 'Squadra: $names';
  }

  @override
  String teamEloLabel(String elo) {
    return 'ELO squadra: $elo';
  }

  @override
  String eloGained(String amount) {
    return '$amount ELO guadagnati';
  }

  @override
  String get adaptabilityStats => 'Stats adattabilità';

  @override
  String get advanced => 'Avanzato';

  @override
  String get seeHowYouPerform =>
      'Guarda come ti comporti in diversi ruoli di squadra';

  @override
  String get leadingTheTeam => 'Guidare la squadra';

  @override
  String get whenHighestRated => 'Quando sei il giocatore meglio classificato';

  @override
  String get playingWithStrongerPartners => 'Giocare con partner più forti';

  @override
  String get whenMoreExperiencedTeammates =>
      'Quando giochi con compagni più esperti';

  @override
  String get balancedTeams => 'Squadre equilibrate';

  @override
  String get whenSimilarlyRatedTeammates =>
      'Quando giochi con compagni di livello simile';

  @override
  String get adaptabilityStatsLocked => 'Stats adattabilità bloccate';

  @override
  String get playMoreGamesToSeeRoles =>
      'Gioca più partite per vedere come ti comporti in diversi ruoli';

  @override
  String get noStatsYet => 'Nessuna stat ancora';

  @override
  String get startPlayingToSeeStats =>
      'Inizia a giocare per vedere le tue statistiche!';

  @override
  String get playGamesToUnlockRankings => 'Gioca per sbloccare le classifiche';

  @override
  String get globalRank => 'Classifica Globale';

  @override
  String get percentile => 'Percentile';

  @override
  String get friendsRank => 'Classifica Amici';

  @override
  String get addFriendsAction => 'Aggiungi amici';

  @override
  String get period30d => '30g';

  @override
  String get period90d => '90g';

  @override
  String get period1y => '1a';

  @override
  String get periodAllTime => 'Sempre';

  @override
  String get monthlyProgressChart => 'Grafico progresso mensile';

  @override
  String playAtLeastNGames(int count) {
    return 'Gioca almeno $count partite';
  }

  @override
  String nOfNGames(int current, int total) {
    return '$current/$total partite';
  }

  @override
  String get startPlayingToTrackProgress =>
      'Inizia a giocare per monitorare i tuoi progressi!';

  @override
  String get keepPlayingToUnlockChart =>
      'Continua a giocare per sbloccare questo grafico!';

  @override
  String get playGamesOverLongerPeriod => 'Gioca per un periodo più lungo';

  @override
  String get keepPlayingToSeeProgress =>
      'Continua a giocare per vedere i tuoi progressi!';

  @override
  String get noGamesInThisPeriod => 'Nessuna partita in questo periodo';

  @override
  String noGamesPlayedInLast(String period) {
    return 'Nessuna partita negli ultimi $period';
  }

  @override
  String get trySelectingLongerPeriod =>
      'Prova a selezionare un periodo più lungo';

  @override
  String get periodLabel30Days => '30 giorni';

  @override
  String get periodLabel90Days => '90 giorni';

  @override
  String get periodLabelYear => 'anno';

  @override
  String get periodLabelAllTime => 'tutto il tempo';

  @override
  String get bestEloThisMonth => 'Miglior ELO questo mese';

  @override
  String get bestEloPast90Days => 'Miglior ELO ultimi 90 giorni';

  @override
  String get bestEloThisYear => 'Miglior ELO quest\'anno';

  @override
  String get bestEloAllTime => 'Miglior ELO di sempre';

  @override
  String lastNGames(int count) {
    return 'Ultime $count partite';
  }

  @override
  String get noGamesPlayedYet => 'Nessuna partita giocata';

  @override
  String winsStreakCount(int count) {
    return '$count vittorie';
  }

  @override
  String lossesStreakCount(int count) {
    return '$count sconfitte';
  }

  @override
  String get partnerDetailsTitle => 'Dettagli partner';

  @override
  String get overallRecord => 'Bilancio generale';

  @override
  String get games => 'Partite';

  @override
  String get record => 'Bilancio';

  @override
  String get pointDifferential => 'Differenza punti';

  @override
  String get avgPerGame => 'Media per partita';

  @override
  String get pointsFor => 'Punti fatti';

  @override
  String get pointsAgainst => 'Punti subiti';

  @override
  String get eloPerformance => 'Performance ELO';

  @override
  String get totalChange => 'Variazione totale';

  @override
  String get recentForm => 'Forma recente';

  @override
  String streakWins(int count) {
    return '$count V Serie';
  }

  @override
  String streakLosses(int count) {
    return '$count S Serie';
  }

  @override
  String get noRecentGames => 'Nessuna partita recente';

  @override
  String eloLabel(String value) {
    return 'ELO: $value';
  }

  @override
  String get nextGame => 'Prossima partita';

  @override
  String get noGamesScheduled => 'Nessuna partita organizzata ancora';

  @override
  String get nextTrainingSession => 'Prossimo allenamento';

  @override
  String get noTrainingSessionsScheduled => 'Nessun allenamento programmato';

  @override
  String get stats => 'Statistiche';

  @override
  String get myStats => 'Le Mie Statistiche';

  @override
  String get generateInviteLink => 'Genera link di invito';

  @override
  String get copyLink => 'Copia link';

  @override
  String get shareLink => 'Condividi';

  @override
  String get linkCopied => 'Link copiato negli appunti';

  @override
  String get inviteLinkSectionTitle => 'Invita membri';

  @override
  String get inviteLinkDescription =>
      'Condividi questo link per invitare persone a unirsi al gruppo.';

  @override
  String get revokeInvite => 'Revoca invito';

  @override
  String get inviteRevoked => 'Link di invito revocato';

  @override
  String get generateInviteError => 'Impossibile generare il link di invito';

  @override
  String get revokeInviteError => 'Impossibile revocare il link di invito';

  @override
  String inviteLinkShareMessage(String url) {
    return 'Unisciti al mio gruppo su PlayWithMe! $url';
  }

  @override
  String get pageNotFound => 'Pagina non trovata';

  @override
  String get pageNotFoundMessage => 'La pagina richiesta non è stata trovata.';

  @override
  String get inviteOnboardingTitle => 'Sei stato invitato!';

  @override
  String get inviteOnboardingSubtitle => 'Sei stato invitato a unirti a:';

  @override
  String get iHaveAnAccount => 'Ho un account';

  @override
  String get joinGroup => 'Unisciti al gruppo';

  @override
  String get joinGroupConfirmation => 'Unirsi al gruppo?';

  @override
  String membersCount(int count) {
    return '$count membri';
  }

  @override
  String get inviteExpired => 'Questo link di invito è scaduto';

  @override
  String get inviteLinkRevoked => 'Questo link di invito non è più valido';

  @override
  String get inviteLimitReached =>
      'Questo link di invito ha raggiunto il suo limite di utilizzo';

  @override
  String groupJoinedSuccess(String groupName) {
    return 'Benvenuto in $groupName!';
  }

  @override
  String get alreadyAMember => 'Sei già membro di questo gruppo';

  @override
  String get continueToApp => 'Continua all\'app';

  @override
  String get validatingInvite => 'Convalida dell\'invito...';

  @override
  String get joiningGroup => 'Entrando nel gruppo...';
}
