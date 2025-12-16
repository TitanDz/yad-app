import 'package:flutter/material.dart';
import 'package:yad_app/features/home/domain/entities/notification.dart' as notif_entity;

/// Enhanced notification card with visual indicators for different notification types
class EnhancedNotificationCard extends StatelessWidget {
  final notif_entity.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showCategory;

  const EnhancedNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.showCategory = true,
  });

  /// Get the color and icon based on notification type
  /// Uses brand-aligned colors that respect the app's design system
  (Color backgroundColor, Color iconColor, IconData icon, String label) _getTypeDetails(BuildContext context) {
    switch (notification.type) {
      case 'minyan_alert':
        // Alert notifications use error color for urgency
        return (
          Theme.of(context).colorScheme.error.withValues(alpha: 0.12),  // Very light error tint
          Theme.of(context).colorScheme.error,
          Icons.notifications_active,
          'Minyan Alert'
        );
      case 'minyan_update':
        // Updates use primary (Divinity blue) for consistency
        return (
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),  // Very light primary tint
          Theme.of(context).colorScheme.primary,
          Icons.update,
          'Minyan Update'
        );
      case 'announcement':
        // Announcements use secondary (success green) for positive tone
        return (
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),  // Very light green tint
          Theme.of(context).colorScheme.secondary,
          Icons.info_outline,
          'Announcement'
        );
      default:
        return (
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
          Theme.of(context).colorScheme.onSurfaceVariant,
          Icons.notifications,
          'Notification'
        );
    }
  }

  /// Get icon based on notification icon type
  IconData _getIconData() {
    final iconMap = {
      'alert': Icons.notifications_active,
      'update': Icons.update,
      'announcement': Icons.info,
      'cancelled': Icons.cancel,
    };
    return iconMap[notification.icon] ?? Icons.notifications;
  }

  /// Format time relative to now
  String _formatTime() {
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${notification.timestamp.month}/${notification.timestamp.day}/${notification.timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, iconColor, typeIcon, typeLabel) = _getTypeDetails(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: notification.isRead
          ? Theme.of(context).colorScheme.surface
          : backgroundColor,
      elevation: notification.isRead ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon, Title, Unread indicator, Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: notification.isRead
                          ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15)
                          : backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: notification.isRead
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: 1,
                            ),
                    ),
                    child: Icon(
                      _getIconData(),
                      color: notification.isRead
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (showCategory)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // More menu button
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Message
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Footer: Timestamp and Action indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (notification.relatedMinyanId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Minyan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
