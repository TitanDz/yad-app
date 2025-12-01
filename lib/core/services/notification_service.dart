/// Service for broadcasting notifications to inactive users when minyans need participants
class NotificationService {
  /// Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Broadcast notification when minyan needs participants
  Future<void> broadcastMinyanNeedNotification({
    required String minyanId,
    required String prayerType,
    required String location,
    required int currentParticipants,
    required int requiredParticipants,
  }) async {
    try {
      final participantsNeeded = requiredParticipants - currentParticipants;
      
      // Prepare notification payload
      final notificationData = {
        'type': 'minyan_needs_participants',
        'minyanId': minyanId,
        'prayerType': prayerType,
        'location': location,
        'currentParticipants': currentParticipants,
        'requiredParticipants': requiredParticipants,
        'participantsNeeded': participantsNeeded,
        'title': 'Minyan Needs You!',
        'message': '$prayerType at $location needs $participantsNeeded more people',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // TODO: Send via FCM to inactive users in radius
      // POST /api/notifications/broadcast
      // {
      //   "type": "minyan_needs_participants",
      //   "targetUserStatus": "inactive",
      //   "minyanData": notificationData
      // }
      
      print('[NotificationService] Broadcasting minyan notification: $notificationData');
    } catch (e) {
      print('[NotificationService] Failed to broadcast notification: $e');
    }
  }

  /// Notify user when they've been inactive for too long
  Future<void> notifyInactiveUser({
    required String userId,
    required int inactiveMinutes,
  }) async {
    try {
      final notificationData = {
        'type': 'user_inactive_reminder',
        'userId': userId,
        'inactiveMinutes': inactiveMinutes,
        'title': 'Come back to The10th!',
        'message': 'You\'ve been away for $inactiveMinutes minutes. Active minyams nearby need you!',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // TODO: Send via FCM to user
      // POST /api/notifications/send
      // { "userId": userId, "data": notificationData }
      
      print('[NotificationService] Sending inactive user notification: $notificationData');
    } catch (e) {
      print('[NotificationService] Failed to send notification: $e');
    }
  }

  /// Notify user when nearby minyan they're interested in is starting soon
  Future<void> notifyMinyanStartingSoon({
    required String userId,
    required String minyanId,
    required String prayerType,
    required String location,
    required int minutesUntilStart,
  }) async {
    try {
      final notificationData = {
        'type': 'minyan_starting_soon',
        'userId': userId,
        'minyanId': minyanId,
        'prayerType': prayerType,
        'location': location,
        'minutesUntilStart': minutesUntilStart,
        'title': 'Minyan Starting Soon!',
        'message': '$prayerType at $location starts in $minutesUntilStart minutes',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // TODO: Send via FCM
      print('[NotificationService] Sending minyan starting soon notification: $notificationData');
    } catch (e) {
      print('[NotificationService] Failed to send notification: $e');
    }
  }

  /// Check if minyan needs notification broadcast
  bool shouldBroadcastNotification({
    required int currentParticipants,
    required int requiredParticipants,
    required DateTime lastNotificationTime,
  }) {
    final participantsNeeded = requiredParticipants - currentParticipants;
    
    // Broadcast if:
    // 1. Need at least 1 more participant
    // 2. Haven't sent notification in last 10 minutes
    final timeSinceLastNotification = DateTime.now().difference(lastNotificationTime);
    
    return participantsNeeded > 0 && 
           timeSinceLastNotification.inMinutes >= 10;
  }
}
