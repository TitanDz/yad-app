import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type; // 'minyan_alert', 'minyan_update', 'announcement'
  final DateTime timestamp;
  final bool isRead;
  final String? relatedMinyanId;
  final String? icon; // Icon type identifier

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.relatedMinyanId,
    this.icon,
  });

  // Copy with method for creating modified instances
  Notification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedMinyanId,
    String? icon,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedMinyanId: relatedMinyanId ?? this.relatedMinyanId,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        timestamp,
        isRead,
        relatedMinyanId,
        icon,
      ];
}
