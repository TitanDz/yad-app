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
      // notif_entity.Notification(
      //   id: '1',
      //   title: 'New Minyan Alert',
      //   message: 'Shacharit service starting in 30 minutes at Central Synagogue',
      //   type: 'minyan_alert',
      //   timestamp: now.subtract(const Duration(minutes: 5)),
      //   isRead: false,
      //   relatedMinyanId: 'minyan_1',
      //   icon: 'alert',
      // ),
      notif_entity.Notification(
        id: '2',
        title: 'Minyan Update',
        message: 'Mincha service at Park Avenue Shul has been rescheduled to 2:00 PM',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        relatedMinyanId: 'minyan_2',
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '3',
        title: 'New Feature Available',
        message: 'Prayer preferences customization is now available in settings',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
        icon: 'announcement',
      ),
      notif_entity.Notification(
        id: '4',
        title: 'Minyan Alert',
        message: 'Maariv service starting in 15 minutes at Midtown Synagogue',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        relatedMinyanId: 'minyan_3',
        icon: 'alert',
      ),
      notif_entity.Notification(
        id: '5',
        title: 'App Update',
        message: 'A10th version 2.0.1 is now available with bug fixes and improvements',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
        icon: 'update',
      ),
      notif_entity.Notification(
        id: '6',
        title: 'Minyan Update',
        message: 'Shacharit service at Upper West Side Temple has been cancelled',
        type: 'minyan_update',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
        relatedMinyanId: 'minyan_4',
        icon: 'cancelled',
      ),
      notif_entity.Notification(
        id: '7',
        title: 'New Minyan Nearby',
        message: 'Someone created a Mincha service 0.8 miles from your location',
        type: 'minyan_alert',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
        relatedMinyanId: 'minyan_5',
        icon: 'alert',
      ),
      notif_entity.Notification(
        id: '8',
        title: 'Community Announcement',
        message: 'Join our community forum to discuss prayer preferences and locations',
        type: 'announcement',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        icon: 'announcement',
      ),
    ]);
  }
}
