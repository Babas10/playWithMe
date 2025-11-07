// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlayWithMe';

  @override
  String get welcomeMessage => '¡Bienvenido a PlayWithMe!';

  @override
  String get beachVolleyballOrganizer =>
      'Organizador de partidos de voleibol de playa';

  @override
  String get firebaseConnected => 'Conectado';

  @override
  String get firebaseDisconnected => 'Desconectado';

  @override
  String get firebase => 'Firebase';

  @override
  String get environment => 'Entorno';

  @override
  String get project => 'Proyecto';

  @override
  String get loading => 'Cargando...';

  @override
  String get profile => 'Perfil';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get accountSettings => 'Configuración de Cuenta';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get displayName => 'Nombre para Mostrar';

  @override
  String get language => 'Idioma';

  @override
  String get country => 'País';

  @override
  String get timezone => 'Zona Horaria';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get settingsUpdatedSuccessfully =>
      'Configuración actualizada exitosamente';

  @override
  String get removeAvatar => 'Eliminar Avatar';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de Galería';

  @override
  String get confirmRemoveAvatar =>
      '¿Estás seguro de que quieres eliminar tu avatar?';

  @override
  String get remove => 'Eliminar';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get forgotPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get unsavedChangesTitle => 'Cambios No Guardados';

  @override
  String get unsavedChangesMessage =>
      'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?';

  @override
  String get discard => 'Descartar';

  @override
  String get displayNameHint => 'Ingresa tu nombre para mostrar';

  @override
  String get preferredLanguage => 'Idioma Preferido';

  @override
  String get saving => 'Guardando...';

  @override
  String get stay => 'Quedarse';

  @override
  String get accountInformation => 'Información de la Cuenta';

  @override
  String get verify => 'Verificar';

  @override
  String get accountType => 'Tipo de Cuenta';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get regular => 'Regular';

  @override
  String get memberSince => 'Miembro Desde';

  @override
  String get lastActive => 'Última Actividad';

  @override
  String get signOutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get pleaseLogIn => 'Por favor inicia sesión para ver tu perfil';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get myGroups => 'Mis Grupos';

  @override
  String get pleaseLogInToViewGroups =>
      'Por favor inicia sesión para ver tus grupos';

  @override
  String get errorLoadingGroups => 'Error al Cargar Grupos';

  @override
  String get retry => 'Reintentar';

  @override
  String get createGroup => 'Crear Grupo';

  @override
  String get groupDetailsComingSoon =>
      '¡Página de detalles del grupo próximamente!';

  @override
  String get noGroupsYet => 'Aún no eres parte de ningún grupo';

  @override
  String get noGroupsMessage =>
      '¡Crea o únete a grupos para comenzar a organizar partidos de voleibol de playa con tus amigos!';

  @override
  String memberCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get publicGroup => 'Público';

  @override
  String get inviteOnlyGroup => 'Solo por Invitación';

  @override
  String get privateGroup => 'Privado';

  @override
  String get createYourFirstGroup => 'Crea Tu Primer Grupo';

  @override
  String get useCreateGroupButton =>
      'Usa el botón Crear Grupo a continuación para comenzar.';

  @override
  String get home => 'Inicio';

  @override
  String get groups => 'Grupos';

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
