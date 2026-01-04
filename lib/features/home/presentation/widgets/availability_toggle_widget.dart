import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/presentation/bloc/availability_bloc.dart';

/// Widget for toggling user availability for 30 minutes
class AvailabilityToggleWidget extends StatelessWidget {
  final String userId;
  final VoidCallback? onAvailabilityChanged;

  const AvailabilityToggleWidget({
    super.key,
    required this.userId,
    this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityBloc, AvailabilityState>(
      builder: (context, state) {
        if (state is AvailabilityLoaded) {
          final isUnavailable = state.status.isCurrentlyUnavailable;
          final remainingMinutes = state.remainingMinutes;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnavailable
                  ? AppTheme.divinity.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isUnavailable
                    ? AppTheme.divinity
                    : AppTheme.divinity.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Text
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        isUnavailable ? Icons.do_not_disturb_on : Icons.check_circle_outline,
                        color: isUnavailable
                            ? AppTheme.divinity
                            : AppTheme.divinity.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnavailable ? 'Do Not Disturb' : 'Available',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isUnavailable
                                      ? AppTheme.divinity
                                      : AppTheme.divinity.withValues(alpha: 0.7),
                                ),
                          ),
                          if (isUnavailable && remainingMinutes != null)
                            Text(
                              'Back in $remainingMinutes min',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.divinity.withValues(alpha: 0.6),
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle Button
                GestureDetector(
                  onTap: () {
                    if (isUnavailable) {
                      context.read<AvailabilityBloc>().add(
                            SetAvailableEvent(userId: userId),
                          );
                    } else {
                      _showAvailabilityOptions(context);
                    }
                    onAvailabilityChanged?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isUnavailable
                          ? AppTheme.divinity
                          : AppTheme.divinity.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUnavailable ? 'Cancel' : 'Set',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnavailable
                                ? Colors.white
                                : AppTheme.divinity,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showAvailabilityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Unavailable For',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            // 15 minutes
            _buildDurationOption(
              context,
              '15 Minutes',
              15,
            ),
            const SizedBox(height: 12),
            // 30 minutes
            _buildDurationOption(
              context,
              '30 Minutes',
              30,
            ),
            const SizedBox(height: 12),
            // 1 hour
            _buildDurationOption(
              context,
              '1 Hour',
              60,
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(
    BuildContext context,
    String label,
    int minutes,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          context.read<AvailabilityBloc>().add(
                SetUnavailableEvent(
                  userId: userId,
                  duration: Duration(minutes: minutes),
                  reason: 'Do not disturb',
                ),
              );
          Navigator.pop(context);
          onAvailabilityChanged?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.divinity,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
