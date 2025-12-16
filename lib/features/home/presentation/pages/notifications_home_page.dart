import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/notification_bloc.dart';
import 'package:yad_app/features/home/presentation/widgets/enhanced_notification_card.dart';

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
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return EnhancedNotificationCard(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<NotificationBloc>().add(MarkAsReadEvent(notification.id));
                            }
                          },
                          onDelete: () {
                            context.read<NotificationBloc>().add(DeleteNotificationEvent(notification.id));
                          },
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
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
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
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.25),
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

}
