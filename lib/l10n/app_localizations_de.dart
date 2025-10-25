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
}
