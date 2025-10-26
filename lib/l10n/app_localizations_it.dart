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
}
