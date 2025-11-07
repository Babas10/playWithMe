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
}
