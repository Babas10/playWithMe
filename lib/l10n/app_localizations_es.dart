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
  String get community => 'Comunidad';

  @override
  String get myCommunity => 'Mi Comunidad';

  @override
  String get friends => 'Amigos';

  @override
  String get requests => 'Solicitudes';

  @override
  String get noFriendsYet => 'Aún no tienes amigos';

  @override
  String get searchForFriends => '¡Busca amigos para comenzar!';

  @override
  String get noPendingRequests => 'No hay solicitudes de amistad pendientes';

  @override
  String get receivedRequests => 'Solicitudes Recibidas';

  @override
  String get sentRequests => 'Solicitudes Enviadas';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get pending => 'Pendiente';

  @override
  String get removeFriend => '¿Eliminar Amigo?';

  @override
  String removeFriendConfirmation(String name) {
    return '¿Estás seguro de que quieres eliminar a $name de tus amigos?';
  }

  @override
  String get errorLoadingFriends => 'Error al cargar amigos';

  @override
  String get searchFriendsByEmail => 'Buscar amigos por correo electrónico...';

  @override
  String get cannotAddYourself => 'No puedes agregarte a ti mismo como amigo';

  @override
  String userNotFoundWithEmail(String email) {
    return 'No se encontró ningún usuario con el correo: $email';
  }

  @override
  String get makeSureEmailCorrect => 'Asegúrate de que el correo sea correcto';

  @override
  String get requestPending => 'Pendiente';

  @override
  String get acceptRequest => 'Aceptar Solicitud';

  @override
  String get sendFriendRequest => 'Agregar';

  @override
  String get search => 'Buscar';

  @override
  String get addFriend => 'Agregar Amigo';

  @override
  String get searchForFriendsToAdd => 'Buscar amigos para agregar';

  @override
  String get enterEmailToFindFriends =>
      'Ingrese una dirección de correo para encontrar usuarios';

  @override
  String get checkRequestsTab =>
      'Consulta la pestaña Solicitudes para aceptar la solicitud de amistad';

  @override
  String get ok => 'OK';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? ';

  @override
  String get signUp => 'Registrarse';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get backToLogin => 'Volver al Inicio de Sesión';

  @override
  String get emailSent => '¡Correo Enviado!';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get accountCreatedSuccess =>
      '¡Cuenta creada exitosamente! Revisa tu correo para verificar.';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get emailHint => 'Correo Electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get displayNameOptionalHint => 'Nombre para Mostrar (Opcional)';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get createGame => 'Crear Partido';

  @override
  String get gameCreatedSuccess => '¡Partido creado exitosamente!';

  @override
  String get pleaseLogInToCreateGame => 'Inicia sesión para crear un partido';

  @override
  String get group => 'Grupo';

  @override
  String get dateTime => 'Fecha y Hora';

  @override
  String get tapToSelect => 'Toca para seleccionar';

  @override
  String get gameDetails => 'Detalles del Partido';

  @override
  String get goBack => 'Volver';

  @override
  String get organizer => 'Organizador';

  @override
  String get enterResults => 'Ingresar Resultados';

  @override
  String get leaveGame => 'Abandonar Partido';

  @override
  String get leaveWaitlist => 'Abandonar Lista de Espera';

  @override
  String get confirm => 'Confirmar';

  @override
  String get editDispute => 'Editar / Disputar';

  @override
  String get filterGames => 'Filtrar Partidos';

  @override
  String get allGames => 'Todos los Partidos';

  @override
  String get myGamesOnly => 'Solo Mis Partidos';

  @override
  String get gameHistory => 'Historial de Partidos';

  @override
  String get selectFiltersToView => 'Selecciona filtros para ver el historial';

  @override
  String get activeFilters => 'Filtros activos: ';

  @override
  String get myGames => 'Mis Partidos';

  @override
  String get gameResults => 'Resultados del Partido';

  @override
  String groupNameGames(String groupName) {
    return 'Partidos de $groupName';
  }

  @override
  String get recordResults => 'Registrar Resultados';

  @override
  String get teamsSavedSuccess => 'Equipos guardados exitosamente';

  @override
  String get teamA => 'Equipo A';

  @override
  String get teamB => 'Equipo B';

  @override
  String get enterScores => 'Ingresar Puntos';

  @override
  String get scoresSavedSuccess => '¡Puntos guardados exitosamente!';

  @override
  String get savingScores => 'Guardando puntos...';

  @override
  String get oneSet => '1 Set';

  @override
  String get bestOfTwo => 'Mejor de 2';

  @override
  String get bestOfThree => 'Mejor de 3';

  @override
  String get gameTitle => 'Título del Partido';

  @override
  String get gameTitleHint => 'ej. Voleibol de Playa';

  @override
  String get descriptionOptional => 'Descripción (Opcional)';

  @override
  String get gameDescriptionHint => 'Agregar detalles sobre el partido...';

  @override
  String get location => 'Ubicación';

  @override
  String get locationHint => 'ej. Playa de Barcelona';

  @override
  String get addressOptional => 'Dirección (Opcional)';

  @override
  String get addressHint => 'Dirección completa...';

  @override
  String get filter => 'Filtrar';

  @override
  String get dateRange => 'Rango de Fechas';

  @override
  String get removeFromTeam => 'Quitar del equipo';

  @override
  String get clearFilter => 'Limpiar filtro';

  @override
  String get filterByDate => 'Filtrar por fecha';

  @override
  String get groupNameRequired => 'Nombre del Grupo *';

  @override
  String get groupNameHint => 'ej. Equipo Beach Volley';

  @override
  String get groupDescriptionHint =>
      'ej. Partidos semanales de voleibol de playa';

  @override
  String get pleaseSelectStartTimeFirst =>
      'Primero selecciona la hora de inicio';

  @override
  String get pleaseSelectStartTime => 'Selecciona la hora de inicio';

  @override
  String get pleaseSelectEndTime => 'Selecciona la hora de fin';

  @override
  String get trainingCreatedSuccess => '¡Entrenamiento creado exitosamente!';

  @override
  String get createTrainingSession => 'Crear Entrenamiento';

  @override
  String get pleaseLogInToCreateTraining =>
      'Inicia sesión para crear un entrenamiento';

  @override
  String get startTime => 'Hora de Inicio';

  @override
  String get endTime => 'Hora de Fin';

  @override
  String get title => 'Título';

  @override
  String get trainingSession => 'Entrenamiento';

  @override
  String get trainingNotFound => 'Entrenamiento no encontrado';

  @override
  String get trainingCancelled => 'Entrenamiento cancelado';

  @override
  String get errorLoadingParticipants => 'Error al cargar participantes';

  @override
  String get joinedTrainingSuccess =>
      '¡Te uniste al entrenamiento exitosamente!';

  @override
  String get leftTraining => 'Has dejado el entrenamiento';

  @override
  String get joinTrainingSession => 'Unirse al Entrenamiento';

  @override
  String get join => 'Unirse';

  @override
  String get leaveTrainingSession => 'Dejar Entrenamiento';

  @override
  String get leave => 'Dejar';

  @override
  String get cancelTrainingSession => '¿Cancelar Entrenamiento?';

  @override
  String get keepSession => 'Mantener Entrenamiento';

  @override
  String get cancelSession => 'Cancelar Entrenamiento';

  @override
  String get sessionFeedback => 'Comentarios del Entrenamiento';

  @override
  String get thankYouFeedback => '¡Gracias por tus comentarios!';

  @override
  String get backToSession => 'Volver al Entrenamiento';

  @override
  String get needsWork => 'Necesita mejorar';

  @override
  String get topLevelTraining => 'Entrenamiento de alto nivel';

  @override
  String get pleaseRateAllCategories =>
      'Califica las tres categorías antes de enviar';

  @override
  String get emailVerification => 'Verificación de Correo';

  @override
  String verificationEmailSent(String email) {
    return 'Correo de verificación enviado a $email';
  }

  @override
  String get backToProfile => 'Volver al Perfil';

  @override
  String get sendVerificationEmail => 'Enviar Correo de Verificación';

  @override
  String get refreshStatus => 'Actualizar Estado';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get eloHistory => 'Historial ELO';

  @override
  String get gameDetailsComingSoon => '¡Detalles del partido próximamente!';

  @override
  String get headToHead => 'Cara a Cara';

  @override
  String get partnerDetails => 'Detalles del Compañero';

  @override
  String get invitations => 'Invitaciones';

  @override
  String get pleaseLogInToViewInvitations =>
      'Inicia sesión para ver invitaciones';

  @override
  String get pendingInvitations => 'Invitaciones Pendientes';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get groupInvitations => 'Invitaciones de Grupo';

  @override
  String get groupInvitationsDesc => 'Cuando alguien te invita a un grupo';

  @override
  String get invitationAccepted => 'Invitación Aceptada';

  @override
  String get invitationAcceptedDesc => 'Cuando alguien acepta tu invitación';

  @override
  String get newGames => 'Nuevos Partidos';

  @override
  String get newGamesDesc => 'Cuando se crea un nuevo partido en tus grupos';

  @override
  String get roleChanges => 'Cambios de Rol';

  @override
  String get roleChangesDesc => 'Cuando te ascienden a administrador';

  @override
  String get newTrainingSessions => 'Nuevos Entrenamientos';

  @override
  String get newTrainingSessionsDesc =>
      'Cuando se crea un entrenamiento en tus grupos';

  @override
  String get minParticipantsReached => 'Mínimo de Participantes Alcanzado';

  @override
  String get minParticipantsReachedDesc =>
      'Cuando un entrenamiento tiene suficientes participantes';

  @override
  String get feedbackReceived => 'Comentarios Recibidos';

  @override
  String get feedbackReceivedDesc =>
      'Cuando alguien deja comentarios en un entrenamiento';

  @override
  String get sessionCancelled => 'Entrenamiento Cancelado';

  @override
  String get sessionCancelledDesc =>
      'Cuando un entrenamiento al que te uniste es cancelado';

  @override
  String get memberJoined => 'Miembro Se Unió';

  @override
  String get memberJoinedDesc => 'Cuando alguien se une a tu grupo';

  @override
  String get memberLeft => 'Miembro Se Fue';

  @override
  String get memberLeftDesc => 'Cuando alguien deja tu grupo';

  @override
  String get enableQuietHours => 'Activar Horas de Silencio';

  @override
  String get quietHoursDesc => 'Pausar notificaciones en horarios específicos';

  @override
  String get adjustQuietHours => 'Ajustar Horas de Silencio';

  @override
  String get setQuietHours => 'Establecer Horas de Silencio';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get pleaseLogInToAddFriends => 'Inicia sesión para agregar amigos';

  @override
  String get welcomeBack => '¡Bienvenido de Nuevo!';

  @override
  String get signInToContinue =>
      'Inicia sesión para continuar organizando tus partidos de voleibol';

  @override
  String get emailRequired => 'El correo electrónico es requerido';

  @override
  String get validEmailRequired => 'Por favor ingresa un correo válido';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String get continueAsGuest => 'Continuar como Invitado';

  @override
  String get joinPlayWithMe => '¡Únete a PlayWithMe!';

  @override
  String get createAccountSubtitle =>
      'Crea tu cuenta para empezar a organizar partidos de voleibol';

  @override
  String get displayNameTooLong =>
      'El nombre para mostrar debe tener menos de 50 caracteres';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get termsAgreement =>
      'Al crear una cuenta, aceptas nuestros Términos de Servicio y Política de Privacidad.';

  @override
  String get forgotYourPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get forgotPasswordInstructions =>
      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get sendResetEmail => 'Enviar Correo de Restablecimiento';

  @override
  String get resetLinkSentTo =>
      'Hemos enviado un enlace de restablecimiento a:';

  @override
  String get checkEmailResetInstructions =>
      'Por favor revisa tu correo y sigue las instrucciones para restablecer tu contraseña.';

  @override
  String get noResultsAvailable => 'Aún no hay resultados disponibles';

  @override
  String get scoresWillAppear =>
      'Los puntajes aparecerán aquí una vez que se ingresen';

  @override
  String get individualGames => 'Partidos Individuales';

  @override
  String get howManyGamesPlayed => '¿Cuántos partidos jugaste?';

  @override
  String get assignPlayersToTeams => 'Asignar Jugadores a Equipos';

  @override
  String get dragPlayersToAssign =>
      'Arrastra jugadores para asignarlos al Equipo A o B';

  @override
  String get pendingVerification => 'Verificación Pendiente';

  @override
  String get youreIn => 'Estás Inscrito';

  @override
  String get onWaitlist => 'En Lista de Espera';

  @override
  String get full => 'Lleno';

  @override
  String get joinGame => 'Unirse al Partido';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get player => 'Jugador';

  @override
  String get noScoresRecorded => 'Sin puntajes registrados';

  @override
  String get eloUpdated => 'ELO Actualizado';

  @override
  String get vs => 'VS';

  @override
  String get cancelled => 'CANCELADO';

  @override
  String get joined => 'INSCRITO';

  @override
  String get training => 'Entrenamiento';

  @override
  String get gameLabel => 'PARTIDO';

  @override
  String minParticipants(int count) {
    return 'Mín: $count';
  }

  @override
  String get selectGameDate => 'Seleccionar Fecha del Partido';

  @override
  String get selectGameTime => 'Seleccionar Hora del Partido';

  @override
  String get pleaseTitleRequired => 'Por favor ingresa un título de partido';

  @override
  String get titleMinLength => 'El título debe tener al menos 3 caracteres';

  @override
  String get titleMaxLength => 'El título debe tener menos de 100 caracteres';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get pleaseEnterLocation => 'Por favor ingresa una ubicación';

  @override
  String get notSelected => 'No seleccionado';

  @override
  String get selectStartDate => 'Seleccionar Fecha de Inicio';

  @override
  String get selectStartTime => 'Seleccionar Hora de Inicio';

  @override
  String get selectEndTime => 'Seleccionar Hora de Fin';

  @override
  String get participants => 'Participantes';

  @override
  String get exercises => 'Ejercicios';

  @override
  String get feedback => 'Comentarios';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get players => 'Jugadores';

  @override
  String get competitiveGameWithElo =>
      'Partido competitivo con clasificación ELO';

  @override
  String get practiceSessionNoElo => 'Sesión de práctica sin impacto en ELO';

  @override
  String get promoteToAdmin => 'Promover a Administrador';

  @override
  String get promote => 'Promover';

  @override
  String get demoteToMember => 'Degradar a Miembro';

  @override
  String get demote => 'Degradar';

  @override
  String get removeMember => 'Eliminar Miembro';

  @override
  String get leaveGroup => 'Abandonar Grupo';

  @override
  String get selectAll => 'Seleccionar Todo';

  @override
  String get clearAll => 'Limpiar Todo';

  @override
  String get upload => 'Subir';

  @override
  String get avatarUploadedSuccess => 'Avatar subido exitosamente';

  @override
  String get avatarRemovedSuccess => 'Avatar eliminado exitosamente';

  @override
  String get bestTeammate => 'Mejor Compañero';

  @override
  String get gameNotFound => 'Partido No Encontrado';

  @override
  String get noCompletedGamesYet => 'Aún no hay partidos completados';

  @override
  String get gamesWillAppearAfterCompleted =>
      'Los partidos aparecerán aquí una vez completados';

  @override
  String get finalScore => 'Puntaje Final';

  @override
  String get eloRatingChanges => 'Cambios de Clasificación ELO';

  @override
  String get unknownPlayer => 'Jugador Desconocido';

  @override
  String gameNumber(int number) {
    return 'Partido $number';
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
  String get format => 'Formato:';

  @override
  String get invalidScore => 'Puntaje inválido';

  @override
  String get overallWinnerTeamA => 'Ganador General: Equipo A';

  @override
  String get overallWinnerTeamB => 'Ganador General: Equipo B';

  @override
  String get resultTie => 'Resultado: Empate';

  @override
  String get saveScores => 'Guardar Puntajes';

  @override
  String completeGamesToContinue(int current, int total) {
    return 'Completa $current/$total partidos para continuar';
  }

  @override
  String get upcomingActivities => 'Actividades Próximas';

  @override
  String get pastActivities => 'Actividades Pasadas';

  @override
  String get noUpcomingGamesYet => 'Aún no hay partidos próximos';

  @override
  String get createFirstGame => '¡Crea el primer partido!';

  @override
  String get noActivitiesYet => 'Aún no hay actividades';

  @override
  String get createFirstActivity => '¡Crea la primera actividad!';

  @override
  String get gamesWon => 'partidos ganados';

  @override
  String get playerCountSingular => '1 jugador';

  @override
  String playerCountPlural(int count) {
    return '$count jugadores';
  }

  @override
  String wonScoreDescription(String winner, String score) {
    return '$winner ganó $score';
  }

  @override
  String playersWaitlisted(int count) {
    return '$count en lista de espera';
  }

  @override
  String playersCount(int current, int max) {
    return '$current/$max jugadores';
  }

  @override
  String get minParticipantsLabel => 'Mín Participantes';

  @override
  String get maxParticipantsLabel => 'Máx Participantes';

  @override
  String get youAreOrganizing => 'Estás organizando';

  @override
  String organizedBy(String name) {
    return 'Organizado por $name';
  }

  @override
  String get scheduled => 'Programado';

  @override
  String get completed => 'Completado';

  @override
  String get noParticipantsYet => 'Sin participantes aún';

  @override
  String get beFirstToJoin => '¡Sé el primero en unirte!';

  @override
  String get participation => 'Participación';

  @override
  String get current => 'Actual';

  @override
  String get minimum => 'Mínimo';

  @override
  String get maximum => 'Máximo';

  @override
  String get availableSpots => 'Lugares Disponibles';

  @override
  String get you => 'Tú';

  @override
  String get joining => 'Uniéndose...';

  @override
  String get leaving => 'Saliendo...';

  @override
  String get cannotJoin => 'No se puede unir';

  @override
  String get allParticipantsNotified =>
      'Todos los participantes serán notificados.';

  @override
  String get feedbackAlreadySubmitted => 'Comentarios Ya Enviados';

  @override
  String alreadyProvidedFeedback(String sessionTitle) {
    return 'Ya has proporcionado comentarios para \"$sessionTitle\".';
  }

  @override
  String get provideAnonymousFeedback => 'Proporcionar Comentarios Anónimos';

  @override
  String get feedbackIsAnonymous =>
      'Tus comentarios son anónimos y ayudan a mejorar futuros entrenamientos.';

  @override
  String get exercisesQuality => 'Calidad de los Ejercicios';

  @override
  String get wereDrillsEffective => '¿Fueron efectivos los ejercicios?';

  @override
  String get trainingIntensity => 'Intensidad del Entrenamiento';

  @override
  String get physicalDemandLevel => 'Nivel de exigencia física';

  @override
  String get coachingClarity => 'Claridad del Entrenador';

  @override
  String get instructionsAndCorrections => '¿Instrucciones y correcciones?';

  @override
  String get additionalCommentsOptional => 'Comentarios Adicionales (Opcional)';

  @override
  String get shareYourThoughts =>
      'Comparte tus pensamientos sobre la sesión, los ejercicios, o sugerencias de mejora...';

  @override
  String get submitFeedback => 'Enviar Comentarios';

  @override
  String get feedbackPrivacyNotice =>
      'Tus comentarios son completamente anónimos y no pueden ser rastreados hasta ti.';

  @override
  String get invite => 'Invitar';

  @override
  String get inviteMembers => 'Invitar Miembros';

  @override
  String get adminOnly => 'Solo administradores';

  @override
  String get create => 'Crear';

  @override
  String get createGameOrTraining => 'Crear partido o entrenamiento';

  @override
  String get activities => 'Actividades';

  @override
  String get viewAllActivities => 'Ver todas las actividades';

  @override
  String get removeFromGroup => 'Quitar del Grupo';

  @override
  String promoteConfirmMessage(String name) {
    return '¿Estás seguro de que quieres promover a $name a administrador?\n\nLos administradores pueden:\n• Gestionar miembros del grupo\n• Invitar nuevos miembros\n• Modificar configuración del grupo';
  }

  @override
  String demoteConfirmMessage(String name) {
    return '¿Estás seguro de que quieres degradar a $name a miembro regular?\n\nPerderá los privilegios de administrador.';
  }

  @override
  String removeConfirmMessage(String name) {
    return '¿Estás seguro de que quieres quitar a $name del grupo?\n\nEsta acción no se puede deshacer. Tendrá que ser invitado nuevamente.';
  }

  @override
  String leaveGroupConfirmMessage(String groupName) {
    return '¿Estás seguro de que quieres abandonar \"$groupName\"?\n\nNecesitarás ser invitado nuevamente para unirte a este grupo.';
  }

  @override
  String get performanceStats => 'Estadísticas de Rendimiento';

  @override
  String get eloRatingLabel => 'Clasificación ELO';

  @override
  String peak(String value) {
    return 'Máximo: $value';
  }

  @override
  String get winRate => 'Tasa de victoria';

  @override
  String winsLosses(int wins, int losses) {
    return '${wins}V - ${losses}D';
  }

  @override
  String get streakLabel => 'Racha';

  @override
  String get winning => 'Victorias';

  @override
  String get losingStreak => 'Derrotas';

  @override
  String get noStreak => 'Ninguna';

  @override
  String get gamesPlayedLabel => 'Partidos Jugados';

  @override
  String get noPlayersAssigned => 'Sin jugadores asignados';

  @override
  String get unassignedPlayers => 'Jugadores No Asignados';

  @override
  String get allPlayersAssigned => '¡Todos los jugadores asignados!';

  @override
  String get saveTeams => 'Guardar Equipos';

  @override
  String get assignAllPlayersToContinue =>
      'Asigna todos los jugadores para continuar';

  @override
  String invitedBy(String name) {
    return 'Invitado por $name';
  }

  @override
  String get errorTitle => 'Error';

  @override
  String participantsCount(int current, int max) {
    return '$current/$max participantes';
  }

  @override
  String doYouWantToJoin(
    String sessionTitle,
    String dateTime,
    String location,
  ) {
    return '¿Quieres unirte a \"$sessionTitle\"?\n\nFecha: $dateTime\nUbicación: $location';
  }

  @override
  String areYouSureLeave(String sessionTitle) {
    return '¿Estás seguro de que quieres dejar \"$sessionTitle\"?';
  }

  @override
  String cancelSessionConfirm(String sessionTitle) {
    return '¿Estás seguro de que quieres cancelar \"$sessionTitle\"?\n\nTodos los participantes serán notificados.';
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
  String get bestPartner => 'Mejor Compañero';

  @override
  String get noPartnerDataYet => 'Aún sin datos de compañero';

  @override
  String get playGamesWithTeammate => 'Juega 5+ partidos con un compañero';

  @override
  String winRatePercent(String rate) {
    return '$rate% de victorias';
  }

  @override
  String gamesCount(int count) {
    return '$count partidos';
  }

  @override
  String winsLossesGames(int wins, int losses, int total) {
    return '${wins}V - ${losses}D • $total partidos';
  }

  @override
  String get momentumAndConsistency => 'Momentum y Consistencia';

  @override
  String get eloProgress => 'Progreso ELO';

  @override
  String get winStreak => 'Racha de victorias';

  @override
  String get lossStreak => 'Racha de derrotas';

  @override
  String get noActiveStreak => 'Sin racha activa';

  @override
  String get winNextGameToStartStreak =>
      '¡Gana tu próximo partido para iniciar una racha!';

  @override
  String get rival => 'Rival';

  @override
  String matchups(int count) {
    return '$count enfrentamientos';
  }

  @override
  String winRateLabel(String rate) {
    return 'Tasa de victoria: $rate%';
  }

  @override
  String get tapForFullBreakdown => 'Toca para ver detalles';

  @override
  String get noNemesisYet => 'Sin Némesis aún';

  @override
  String get playGamesAgainstSameOpponent =>
      'Juega al menos 3 partidos contra el mismo oponente para seguir tu enfrentamiento más difícil.';

  @override
  String get faceOpponentThreeTimes => 'Enfrenta al mismo oponente 3+ veces';

  @override
  String get noPerformanceData => 'Sin datos de rendimiento';

  @override
  String get playFirstGameToSeeStats =>
      '¡Juega tu primer partido para ver tus estadísticas!';

  @override
  String get playAtLeastOneGame => 'Juega al menos 1 partido para desbloquear';

  @override
  String get performanceOverview => 'Resumen de rendimiento';

  @override
  String get currentElo => 'ELO actual';

  @override
  String get peakElo => 'ELO máximo';

  @override
  String get gamesPlayed => 'Partidos jugados';

  @override
  String get bestWin => 'Mejor victoria';

  @override
  String get winGameToUnlock => 'Gana un partido para desbloquear';

  @override
  String get beatOpponentsToTrack =>
      'Vence oponentes para seguir tus mejores victorias';

  @override
  String get avgPointDiff => 'Dif. puntos prom.';

  @override
  String get completeGameToUnlock => 'Completa un partido para desbloquear';

  @override
  String get winAndLoseSetsToSee => 'Gana y pierde sets para ver tus márgenes';

  @override
  String get avgPointDifferential => 'Diferencia de puntos promedio';

  @override
  String get inWins => 'En victorias';

  @override
  String get inLosses => 'En derrotas';

  @override
  String setsCount(int count) {
    return '$count sets';
  }

  @override
  String teamLabel(String names) {
    return 'Equipo: $names';
  }

  @override
  String teamEloLabel(String elo) {
    return 'ELO del equipo: $elo';
  }

  @override
  String eloGained(String amount) {
    return '$amount ELO ganados';
  }

  @override
  String get adaptabilityStats => 'Stats de adaptabilidad';

  @override
  String get advanced => 'Avanzado';

  @override
  String get seeHowYouPerform =>
      'Mira cómo te desempeñas en diferentes roles de equipo';

  @override
  String get leadingTheTeam => 'Liderando el equipo';

  @override
  String get whenHighestRated => 'Cuando eres el jugador mejor clasificado';

  @override
  String get playingWithStrongerPartners =>
      'Jugando con compañeros más fuertes';

  @override
  String get whenMoreExperiencedTeammates =>
      'Cuando juegas con compañeros más experimentados';

  @override
  String get balancedTeams => 'Equipos equilibrados';

  @override
  String get whenSimilarlyRatedTeammates =>
      'Cuando juegas con compañeros de nivel similar';

  @override
  String get adaptabilityStatsLocked => 'Stats de adaptabilidad bloqueadas';

  @override
  String get playMoreGamesToSeeRoles =>
      'Juega más partidos para ver cómo te desempeñas en diferentes roles';

  @override
  String get noStatsYet => 'Sin stats aún';

  @override
  String get startPlayingToSeeStats =>
      '¡Empieza a jugar para ver tus estadísticas!';

  @override
  String get playGamesToUnlockRankings => 'Juega para desbloquear rankings';

  @override
  String get globalRank => 'Ranking Global';

  @override
  String get percentile => 'Percentil';

  @override
  String get friendsRank => 'Ranking Amigos';

  @override
  String get addFriendsAction => 'Añadir amigos';

  @override
  String get period30d => '30d';

  @override
  String get period90d => '90d';

  @override
  String get period1y => '1a';

  @override
  String get periodAllTime => 'Todo';

  @override
  String get monthlyProgressChart => 'Gráfico de progreso mensual';

  @override
  String playAtLeastNGames(int count) {
    return 'Juega al menos $count partidos';
  }

  @override
  String nOfNGames(int current, int total) {
    return '$current/$total partidos';
  }

  @override
  String get startPlayingToTrackProgress =>
      '¡Empieza a jugar para seguir tu progreso!';

  @override
  String get keepPlayingToUnlockChart =>
      '¡Sigue jugando para desbloquear este gráfico!';

  @override
  String get playGamesOverLongerPeriod => 'Juega durante un período más largo';

  @override
  String get keepPlayingToSeeProgress => '¡Sigue jugando para ver tu progreso!';

  @override
  String get noGamesInThisPeriod => 'Sin partidos en este período';

  @override
  String noGamesPlayedInLast(String period) {
    return 'Sin partidos en los últimos $period';
  }

  @override
  String get trySelectingLongerPeriod =>
      'Intenta seleccionar un período más largo';

  @override
  String get periodLabel30Days => '30 días';

  @override
  String get periodLabel90Days => '90 días';

  @override
  String get periodLabelYear => 'año';

  @override
  String get periodLabelAllTime => 'todo el tiempo';

  @override
  String get bestEloThisMonth => 'Mejor ELO este mes';

  @override
  String get bestEloPast90Days => 'Mejor ELO últimos 90 días';

  @override
  String get bestEloThisYear => 'Mejor ELO este año';

  @override
  String get bestEloAllTime => 'Mejor ELO de todos los tiempos';

  @override
  String lastNGames(int count) {
    return 'Últimos $count partidos';
  }

  @override
  String get noGamesPlayedYet => 'Sin partidos jugados';

  @override
  String winsStreakCount(int count) {
    return '$count victorias';
  }

  @override
  String lossesStreakCount(int count) {
    return '$count derrotas';
  }

  @override
  String get partnerDetailsTitle => 'Detalles del compañero';

  @override
  String get overallRecord => 'Registro general';

  @override
  String get games => 'Partidos';

  @override
  String get record => 'Registro';

  @override
  String get pointDifferential => 'Diferencial de puntos';

  @override
  String get avgPerGame => 'Prom. por partido';

  @override
  String get pointsFor => 'Puntos a favor';

  @override
  String get pointsAgainst => 'Puntos en contra';

  @override
  String get eloPerformance => 'Rendimiento ELO';

  @override
  String get totalChange => 'Cambio total';

  @override
  String get recentForm => 'Forma reciente';

  @override
  String streakWins(int count) {
    return '$count V Racha';
  }

  @override
  String streakLosses(int count) {
    return '$count D Racha';
  }

  @override
  String get noRecentGames => 'Sin partidos recientes';

  @override
  String eloLabel(String value) {
    return 'ELO: $value';
  }

  @override
  String get nextGame => 'Próximo partido';

  @override
  String get noGamesScheduled => 'Aún no hay partidos organizados';

  @override
  String get nextTrainingSession => 'Próxima sesión de entrenamiento';

  @override
  String get noTrainingSessionsScheduled =>
      'No hay sesiones de entrenamiento programadas';
}
