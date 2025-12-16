import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/home/domain/entities/notification.dart' as notif_entity;

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsReadEvent extends NotificationEvent {
  const MarkAllAsReadEvent();
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotificationsEvent extends NotificationEvent {
  const ClearAllNotificationsEvent();
}

class FilterNotificationsEvent extends NotificationEvent {
  final String? typeFilter; // 'minyan_alert', 'minyan_update', 'announcement'

  const FilterNotificationsEvent({this.typeFilter});

  @override
  List<Object?> get props => [typeFilter];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  final List<notif_entity.Notification> notifications;
  final int unreadCount;
  final String? filterType;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.filterType,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, filterType];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final List<notif_entity.Notification> _allNotifications = [];
  String? _currentFilter;

  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ClearAllNotificationsEvent>(_onClearAllNotifications);
    on<FilterNotificationsEvent>(_onFilterNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize with mock data if empty
      if (_allNotifications.isEmpty) {
        _initializeMockNotifications();
      }

      _emitNotificationsLoaded(emit);
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final index = _allNotifications.indexWhere((n) => n.id == event.notificationId);
      if (index != -1) {
        _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
        _emitNotificationsLoaded(emit);
        emit(const NotificationActionSuccess('Notification marked as read'));
      }
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      for (int i = 0; i < _allNotifications.length; i++) {
        _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
      }
      _emitNotificationsLoaded(emit);
      emit(const NotificationActionSuccess('All notifications marked as read'));
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _allNotifications.removeWhere((n) => n.id == event.notificationId);
      _emitNotificationsLoaded(emit);
      emit(const NotificationActionSuccess('Notification deleted'));
    } catch (e) {
      emit(NotificationError('Failed to delete notification: ${e.toString()}'));
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _allNotifications.clear();
      _emitNotificationsLoaded(emit);
      emit(const NotificationActionSuccess('All notifications cleared'));
    } catch (e) {
      emit(NotificationError('Failed to clear notifications: ${e.toString()}'));
    }
  }

  Future<void> _onFilterNotifications(
    FilterNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _currentFilter = event.typeFilter;
      _emitNotificationsLoaded(emit);
    } catch (e) {
      emit(NotificationError('Failed to filter notifications: ${e.toString()}'));
    }
  }

  void _emitNotificationsLoaded(Emitter<NotificationState> emit) {
    var filtered = List<notif_entity.Notification>.from(_allNotifications);

    if (_currentFilter != null) {
      filtered = filtered.where((n) => n.type == _currentFilter).toList();
    }

    // Sort by timestamp descending (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final unreadCount = _allNotifications.where((n) => !n.isRead).length;

    emit(NotificationsLoaded(
      notifications: filtered,
      unreadCount: unreadCount,
      filterType: _currentFilter,
    ));
  }

  void _initializeMockNotifications() {
    final now = DateTime.now();

    _allNotifications.addAll([
      // ===== SOMEONE JOINED YOUR MINYAN =====
      notif_entity.Notification(
        id: '1',
        title: 'New Member Joined',
        message: 'Sarah Cohen joined your Shacharit minyan at Central Synagogue',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isRead: false,
        relatedMinyanId: 'minyan_central_1',
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '2',
        title: 'New Member Joined',
        message: 'Michael Rothstein joined your Mincha minyan at Park Avenue Shul',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(minutes: 8)),
        isRead: false,
        relatedMinyanId: 'minyan_park_2',
        icon: 'update',
      ),
      // ===== NEARBY MINYAN ALERTS =====
      notif_entity.Notification(
        id: '3',
        title: 'New Minyan Created Nearby',
        message: 'David Kohen created a Shacharit service 1.2 miles from you at Lincoln Center',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isRead: false,
        relatedMinyanId: 'minyan_lincoln_3',
        icon: 'alert',
      ),
      notif_entity.Notification(
        id: '4',
        title: 'New Minyan Created Nearby',
        message: 'Rachel Silverstein created a Mincha minyan 0.6 miles from you at Brooklyn Heights',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        relatedMinyanId: 'minyan_brooklyn_4',
        icon: 'alert',
      ),
      // ===== REMINDER ALERTS =====
      notif_entity.Notification(
        id: '5',
        title: 'Minyan Starting Soon',
        message: 'Maariv service at Midtown Synagogue starts in 30 minutes. You have 4 other members waiting.',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(minutes: 32)),
        isRead: false,
        relatedMinyanId: 'minyan_midtown_5',
        icon: 'alert',
      ),
      notif_entity.Notification(
        id: '6',
        title: 'Minyan Reminder',
        message: 'Your Shacharit minyan at Upper West Side Temple starts in 1 hour',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 5)),
        isRead: false,
        relatedMinyanId: 'minyan_upwest_6',
        icon: 'alert',
      ),
      // ===== SCHEDULE/CANCELLATION UPDATES =====
      notif_entity.Notification(
        id: '7',
        title: 'Schedule Changed',
        message: 'Mincha service at Park Avenue Shul has been rescheduled from 2:00 PM to 2:30 PM',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        relatedMinyanId: 'minyan_park_7',
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '8',
        title: 'Minyan Cancelled',
        message: 'Maariv service at Forest Hills Temple has been cancelled today',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        relatedMinyanId: 'minyan_forest_8',
        icon: 'cancelled',
      ),
      notif_entity.Notification(
        id: '9',
        title: 'Minyan Reminder',
        message: 'Your Mincha minyan at Bay Ridge Synagogue starts tomorrow at 1:45 PM',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        relatedMinyanId: 'minyan_bay_9',
        icon: 'alert',
      ),
      // ===== COMMUNITY ANNOUNCEMENTS =====
      notif_entity.Notification(
        id: '10',
        title: 'Community Announcement',
        message: 'New Yad-Yad feature available: Share minyan locations with your prayer group',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
        icon: 'announcement',
      ),
      notif_entity.Notification(
        id: '11',
        title: 'App Update Available',
        message: 'Yad-Yad version 2.1.0 is now available with improved map features and notifications',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 12)),
        isRead: true,
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '12',
        title: 'Tips & Insights',
        message: 'Did you know? You can customize your prayer preferences to get personalized minyan recommendations',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 24)),
        isRead: true,
        icon: 'announcement',
      ),
      // ===== MORE MEMBERSHIP UPDATES =====
      notif_entity.Notification(
        id: '13',
        title: 'New Member Joined',
        message: 'Jonathan Miller joined your Maariv minyan at Riverside Shul (now 6 members)',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
        relatedMinyanId: 'minyan_riverside_13',
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '14',
        title: 'Member Left',
        message: 'Rebecca Goldman left your Shacharit minyan at Central Synagogue',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
        relatedMinyanId: 'minyan_central_14',
        icon: 'update',
      ),
      // ===== HISTORIC/OLDER NOTIFICATIONS =====
      notif_entity.Notification(
        id: '15',
        title: 'New Minyan Created Nearby',
        message: 'Miriam Goldstein created a Shacharit service 2.1 miles from you at Washington Heights',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        relatedMinyanId: 'minyan_wash_15',
        icon: 'alert',
      ),
      notif_entity.Notification(
        id: '16',
        title: 'Weekly Digest',
        message: 'You attended 4 minyans this week and connected with 8 new members',
        type: 'announcement',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        isRead: true,
        icon: 'announcement',
      ),
    ]);
  }
}
