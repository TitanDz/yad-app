import 'package:flutter/material.dart';
import 'package:yad_app/features/home/domain/entities/active_user_marker.dart';

class SendInvitationsSheet extends StatefulWidget {
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
  State<SendInvitationsSheet> createState() => _SendInvitationsSheetState();
}

class _SendInvitationsSheetState extends State<SendInvitationsSheet> {
  late Set<String> selectedUserIds;

  @override
  void initState() {
    super.initState();
    selectedUserIds = {};
  }

  @override
  Widget build(BuildContext context) {
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
                    'Invite nearby users',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.minyanDetails,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selected: ${selectedUserIds.length}/${widget.nearbyUsers.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // List of users
            Expanded(
              child: widget.nearbyUsers.isEmpty
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
                      itemCount: widget.nearbyUsers.length,
                      itemBuilder: (context, index) {
                        final user = widget.nearbyUsers[index];
                        final isSelected = selectedUserIds.contains(user.userId);

                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            user.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Row(
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
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                selectedUserIds.add(user.userId);
                              } else {
                                selectedUserIds.remove(user.userId);
                              }
                            });
                          },
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
                    onPressed: selectedUserIds.isEmpty
                        ? null
                        : () {
                            widget.onSendInvitations(selectedUserIds.toList());
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      'Send Invitations (${selectedUserIds.length})',
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
