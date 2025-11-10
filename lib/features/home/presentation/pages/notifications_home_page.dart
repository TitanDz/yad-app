import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/notification_bloc.dart';

class NotificationsHomePage extends StatefulWidget {
  const NotificationsHomePage({super.key});

  @override
  State<NotificationsHomePage> createState() => _NotificationsHomePageState();
}

class _NotificationsHomePageState extends State<NotificationsHomePage> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header with title and action buttons
          _buildHeader(context),
          
          // Filter tabs
          _buildFilterTabs(context),
          
          // Notifications list
          Expanded(
            child: BlocListener<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is NotificationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(
                          context,
                          state.notifications[index],
                        );
                      },
                    );
                  }

                  if (state is NotificationError) {
                    return _buildErrorState(context, state.message);
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Mark all as read button
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: Icon(
                    Icons.done_all,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    context.read<NotificationBloc>().add(const MarkAllAsReadEvent());
                  },
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox(width: 48);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.unreadCount;
        }

        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(
                  context,
                  label: 'All',
                  isSelected: _selectedFilter == null,
                  unreadCount: unreadCount,
                  onTap: () {
                    setState(() => _selectedFilter = null);
                    context.read<NotificationBloc>().add(const FilterNotificationsEvent());
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  label: 'Minyan Alerts',
                  isSelected: _selectedFilter == 'minyan_alert',
                  onTap: () {
                    setState(() => _selectedFilter = 'minyan_alert');
                    context.read<NotificationBloc>().add(
                          const FilterNotificationsEvent(typeFilter: 'minyan_alert'),
                        );
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  label: 'Updates',
                  isSelected: _selectedFilter == 'minyan_update',
                  onTap: () {
                    setState(() => _selectedFilter = 'minyan_update');
                    context.read<NotificationBloc>().add(
                          const FilterNotificationsEvent(typeFilter: 'minyan_update'),
                        );
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  label: 'Announcements',
                  isSelected: _selectedFilter == 'announcement',
                  onTap: () {
                    setState(() => _selectedFilter = 'announcement');
                    context.read<NotificationBloc>().add(
                          const FilterNotificationsEvent(typeFilter: 'announcement'),
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int unreadCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (unreadCount > 0 && isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, var notification) {
    final iconMap = {
      'alert': Icons.notifications_active,
      'update': Icons.update,
      'announcement': Icons.info,
      'cancelled': Icons.cancel,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationBloc>().add(MarkAsReadEvent(notification.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconMap[notification.icon] ?? Icons.notifications,
                  color: notification.isRead
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
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
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Delete button
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
                  if (value == 'delete') {
                    context.read<NotificationBloc>().add(DeleteNotificationEvent(notification.id));
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 56,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(const LoadNotificationsEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
