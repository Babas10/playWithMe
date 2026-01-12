// Mock repository for TrainingSessionRepository used in testing
import 'dart:async';

import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/data/models/training_session_participant_model.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';

class MockTrainingSessionRepository implements TrainingSessionRepository {
  final StreamController<List<TrainingSessionModel>> _sessionsController =
      StreamController<List<TrainingSessionModel>>.broadcast();
  final Map<String, StreamController<TrainingSessionModel?>>
      _sessionStreamControllers = {};
  final Map<String, TrainingSessionModel> _sessions = {};

  MockTrainingSessionRepository() {
    // Seed initial empty list to match real repository behavior
    _sessionsController.add(const []);
  }

  // Helper methods for testing
  void addSession(TrainingSessionModel session) {
    _sessions[session.id] = session;
    _emitSessions();
    _emitSessionUpdate(session.id);
  }

  void clearSessions() {
    _sessions.clear();
    _emitSessions();
  }

  void _emitSessions() {
    if (!_sessionsController.isClosed) {
      _sessionsController.add(_sessions.values.toList());
    }
  }

  void _emitSessionUpdate(String sessionId) {
    final controller = _sessionStreamControllers[sessionId];
    if (controller != null && !controller.isClosed) {
      controller.add(_sessions[sessionId]);
    }
  }

  void dispose() {
    _sessionsController.close();
    for (final controller in _sessionStreamControllers.values) {
      controller.close();
    }
    _sessionStreamControllers.clear();
  }

  // Repository methods
  @override
  Future<TrainingSessionModel?> getTrainingSessionById(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Stream<TrainingSessionModel?> getTrainingSessionStream(String sessionId) {
    if (!_sessionStreamControllers.containsKey(sessionId)) {
      late final StreamController<TrainingSessionModel?> controller;
      controller = StreamController<TrainingSessionModel?>.broadcast(
        onListen: () {
          controller.add(_sessions[sessionId]);
        },
      );
      _sessionStreamControllers[sessionId] = controller;
    }

    return _sessionStreamControllers[sessionId]!.stream;
  }

  @override
  Stream<List<TrainingSessionModel>> getTrainingSessionsForGroup(
      String groupId) async* {
    // Emit current state immediately
    yield _sessions.values
        .where((session) => session.groupId == groupId)
        .toList();

    // Then emit future updates
    await for (final sessions in _sessionsController.stream) {
      yield sessions.where((session) => session.groupId == groupId).toList();
    }
  }

  @override
  Stream<List<TrainingSessionModel>> getUpcomingTrainingSessionsForGroup(
      String groupId) async* {
    final now = DateTime.now();
    await for (final sessions in getTrainingSessionsForGroup(groupId)) {
      yield sessions
          .where((session) =>
              session.startTime.isAfter(now) &&
              session.status == TrainingStatus.scheduled)
          .toList();
    }
  }

  @override
  Future<List<TrainingSessionModel>> getPastTrainingSessionsForGroup(
    String groupId, {
    int limit = 20,
  }) async {
    final now = DateTime.now();
    final pastSessions = _sessions.values
        .where(
            (session) => session.groupId == groupId && session.startTime.isBefore(now))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return pastSessions.take(limit).toList();
  }

  @override
  Stream<List<TrainingSessionModel>> getTrainingSessionsForUser(String userId) {
    return _sessionsController.stream.map((sessions) => sessions
        .where((session) => session.isParticipant(userId))
        .toList());
  }

  @override
  Stream<int> getUpcomingTrainingSessionsCount(String groupId) async* {
    await for (final sessions
        in getUpcomingTrainingSessionsForGroup(groupId)) {
      yield sessions.length;
    }
  }

  @override
  Future<String> createTrainingSession(TrainingSessionModel session) async {
    _sessions[session.id] = session;
    _emitSessions();
    return session.id;
  }

  @override
  Future<void> updateTrainingSessionInfo(
    String sessionId, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    GameLocation? location,
    String? notes,
  }) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.updateInfo(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        notes: notes,
      );
      _emitSessions();
    }
  }

  @override
  Future<void> updateTrainingSessionSettings(
    String sessionId, {
    int? maxParticipants,
    int? minParticipants,
  }) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.updateSettings(
        maxParticipants: maxParticipants,
        minParticipants: minParticipants,
      );
      _emitSessions();
    }
  }

  @override
  Future<void> joinTrainingSession(String sessionId) async {
    // Mock implementation - not fully implemented
    throw UnimplementedError();
  }

  @override
  Future<void> leaveTrainingSession(String sessionId) async {
    // Mock implementation - not fully implemented
    throw UnimplementedError();
  }

  @override
  Future<void> addParticipant(String sessionId, String userId) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.addParticipant(userId);
      _emitSessions();
    }
  }

  @override
  Future<void> removeParticipant(String sessionId, String userId) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.removeParticipant(userId);
      _emitSessions();
    }
  }

  @override
  Future<void> cancelTrainingSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.cancelSession();
      _emitSessions();
    }
  }

  @override
  Future<void> completeTrainingSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.completeSession();
      _emitSessions();
    }
  }

  @override
  Future<TrainingStatus> updateSessionStatusIfNeeded(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('Training session not found');
    }

    // Only update if session is scheduled and past endTime
    if (session.status != TrainingStatus.scheduled) {
      return session.status;
    }

    final now = DateTime.now();
    if (session.endTime.isAfter(now)) {
      // Session hasn't ended yet
      return TrainingStatus.scheduled;
    }

    // Session has ended - determine final status based on participants
    final hasEnoughParticipants =
        session.participantIds.length >= session.minParticipants;

    TrainingSessionModel updatedSession;
    if (hasEnoughParticipants) {
      // Enough participants → mark as completed
      updatedSession = session.completeSession();
    } else {
      // Not enough participants → mark as cancelled
      updatedSession = session.cancelSession();
    }

    _sessions[sessionId] = updatedSession;
    _emitSessions();
    _emitSessionUpdate(sessionId);

    return updatedSession.status;
  }

  @override
  Future<void> deleteTrainingSession(String sessionId) async {
    _sessions.remove(sessionId);
    _emitSessions();
  }

  @override
  Future<bool> trainingSessionExists(String sessionId) async {
    return _sessions.containsKey(sessionId);
  }

  @override
  Future<List<String>> getTrainingSessionParticipants(String sessionId) async {
    final session = _sessions[sessionId];
    return session?.participantIds ?? [];
  }

  @override
  Stream<List<TrainingSessionParticipantModel>>
      getTrainingSessionParticipantsStream(String sessionId) {
    // Mock implementation - not fully implemented
    return Stream.value([]);
  }

  @override
  Stream<int> getTrainingSessionParticipantCount(String sessionId) {
    return getTrainingSessionStream(sessionId).map((session) => session?.currentParticipantCount ?? 0);
  }

  @override
  Future<bool> canUserJoinTrainingSession(String sessionId, String userId) async {
    final session = _sessions[sessionId];
    return session?.canUserJoin(userId) ?? false;
  }

  @override
  Stream<List<TrainingSessionModel>> getRecurringSessionInstances(
      String parentSessionId) {
    return Stream.value([]);
  }

  @override
  Stream<List<TrainingSessionModel>> getUpcomingRecurringSessionInstances(
      String parentSessionId) {
    return Stream.value([]);
  }

  @override
  Future<List<String>> generateRecurringInstances(String parentSessionId) async {
    return [];
  }

  @override
  Future<void> cancelRecurringSessionInstance(String instanceId) async {
    // Mock implementation
  }
}
