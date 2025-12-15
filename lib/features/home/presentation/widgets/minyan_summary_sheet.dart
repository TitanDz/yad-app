import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

class MinyanSummarySheet extends StatelessWidget {
  final Minyan minyan;
  final VoidCallback? onClose;

  const MinyanSummarySheet({
    super.key,
    required this.minyan,
    this.onClose,
  });

  /// Format date from YYYY-MM-DD to readable format with day name
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('EEEE, MMMM d, yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format time to 12-hour format with context
  String _format12HourTime(String timeStr, BuildContext context) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final time = TimeOfDay(hour: hour, minute: minute);
      return time.format(context);
    } catch (e) {
      return timeStr;
    }
  }

  /// Format distance with appropriate unit
  String _formatDistance(double? distance) {
    if (distance == null) return 'Unknown';
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Name (Title)
                  Text(
                    minyan.locationName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Distance Info
                  _SummaryItem(
                    icon: Icons.location_on_outlined,
                    label: 'Distance',
                    value: _formatDistance(minyan.distance),
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Prayer Type
                  _SummaryItem(
                    icon: Icons.church_outlined,
                    label: 'Prayer Type',
                    value: minyan.prayerType,
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Time
                  _SummaryItem(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: _format12HourTime(minyan.time, context),
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Date
                  _SummaryItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(minyan.date),
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Participants
                  _SummaryItem(
                    icon: Icons.people_outlined,
                    label: 'Participants',
                    value: '${minyan.participantCount} people',
                    context: context,
                  ),
                  const SizedBox(height: 16),

                  // Notes if available
                  if (minyan.notes.isNotEmpty) ...[
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'About this minyan',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      minyan.notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons - Three button layout
                  Column(
                    children: [
                      // First row: Waze and Route buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text('View in Waze'),
                              onPressed: () {
                                // TODO: Implement Waze integration
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening Waze integration...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(Icons.directions),
                              label: const Text('View Route'),
                              onPressed: () {
                                Navigator.pop(context);
                                // Route is already being drawn from marker tap
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Second row: Close button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper widget for displaying summary items
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
