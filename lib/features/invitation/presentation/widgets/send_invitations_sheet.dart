import 'package:flutter/material.dart';
import 'package:yad_app/features/home/domain/entities/active_user_marker.dart';

class SendInvitationsSheet extends StatelessWidget {
  final List<ActiveUserMarker> nearbyUsers;
  final String minyanDetails;
  final Function(List<String>) onSendInvitations;

  const SendInvitationsSheet({
    super.key,
    required this.nearbyUsers,
    required this.minyanDetails,
    required this.onSendInvitations,
  });

  @override
  Widget build(BuildContext context) {
    // Automatically include all users
    final allUserIds = nearbyUsers.map((u) => u.userId).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite all nearby users',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    minyanDetails,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ready to send to ${nearbyUsers.length} nearby users',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // List of users (read-only display)
            Expanded(
              child: nearbyUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No nearby users',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: nearbyUsers.length,
                      itemBuilder: (context, index) {
                        final user = nearbyUsers[index];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${user.distance?.toStringAsFixed(1) ?? "??"} km away',
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                          const SizedBox(width: 12),
                                          user.isAvailable
                                              ? Chip(
                                                  label: const Text('Available'),
                                                  backgroundColor: Colors.green.withValues(alpha: 0.15),
                                                  labelStyle: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                )
                                              : Chip(
                                                  label: Text('In ${user.minutesUnavailable}m'),
                                                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                                                  labelStyle: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Checkmark icon indicating all will be included
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: nearbyUsers.isEmpty
                        ? null
                        : () {
                            onSendInvitations(allUserIds);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      'Send Invitations to All (${nearbyUsers.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
