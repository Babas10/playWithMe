// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PlayWithMe';

  @override
  String get welcomeMessage => 'Bienvenue sur PlayWithMe !';

  @override
  String get beachVolleyballOrganizer =>
      'Organisateur de matchs de beach-volley';

  @override
  String get firebaseConnected => 'Connecté';

  @override
  String get firebaseDisconnected => 'Déconnecté';

  @override
  String get firebase => 'Firebase';

  @override
  String get environment => 'Environnement';

  @override
  String get project => 'Projet';

  @override
  String get loading => 'Chargement...';

  @override
  String get profile => 'Profil';

  @override
  String get signOut => 'Se Déconnecter';

  @override
  String get accountSettings => 'Paramètres du Compte';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get displayName => 'Nom d\'Affichage';

  @override
  String get language => 'Langue';

  @override
  String get country => 'Pays';

  @override
  String get timezone => 'Fuseau Horaire';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String get settingsUpdatedSuccessfully => 'Paramètres mis à jour avec succès';

  @override
  String get removeAvatar => 'Supprimer l\'Avatar';

  @override
  String get takePhoto => 'Prendre une Photo';

  @override
  String get chooseFromGallery => 'Choisir dans la Galerie';

  @override
  String get confirmRemoveAvatar =>
      'Êtes-vous sûr de vouloir supprimer votre avatar ?';

  @override
  String get remove => 'Supprimer';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de Passe';

  @override
  String get login => 'Se Connecter';

  @override
  String get register => 'S\'Inscrire';

  @override
  String get forgotPassword => 'Mot de Passe Oublié ?';

  @override
  String get unsavedChangesTitle => 'Modifications Non Enregistrées';

  @override
  String get unsavedChangesMessage =>
      'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir partir ?';

  @override
  String get discard => 'Abandonner';

  @override
  String get displayNameHint => 'Entrez votre nom d\'affichage';

  @override
  String get preferredLanguage => 'Langue Préférée';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get stay => 'Rester';

  @override
  String get accountInformation => 'Informations du Compte';

  @override
  String get verify => 'Vérifier';

  @override
  String get accountType => 'Type de Compte';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get regular => 'Régulier';

  @override
  String get memberSince => 'Membre Depuis';

  @override
  String get lastActive => 'Dernière Activité';

  @override
  String get signOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get pleaseLogIn => 'Veuillez vous connecter pour voir votre profil';

  @override
  String get userId => 'ID Utilisateur';

  @override
  String get myGroups => 'Mes Groupes';

  @override
  String get pleaseLogInToViewGroups =>
      'Veuillez vous connecter pour voir vos groupes';

  @override
  String get errorLoadingGroups => 'Erreur de Chargement des Groupes';

  @override
  String get retry => 'Réessayer';

  @override
  String get createGroup => 'Créer un Groupe';

  @override
  String get groupDetailsComingSoon =>
      'Page de détails du groupe bientôt disponible !';

  @override
  String get noGroupsYet =>
      'Vous ne faites partie d\'aucun groupe pour le moment';

  @override
  String get noGroupsMessage =>
      'Créez ou rejoignez des groupes pour commencer à organiser des matchs de beach-volley avec vos amis !';

  @override
  String memberCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get publicGroup => 'Public';

  @override
  String get inviteOnlyGroup => 'Sur Invitation Uniquement';

  @override
  String get privateGroup => 'Privé';

  @override
  String get createYourFirstGroup => 'Créer Votre Premier Groupe';

  @override
  String get useCreateGroupButton =>
      'Utilisez le bouton Créer un Groupe ci-dessous pour commencer.';

  @override
  String get home => 'Accueil';

  @override
  String get groups => 'Groupes';

  @override
  String get community => 'Communauté';

  @override
  String get myCommunity => 'Ma Communauté';

  @override
  String get friends => 'Amis';

  @override
  String get requests => 'Demandes';

  @override
  String get noFriendsYet => 'Vous n\'avez pas encore d\'amis';

  @override
  String get searchForFriends => 'Recherchez des amis pour commencer !';

  @override
  String get noPendingRequests => 'Aucune demande d\'ami en attente';

  @override
  String get receivedRequests => 'Demandes Reçues';

  @override
  String get sentRequests => 'Demandes Envoyées';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get pending => 'En Attente';

  @override
  String get removeFriend => 'Supprimer l\'Ami ?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir retirer $name de vos amis ?';
  }

  @override
  String get errorLoadingFriends => 'Erreur lors du chargement des amis';

  @override
  String get searchFriendsByEmail => 'Rechercher des amis par e-mail...';

  @override
  String get cannotAddYourself =>
      'Vous ne pouvez pas vous ajouter vous-même comme ami';

  @override
  String userNotFoundWithEmail(String email) {
    return 'Aucun utilisateur trouvé avec l\'e-mail : $email';
  }

  @override
  String get makeSureEmailCorrect => 'Assurez-vous que l\'e-mail est correct';

  @override
  String get requestPending => 'En Attente';

  @override
  String get acceptRequest => 'Accepter la Demande';

  @override
  String get sendFriendRequest => 'Ajouter';

  @override
  String get search => 'Rechercher';

  @override
  String get addFriend => 'Ajouter un Ami';

  @override
  String get searchForFriendsToAdd => 'Rechercher des amis à ajouter';

  @override
  String get enterEmailToFindFriends =>
      'Entrez une adresse e-mail pour trouver des utilisateurs';

  @override
  String get checkRequestsTab =>
      'Consultez l\'onglet Demandes pour accepter la demande d\'ami';

  @override
  String get ok => 'OK';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get resetPassword => 'Réinitialiser le Mot de Passe';

  @override
  String get backToLogin => 'Retour à la Connexion';

  @override
  String get emailSent => 'E-mail Envoyé !';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get accountCreatedSuccess =>
      'Compte créé avec succès ! Veuillez vérifier votre e-mail.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get emailHint => 'E-mail';

  @override
  String get passwordHint => 'Mot de Passe';

  @override
  String get displayNameOptionalHint => 'Nom d\'Affichage (Optionnel)';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get createGame => 'Créer un Match';

  @override
  String get gameCreatedSuccess => 'Match créé avec succès !';

  @override
  String get pleaseLogInToCreateGame =>
      'Veuillez vous connecter pour créer un match';

  @override
  String get group => 'Groupe';

  @override
  String get dateTime => 'Date et Heure';

  @override
  String get tapToSelect => 'Appuyez pour sélectionner';

  @override
  String get gameDetails => 'Détails du Match';

  @override
  String get goBack => 'Retour';

  @override
  String get organizer => 'Organisateur';

  @override
  String get enterResults => 'Saisir les Résultats';

  @override
  String get leaveGame => 'Quitter le Match';

  @override
  String get leaveWaitlist => 'Quitter la Liste d\'Attente';

  @override
  String get confirm => 'Confirmer';

  @override
  String get editDispute => 'Modifier / Contester';

  @override
  String get filterGames => 'Filtrer les Matchs';

  @override
  String get allGames => 'Tous les Matchs';

  @override
  String get myGamesOnly => 'Mes Matchs Uniquement';

  @override
  String get gameHistory => 'Historique des Matchs';

  @override
  String get selectFiltersToView =>
      'Sélectionnez des filtres pour voir l\'historique';

  @override
  String get activeFilters => 'Filtres actifs : ';

  @override
  String get myGames => 'Mes Matchs';

  @override
  String get gameResults => 'Résultats du Match';

  @override
  String groupNameGames(String groupName) {
    return 'Matchs de $groupName';
  }

  @override
  String get recordResults => 'Enregistrer les Résultats';

  @override
  String get teamsSavedSuccess => 'Équipes enregistrées avec succès';

  @override
  String get teamA => 'Équipe A';

  @override
  String get teamB => 'Équipe B';

  @override
  String get enterScores => 'Saisir les Scores';

  @override
  String get scoresSavedSuccess => 'Scores enregistrés avec succès !';

  @override
  String get savingScores => 'Enregistrement des scores...';

  @override
  String get oneSet => '1 Set';

  @override
  String get bestOfTwo => 'Meilleur de 2';

  @override
  String get bestOfThree => 'Meilleur de 3';

  @override
  String get gameTitle => 'Titre du Match';

  @override
  String get gameTitleHint => 'ex. Beach Volleyball';

  @override
  String get descriptionOptional => 'Description (Optionnel)';

  @override
  String get gameDescriptionHint => 'Ajoutez des détails sur le match...';

  @override
  String get location => 'Lieu';

  @override
  String get locationHint => 'ex. Plage de Nice';

  @override
  String get addressOptional => 'Adresse (Optionnel)';

  @override
  String get addressHint => 'Adresse complète...';

  @override
  String get filter => 'Filtrer';

  @override
  String get dateRange => 'Plage de Dates';

  @override
  String get removeFromTeam => 'Retirer de l\'équipe';

  @override
  String get clearFilter => 'Effacer le filtre';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get groupNameRequired => 'Nom du Groupe *';

  @override
  String get groupNameHint => 'ex. Équipe Beach Volley';

  @override
  String get groupDescriptionHint => 'ex. Matchs hebdomadaires de beach-volley';

  @override
  String get pleaseSelectStartTimeFirst =>
      'Veuillez d\'abord sélectionner l\'heure de début';

  @override
  String get pleaseSelectStartTime => 'Veuillez sélectionner l\'heure de début';

  @override
  String get pleaseSelectEndTime => 'Veuillez sélectionner l\'heure de fin';

  @override
  String get trainingCreatedSuccess =>
      'Séance d\'entraînement créée avec succès !';

  @override
  String get createTrainingSession => 'Créer une Séance d\'Entraînement';

  @override
  String get pleaseLogInToCreateTraining =>
      'Veuillez vous connecter pour créer une séance';

  @override
  String get startTime => 'Heure de Début';

  @override
  String get endTime => 'Heure de Fin';

  @override
  String get title => 'Titre';

  @override
  String get trainingSession => 'Séance d\'Entraînement';

  @override
  String get trainingNotFound => 'Séance d\'entraînement non trouvée';

  @override
  String get trainingCancelled => 'Séance d\'entraînement annulée';

  @override
  String get errorLoadingParticipants =>
      'Erreur de chargement des participants';

  @override
  String get joinedTrainingSuccess =>
      'Vous avez rejoint la séance avec succès !';

  @override
  String get leftTraining => 'Vous avez quitté la séance d\'entraînement';

  @override
  String get joinTrainingSession => 'Rejoindre la Séance';

  @override
  String get join => 'Rejoindre';

  @override
  String get leaveTrainingSession => 'Quitter la Séance';

  @override
  String get leave => 'Quitter';

  @override
  String get cancelTrainingSession => 'Annuler la Séance ?';

  @override
  String get keepSession => 'Conserver la Séance';

  @override
  String get cancelSession => 'Annuler la Séance';

  @override
  String get sessionFeedback => 'Retour sur la Séance';

  @override
  String get thankYouFeedback => 'Merci pour votre retour !';

  @override
  String get backToSession => 'Retour à la Séance';

  @override
  String get needsWork => 'À améliorer';

  @override
  String get topLevelTraining => 'Entraînement de haut niveau';

  @override
  String get pleaseRateAllCategories =>
      'Veuillez noter les trois catégories avant de soumettre';

  @override
  String get emailVerification => 'Vérification de l\'E-mail';

  @override
  String verificationEmailSent(String email) {
    return 'E-mail de vérification envoyé à $email';
  }

  @override
  String get backToProfile => 'Retour au Profil';

  @override
  String get sendVerificationEmail => 'Envoyer l\'E-mail de Vérification';

  @override
  String get refreshStatus => 'Actualiser le Statut';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get eloHistory => 'Historique ELO';

  @override
  String get gameDetailsComingSoon => 'Détails du match bientôt disponibles !';

  @override
  String get headToHead => 'Face à Face';

  @override
  String get partnerDetails => 'Détails du Partenaire';

  @override
  String get invitations => 'Invitations';

  @override
  String get pleaseLogInToViewInvitations =>
      'Veuillez vous connecter pour voir les invitations';

  @override
  String get pendingInvitations => 'Invitations en Attente';

  @override
  String get notificationSettings => 'Paramètres de Notification';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get groupInvitations => 'Invitations de Groupe';

  @override
  String get groupInvitationsDesc =>
      'Quand quelqu\'un vous invite dans un groupe';

  @override
  String get invitationAccepted => 'Invitation Acceptée';

  @override
  String get invitationAcceptedDesc =>
      'Quand quelqu\'un accepte votre invitation';

  @override
  String get newGames => 'Nouveaux Matchs';

  @override
  String get newGamesDesc => 'Quand un nouveau match est créé dans vos groupes';

  @override
  String get roleChanges => 'Changement de Rôle';

  @override
  String get roleChangesDesc => 'Quand vous êtes promu administrateur';

  @override
  String get newTrainingSessions => 'Nouvelles Séances';

  @override
  String get newTrainingSessionsDesc =>
      'Quand une séance est créée dans vos groupes';

  @override
  String get minParticipantsReached => 'Minimum de Participants Atteint';

  @override
  String get minParticipantsReachedDesc =>
      'Quand une séance a assez de participants';

  @override
  String get feedbackReceived => 'Retour Reçu';

  @override
  String get feedbackReceivedDesc =>
      'Quand quelqu\'un laisse un retour sur une séance';

  @override
  String get sessionCancelled => 'Séance Annulée';

  @override
  String get sessionCancelledDesc =>
      'Quand une séance que vous avez rejoint est annulée';

  @override
  String get memberJoined => 'Membre Rejoint';

  @override
  String get memberJoinedDesc => 'Quand quelqu\'un rejoint votre groupe';

  @override
  String get memberLeft => 'Membre Parti';

  @override
  String get memberLeftDesc => 'Quand quelqu\'un quitte votre groupe';

  @override
  String get enableQuietHours => 'Activer les Heures Calmes';

  @override
  String get quietHoursDesc => 'Suspendre les notifications à certaines heures';

  @override
  String get adjustQuietHours => 'Ajuster les Heures Calmes';

  @override
  String get setQuietHours => 'Définir les Heures Calmes';

  @override
  String error(String message) {
    return 'Erreur : $message';
  }

  @override
  String get pleaseLogInToAddFriends =>
      'Veuillez vous connecter pour ajouter des amis';

  @override
  String get welcomeBack => 'Bon Retour !';

  @override
  String get signInToContinue =>
      'Connectez-vous pour continuer à organiser vos matchs de volleyball';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get validEmailRequired => 'Veuillez entrer un e-mail valide';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'Invité';

  @override
  String get joinPlayWithMe => 'Rejoignez PlayWithMe !';

  @override
  String get createAccountSubtitle =>
      'Créez votre compte pour commencer à organiser des matchs de volleyball';

  @override
  String get displayNameTooLong =>
      'Le nom d\'affichage doit contenir moins de 50 caractères';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get termsAgreement =>
      'En créant un compte, vous acceptez nos Conditions d\'Utilisation et notre Politique de Confidentialité.';

  @override
  String get forgotYourPassword => 'Mot de Passe Oublié ?';

  @override
  String get forgotPasswordInstructions =>
      'Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetEmail => 'Envoyer l\'E-mail de Réinitialisation';

  @override
  String get resetLinkSentTo =>
      'Nous avons envoyé un lien de réinitialisation à :';

  @override
  String get checkEmailResetInstructions =>
      'Veuillez vérifier votre e-mail et suivre les instructions pour réinitialiser votre mot de passe.';

  @override
  String get noResultsAvailable => 'Aucun résultat disponible pour le moment';

  @override
  String get scoresWillAppear => 'Les scores apparaîtront ici une fois saisis';

  @override
  String get individualGames => 'Matchs Individuels';

  @override
  String get howManyGamesPlayed => 'Combien de matchs avez-vous joués ?';

  @override
  String get assignPlayersToTeams => 'Assigner les Joueurs aux Équipes';

  @override
  String get dragPlayersToAssign =>
      'Faites glisser les joueurs pour les assigner à l\'Équipe A ou B';

  @override
  String get pendingVerification => 'Vérification en Attente';

  @override
  String get youreIn => 'Vous êtes inscrit';

  @override
  String get onWaitlist => 'Sur Liste d\'Attente';

  @override
  String get full => 'Complet';

  @override
  String get joinGame => 'Rejoindre le Match';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get player => 'Joueur';

  @override
  String get noScoresRecorded => 'Aucun score enregistré';

  @override
  String get eloUpdated => 'ELO Mis à Jour';

  @override
  String get vs => 'VS';

  @override
  String get cancelled => 'ANNULÉ';

  @override
  String get joined => 'INSCRIT';

  @override
  String get training => 'Entraînement';

  @override
  String get gameLabel => 'MATCH';

  @override
  String minParticipants(int count) {
    return 'Min : $count';
  }

  @override
  String get selectGameDate => 'Sélectionner la Date du Match';

  @override
  String get selectGameTime => 'Sélectionner l\'Heure du Match';

  @override
  String get pleaseTitleRequired => 'Veuillez entrer un titre de match';

  @override
  String get titleMinLength => 'Le titre doit contenir au moins 3 caractères';

  @override
  String get titleMaxLength => 'Le titre doit contenir moins de 100 caractères';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterLocation => 'Veuillez entrer un lieu';

  @override
  String get notSelected => 'Non sélectionné';

  @override
  String get selectStartDate => 'Sélectionner la Date de Début';

  @override
  String get selectStartTime => 'Sélectionner l\'Heure de Début';

  @override
  String get selectEndTime => 'Sélectionner l\'Heure de Fin';

  @override
  String get participants => 'Participants';

  @override
  String get exercises => 'Exercices';

  @override
  String get feedback => 'Retours';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get players => 'Joueurs';

  @override
  String get competitiveGameWithElo => 'Match compétitif avec classement ELO';

  @override
  String get practiceSessionNoElo => 'Séance d\'entraînement sans impact ELO';

  @override
  String get promoteToAdmin => 'Promouvoir Administrateur';

  @override
  String get promote => 'Promouvoir';

  @override
  String get demoteToMember => 'Rétrograder en Membre';

  @override
  String get demote => 'Rétrograder';

  @override
  String get removeMember => 'Retirer le Membre';

  @override
  String get leaveGroup => 'Quitter le Groupe';

  @override
  String get selectAll => 'Tout Sélectionner';

  @override
  String get clearAll => 'Tout Effacer';

  @override
  String get upload => 'Télécharger';

  @override
  String get avatarUploadedSuccess => 'Avatar téléchargé avec succès';

  @override
  String get avatarRemovedSuccess => 'Avatar supprimé avec succès';

  @override
  String get bestTeammate => 'Meilleur Coéquipier';

  @override
  String get gameNotFound => 'Match Non Trouvé';

  @override
  String get noCompletedGamesYet => 'Aucun match terminé pour le moment';

  @override
  String get gamesWillAppearAfterCompleted =>
      'Les matchs apparaîtront ici une fois terminés';

  @override
  String get finalScore => 'Score Final';

  @override
  String get eloRatingChanges => 'Changements de Classement ELO';

  @override
  String get unknownPlayer => 'Joueur Inconnu';

  @override
  String gameNumber(int number) {
    return 'Match $number';
  }

  @override
  String setsScore(int teamA, int teamB) {
    return 'Sets : $teamA - $teamB';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get format => 'Format :';

  @override
  String get invalidScore => 'Score invalide';

  @override
  String get overallWinnerTeamA => 'Vainqueur Général : Équipe A';

  @override
  String get overallWinnerTeamB => 'Vainqueur Général : Équipe B';

  @override
  String get resultTie => 'Résultat : Égalité';

  @override
  String get saveScores => 'Enregistrer les Scores';

  @override
  String completeGamesToContinue(int current, int total) {
    return 'Terminez $current/$total matchs pour continuer';
  }

  @override
  String get upcomingActivities => 'Activités à Venir';

  @override
  String get pastActivities => 'Activités Passées';

  @override
  String get noUpcomingGamesYet => 'Aucun match à venir pour le moment';

  @override
  String get createFirstGame => 'Créez le premier match !';

  @override
  String get noActivitiesYet => 'Aucune activité pour le moment';

  @override
  String get createFirstActivity => 'Créez la première activité !';

  @override
  String get gamesWon => 'matchs gagnés';

  @override
  String get playerCountSingular => '1 joueur';

  @override
  String playerCountPlural(int count) {
    return '$count joueurs';
  }

  @override
  String wonScoreDescription(String winner, String score) {
    return '$winner a gagné $score';
  }

  @override
  String playersWaitlisted(int count) {
    return '$count en liste d\'attente';
  }

  @override
  String playersCount(int current, int max) {
    return '$current/$max joueurs';
  }

  @override
  String get minParticipantsLabel => 'Min Participants';

  @override
  String get maxParticipantsLabel => 'Max Participants';

  @override
  String get youAreOrganizing => 'Vous organisez';

  @override
  String organizedBy(String name) {
    return 'Organisé par $name';
  }

  @override
  String get scheduled => 'Programmé';

  @override
  String get completed => 'Terminé';

  @override
  String get noParticipantsYet => 'Aucun participant pour le moment';

  @override
  String get beFirstToJoin => 'Soyez le premier à rejoindre !';

  @override
  String get participation => 'Participation';

  @override
  String get current => 'Actuel';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get availableSpots => 'Places Disponibles';

  @override
  String get you => 'Vous';

  @override
  String get joining => 'Inscription...';

  @override
  String get leaving => 'Départ...';

  @override
  String get cannotJoin => 'Impossible de rejoindre';

  @override
  String get allParticipantsNotified =>
      'Tous les participants seront notifiés.';

  @override
  String get feedbackAlreadySubmitted => 'Retour Déjà Soumis';

  @override
  String alreadyProvidedFeedback(String sessionTitle) {
    return 'Vous avez déjà donné votre retour pour \"$sessionTitle\".';
  }

  @override
  String get provideAnonymousFeedback => 'Donner un Retour Anonyme';

  @override
  String get feedbackIsAnonymous =>
      'Votre retour est anonyme et aide à améliorer les futures séances d\'entraînement.';

  @override
  String get exercisesQuality => 'Qualité des Exercices';

  @override
  String get wereDrillsEffective => 'Les exercices étaient-ils efficaces ?';

  @override
  String get trainingIntensity => 'Intensité de l\'Entraînement';

  @override
  String get physicalDemandLevel => 'Niveau d\'exigence physique';

  @override
  String get coachingClarity => 'Clarté du Coaching';

  @override
  String get instructionsAndCorrections => 'Instructions et corrections ?';

  @override
  String get additionalCommentsOptional =>
      'Commentaires Additionnels (Optionnel)';

  @override
  String get shareYourThoughts =>
      'Partagez vos impressions sur la séance, les exercices, ou vos suggestions d\'amélioration...';

  @override
  String get submitFeedback => 'Soumettre le Retour';

  @override
  String get feedbackPrivacyNotice =>
      'Votre retour est complètement anonyme et ne peut pas être retracé jusqu\'à vous.';

  @override
  String get invite => 'Inviter';

  @override
  String get inviteMembers => 'Inviter des Membres';

  @override
  String get adminOnly => 'Admins uniquement';

  @override
  String get create => 'Créer';

  @override
  String get createGameOrTraining =>
      'Créer un match ou une séance d\'entraînement';

  @override
  String get activities => 'Activités';

  @override
  String get viewAllActivities => 'Voir toutes les activités';

  @override
  String get removeFromGroup => 'Retirer du Groupe';

  @override
  String promoteConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir promouvoir $name administrateur ?\n\nLes administrateurs peuvent :\n• Gérer les membres du groupe\n• Inviter de nouveaux membres\n• Modifier les paramètres du groupe';
  }

  @override
  String demoteConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir rétrograder $name en membre simple ?\n\nIl perdra ses privilèges d\'administrateur.';
  }

  @override
  String removeConfirmMessage(String name) {
    return 'Êtes-vous sûr de vouloir retirer $name du groupe ?\n\nCette action est irréversible. Il devra être réinvité pour rejoindre le groupe.';
  }

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return 'Êtes-vous sûr de vouloir quitter \"$groupName\" ?\n\nVous devrez être réinvité pour rejoindre ce groupe.';
  }

  @override
  String get performanceStats => 'Statistiques de Performance';

  @override
  String get eloRatingLabel => 'Classement ELO';

  @override
  String peak(String value) {
    return 'Maximum : $value';
  }

  @override
  String get winRate => 'Taux de victoire';

  @override
  String winsLosses(int wins, int losses) {
    return '${wins}V - ${losses}D';
  }

  @override
  String get streakLabel => 'Série';

  @override
  String get winning => 'Victoires';

  @override
  String get losingStreak => 'Défaites';

  @override
  String get noStreak => 'Aucune';

  @override
  String get gamesPlayedLabel => 'Matchs Joués';

  @override
  String get noPlayersAssigned => 'Aucun joueur assigné';

  @override
  String get unassignedPlayers => 'Joueurs Non Assignés';

  @override
  String get allPlayersAssigned => 'Tous les joueurs sont assignés !';

  @override
  String get saveTeams => 'Enregistrer les Équipes';

  @override
  String get assignAllPlayersToContinue =>
      'Assignez tous les joueurs pour continuer';

  @override
  String invitedBy(String name) {
    return 'Invité par $name';
  }

  @override
  String get errorTitle => 'Erreur';

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
    return 'Voulez-vous rejoindre \"$sessionTitle\" ?\n\nDate : $dateTime\nLieu : $location';
  }

  @override
  String areYouSureLeave(String sessionTitle) {
    return 'Êtes-vous sûr de vouloir quitter \"$sessionTitle\" ?';
  }

  @override
  String cancelSessionConfirm(String sessionTitle) {
    return 'Êtes-vous sûr de vouloir annuler \"$sessionTitle\" ?\n\nTous les participants seront notifiés.';
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
  String get bestPartner => 'Meilleur Partenaire';

  @override
  String get noPartnerDataYet => 'Pas encore de données partenaire';

  @override
  String get playGamesWithTeammate => 'Jouez 5+ matchs avec un coéquipier';

  @override
  String winRatePercent(String rate) {
    return '$rate% de victoires';
  }

  @override
  String gamesCount(int count) {
    return '$count matchs';
  }

  @override
  String winsLossesGames(int wins, int losses, int total) {
    return '${wins}V - ${losses}D • $total matchs';
  }

  @override
  String get momentumAndConsistency => 'Momentum & Régularité';

  @override
  String get eloProgress => 'Progression ELO';

  @override
  String get winStreak => 'Série de victoires';

  @override
  String get lossStreak => 'Série de défaites';

  @override
  String get noActiveStreak => 'Pas de série active';

  @override
  String get winNextGameToStartStreak =>
      'Gagnez votre prochain match pour démarrer une série !';

  @override
  String get rival => 'Rival';

  @override
  String matchups(int count) {
    return '$count confrontations';
  }

  @override
  String winRateLabel(String rate) {
    return 'Taux de victoire : $rate%';
  }

  @override
  String get tapForFullBreakdown => 'Appuyez pour plus de détails';

  @override
  String get noNemesisYet => 'Pas encore de Némésis';

  @override
  String get playGamesAgainstSameOpponent =>
      'Jouez au moins 3 matchs contre le même adversaire pour suivre votre plus difficile confrontation.';

  @override
  String get faceOpponentThreeTimes => 'Affrontez le même adversaire 3+ fois';

  @override
  String get noPerformanceData => 'Pas de données de performance';

  @override
  String get playFirstGameToSeeStats =>
      'Jouez votre premier match pour voir vos statistiques !';

  @override
  String get playAtLeastOneGame => 'Jouez au moins 1 match pour débloquer';

  @override
  String get performanceOverview => 'Aperçu des performances';

  @override
  String get currentElo => 'ELO actuel';

  @override
  String get peakElo => 'ELO maximum';

  @override
  String get gamesPlayed => 'Matchs joués';

  @override
  String get bestWin => 'Meilleure victoire';

  @override
  String get winGameToUnlock => 'Gagnez un match pour débloquer';

  @override
  String get beatOpponentsToTrack =>
      'Battez des adversaires pour suivre vos meilleures victoires';

  @override
  String get avgPointDiff => 'Diff. pts moy.';

  @override
  String get completeGameToUnlock => 'Terminez un match pour débloquer';

  @override
  String get winAndLoseSetsToSee =>
      'Gagnez et perdez des sets pour voir vos marges';

  @override
  String get avgPointDifferential => 'Différence de points moyenne';

  @override
  String get inWins => 'En victoires';

  @override
  String get inLosses => 'En défaites';

  @override
  String setsCount(int count) {
    return '$count sets';
  }

  @override
  String teamLabel(String names) {
    return 'Équipe : $names';
  }

  @override
  String teamEloLabel(String elo) {
    return 'ELO équipe : $elo';
  }

  @override
  String eloGained(String amount) {
    return '$amount ELO gagnés';
  }

  @override
  String get adaptabilityStats => 'Stats d\'adaptabilité';

  @override
  String get advanced => 'Avancé';

  @override
  String get seeHowYouPerform =>
      'Voyez comment vous performez dans différents rôles d\'équipe';

  @override
  String get leadingTheTeam => 'Leader de l\'équipe';

  @override
  String get whenHighestRated => 'Quand vous êtes le joueur le mieux classé';

  @override
  String get playingWithStrongerPartners =>
      'Jouer avec des partenaires plus forts';

  @override
  String get whenMoreExperiencedTeammates =>
      'Quand vous jouez avec des coéquipiers plus expérimentés';

  @override
  String get balancedTeams => 'Équipes équilibrées';

  @override
  String get whenSimilarlyRatedTeammates =>
      'Quand vous jouez avec des coéquipiers de niveau similaire';

  @override
  String get adaptabilityStatsLocked => 'Stats d\'adaptabilité verrouillées';

  @override
  String get playMoreGamesToSeeRoles =>
      'Jouez plus de matchs pour voir comment vous performez dans différents rôles';

  @override
  String get noStatsYet => 'Pas encore de stats';

  @override
  String get startPlayingToSeeStats =>
      'Commencez à jouer pour voir vos statistiques !';

  @override
  String get playGamesToUnlockRankings =>
      'Jouez pour débloquer les classements';

  @override
  String get globalRank => 'Rang Global';

  @override
  String get percentile => 'Percentile';

  @override
  String get friendsRank => 'Rang Amis';

  @override
  String get addFriendsAction => 'Ajouter des amis';

  @override
  String get period30d => '30j';

  @override
  String get period90d => '90j';

  @override
  String get period1y => '1an';

  @override
  String get periodAllTime => 'Tout temps';

  @override
  String get monthlyProgressChart => 'Graphique de progression mensuel';

  @override
  String playAtLeastNGames(int count) {
    return 'Jouez au moins $count matchs';
  }

  @override
  String nOfNGames(int current, int total) {
    return '$current/$total matchs';
  }

  @override
  String get startPlayingToTrackProgress =>
      'Commencez à jouer pour suivre votre progression !';

  @override
  String get keepPlayingToUnlockChart =>
      'Continuez à jouer pour débloquer ce graphique !';

  @override
  String get playGamesOverLongerPeriod => 'Jouez sur une plus longue période';

  @override
  String get keepPlayingToSeeProgress =>
      'Continuez à jouer pour voir votre progression !';

  @override
  String get noGamesInThisPeriod => 'Aucun match sur cette période';

  @override
  String noGamesPlayedInLast(String period) {
    return 'Aucun match joué au cours des $period';
  }

  @override
  String get trySelectingLongerPeriod =>
      'Essayez de sélectionner une période plus longue';

  @override
  String get periodLabel30Days => '30 derniers jours';

  @override
  String get periodLabel90Days => '90 derniers jours';

  @override
  String get periodLabelYear => 'l\'année';

  @override
  String get periodLabelAllTime => 'tout temps';

  @override
  String get bestEloThisMonth => 'Meilleur ELO ce mois';

  @override
  String get bestEloPast90Days => 'Meilleur ELO 90 derniers jours';

  @override
  String get bestEloThisYear => 'Meilleur ELO cette année';

  @override
  String get bestEloAllTime => 'Meilleur ELO de tous les temps';

  @override
  String lastNGames(int count) {
    return '$count derniers matchs';
  }

  @override
  String get noGamesPlayedYet => 'Aucun match joué';

  @override
  String winsStreakCount(int count) {
    return '$count victoires';
  }

  @override
  String lossesStreakCount(int count) {
    return '$count défaites';
  }

  @override
  String get partnerDetailsTitle => 'Détails du partenaire';

  @override
  String get overallRecord => 'Bilan global';

  @override
  String get games => 'Matchs';

  @override
  String get record => 'Bilan';

  @override
  String get pointDifferential => 'Différentiel de points';

  @override
  String get avgPerGame => 'Moy. par match';

  @override
  String get pointsFor => 'Points marqués';

  @override
  String get pointsAgainst => 'Points encaissés';

  @override
  String get eloPerformance => 'Performance ELO';

  @override
  String get totalChange => 'Évolution totale';

  @override
  String get recentForm => 'Forme récente';

  @override
  String streakWins(int count) {
    return '$count V consécutives';
  }

  @override
  String streakLosses(int count) {
    return '$count D consécutives';
  }

  @override
  String get noRecentGames => 'Pas de matchs récents';

  @override
  String eloLabel(String value) {
    return 'ELO : $value';
  }

  @override
  String get nextGame => 'Prochain match';

  @override
  String get noGamesScheduled => 'Aucun match organisé pour le moment';

  @override
  String get nextTrainingSession => 'Prochaine séance d\'entraînement';

  @override
  String get noTrainingSessionsScheduled =>
      'Aucune séance d\'entraînement prévue';

  @override
  String get stats => 'Stats';

  @override
  String get myStats => 'Mes Stats';

  @override
  String get generateInviteLink => 'Générer un lien d\'invitation';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get shareLink => 'Partager';

  @override
  String get linkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get inviteLinkSectionTitle => 'Inviter des membres';

  @override
  String get inviteLinkDescription =>
      'Partagez ce lien pour inviter des personnes à rejoindre le groupe.';

  @override
  String get revokeInvite => 'Révoquer l\'invitation';

  @override
  String get inviteRevoked => 'Lien d\'invitation révoqué';

  @override
  String get generateInviteError =>
      'Impossible de générer le lien d\'invitation';

  @override
  String get revokeInviteError =>
      'Impossible de révoquer le lien d\'invitation';

  @override
  String inviteLinkShareMessage(String url) {
    return 'Rejoins mon groupe sur PlayWithMe ! $url';
  }

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get pageNotFoundMessage => 'La page demandée est introuvable.';

  @override
  String get inviteOnboardingTitle => 'Vous êtes invité !';

  @override
  String get inviteOnboardingSubtitle => 'Vous êtes invité à rejoindre :';

  @override
  String get iHaveAnAccount => 'J\'ai un compte';

  @override
  String get joinGroup => 'Rejoindre le groupe';

  @override
  String get joinGroupConfirmation => 'Rejoindre le groupe ?';

  @override
  String membersCount(int count) {
    return '$count membres';
  }

  @override
  String get inviteExpired => 'Ce lien d\'invitation a expiré';

  @override
  String get inviteLinkRevoked => 'Ce lien d\'invitation n\'est plus valide';

  @override
  String get inviteLimitReached =>
      'Ce lien d\'invitation a atteint sa limite d\'utilisation';

  @override
  String groupJoinedSuccess(String groupName) {
    return 'Bienvenue dans $groupName !';
  }

  @override
  String get alreadyAMember => 'Vous êtes déjà membre de ce groupe';

  @override
  String get continueToApp => 'Continuer vers l\'application';

  @override
  String get validatingInvite => 'Validation de l\'invitation...';

  @override
  String get joiningGroup => 'Rejoint le groupe...';

  @override
  String get createAccountToJoin => 'Créez votre compte pour rejoindre :';

  @override
  String get fullNameHint => 'Nom complet';

  @override
  String get fullNameRequired => 'Le nom complet est requis';

  @override
  String get fullNameTooShort =>
      'Le nom complet doit comporter au moins 2 caractères';

  @override
  String get displayNameHintRequired => 'Nom d\'affichage';

  @override
  String get displayNameRequired => 'Le nom d\'affichage est requis';

  @override
  String get displayNameTooShortInvite =>
      'Le nom d\'affichage doit comporter au moins 3 caractères';

  @override
  String get displayNameTooLongInvite =>
      'Le nom d\'affichage doit comporter au maximum 30 caractères';

  @override
  String get passwordRequirementsHint =>
      'Au moins 8 caractères, 1 majuscule, 1 chiffre';

  @override
  String get passwordTooShortInvite =>
      'Le mot de passe doit comporter au moins 8 caractères';

  @override
  String get passwordMissingUppercase =>
      'Le mot de passe doit contenir au moins 1 majuscule';

  @override
  String get passwordMissingNumber =>
      'Le mot de passe doit contenir au moins 1 chiffre';

  @override
  String get createAccountAndJoin => 'Créer un compte et rejoindre';

  @override
  String get alreadyHaveAccountLogin =>
      'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get accountCreatedJoiningGroup =>
      'Compte créé ! Rejoindre le groupe...';

  @override
  String get inviteExpiredDuringRegistration =>
      'Le lien d\'invitation a expiré, mais votre compte a été créé avec succès.';

  @override
  String get emailAlreadyInUse =>
      'Un compte avec cet email existe déjà. Essayez de vous connecter.';

  @override
  String get weakPasswordError =>
      'Le mot de passe est trop faible. Utilisez au moins 8 caractères.';

  @override
  String get invalidEmailError => 'Veuillez entrer une adresse email valide.';

  @override
  String get networkError =>
      'Impossible de se connecter. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get creatingAccount => 'Création du compte...';

  @override
  String verifyEmailWarning(int daysRemaining) {
    return 'Vérifiez votre email pour conserver votre compte. $daysRemaining jours restants.';
  }

  @override
  String get verifyNow => 'Vérifier maintenant';

  @override
  String get dismiss => 'Fermer';

  @override
  String get emailVerifiedSuccess => 'Email vérifié avec succès !';
}
