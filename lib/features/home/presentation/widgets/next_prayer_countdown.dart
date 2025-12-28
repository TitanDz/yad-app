import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';

/// Widget that displays the next upcoming prayer with a live countdown timer
class NextPrayerCountdown extends StatelessWidget {
  final List<PrayerTimeInfo> prayerTimes;
  final bool isLoading;

  const NextPrayerCountdown({
    super.key,
    required this.prayerTimes,
    this.isLoading = false,
  });

  /// Get the next upcoming prayer
  PrayerTimeInfo? _getNextPrayer() {
    if (prayerTimes.isEmpty) {
      debugPrint('[NextPrayerCountdown] Prayer times list is empty');
      return null;
    }

    debugPrint('[NextPrayerCountdown] Checking ${prayerTimes.length} prayer times');
    
    // Find the first prayer that hasn't started yet
    for (final prayer in prayerTimes) {
      debugPrint('[NextPrayerCountdown] Prayer: ${prayer.name}, timeUntilStart: ${prayer.timeUntilStart}, isNegative: ${prayer.timeUntilStart.isNegative}');
      if (!prayer.timeUntilStart.isNegative) {
        debugPrint('[NextPrayerCountdown] Found next prayer: ${prayer.name}');
        return prayer;
      }
    }

    // If no upcoming prayer today, show the last prayer of the day
    // This way users can see the last prayer time even if it has passed
    debugPrint('[NextPrayerCountdown] No upcoming prayers found, showing last prayer of the day');
    if (prayerTimes.isNotEmpty) {
      return prayerTimes.last;
    }
    return null;
  }

  /// Format time duration to "HH:MM:SS" format
  String _formatCountdown(Duration duration) {
    final isNegative = duration.isNegative;
    final absDuration = duration.abs();
    final hours = absDuration.inHours;
    final minutes = absDuration.inMinutes % 60;
    final seconds = absDuration.inSeconds % 60;

    final formatted = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return formatted;
  }

  /// Get the status label for the countdown
  String _getStatusLabel(Duration timeUntilStart) {
    if (timeUntilStart.isNegative) {
      return 'ongoing/passed';
    }
    return 'until prayer';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _getNextPrayer();

    debugPrint('[NextPrayerCountdown.build] prayerTimes.length=${prayerTimes.length}, isLoading=$isLoading, nextPrayer=${nextPrayer?.name}');

    if (isLoading) {
      // Show loading state instead of hiding
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Next Prayer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.6),
                ),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      );
    }

    if (nextPrayer == null) {
      // No prayer found - show message
      debugPrint('[NextPrayerCountdown] No prayer found, showing empty state');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All daily prayers completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Prayer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Next Prayer" label
                Text(
                  'Next Prayer',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Prayer name and time
                Row(
                  children: [
                    // Prayer name
                    Text(
                      nextPrayer.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Prayer time
                    Text(
                      nextPrayer.displayStartTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side: Countdown timer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Countdown text
              Text(
                _formatCountdown(nextPrayer.timeUntilStart),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'monospace', // Monospace for better alignment
                ),
              ),
              const SizedBox(height: 2),
              // "until prayer" label or status
              Text(
                _getStatusLabel(nextPrayer.timeUntilStart),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
