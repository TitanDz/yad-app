import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';
import 'package:intl/intl.dart';

/// Widget that displays prayer times with live countdown timers
class PrayerTimesPanel extends StatefulWidget {
  final List<PrayerTimeInfo> prayerTimes;
  final String cityCountry;
  final bool isLoading;

  const PrayerTimesPanel({
    super.key,
    required this.prayerTimes,
    required this.cityCountry,
    this.isLoading = false,
  });

  @override
  State<PrayerTimesPanel> createState() => _PrayerTimesPanelState();
}

class _PrayerTimesPanelState extends State<PrayerTimesPanel> {
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    _updateDate();
  }

  @override
  void didUpdateWidget(PrayerTimesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDate();
  }

  void _updateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    setState(() {
      _formattedDate = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // City and Country Display
              if (widget.cityCountry.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, you\'re in',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cityCountry,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),

              // Date Display
              Text(
                _formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 20),

              // Prayer Times List
              if (widget.isLoading)
                Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (widget.prayerTimes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Prayer times unavailable',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    widget.prayerTimes.length,
                    (index) => _buildPrayerTimeCard(
                      context,
                      widget.prayerTimes[index],
                      index == widget.prayerTimes.length - 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual prayer time card
  Widget _buildPrayerTimeCard(
    BuildContext context,
    PrayerTimeInfo prayer,
    bool isLast,
  ) {
    final isActive = prayer.isCurrentlyActive;
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isActive ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Prayer name (Hebrew + English)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prayer.hebrewName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Active badge
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Time range
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${prayer.displayStartTime} - ${prayer.displayEndTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Countdown
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prayer.countdownText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const SizedBox(height: 12)
        else
          const SizedBox(height: 0),
      ],
    );
  }
}
