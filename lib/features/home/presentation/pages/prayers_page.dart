import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';
import 'package:yad_app/config/service_locator.dart';

class PrayersPage extends StatefulWidget {
  final List<PrayerTimeInfo> prayerTimes;
  final String cityCountry;
  final bool isLoading;

  const PrayersPage({
    super.key,
    required this.prayerTimes,
    required this.cityCountry,
    this.isLoading = false,
  });

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> {
  late PrayerCountdownService _prayerCountdownService;
  late List<PrayerTimeInfo> _displayedPrayerTimes;
  late String _displayedCityCountry;
  late bool _displayedIsLoading;

  @override
  void initState() {
    super.initState();
    _prayerCountdownService = getIt<PrayerCountdownService>();
    _displayedPrayerTimes = widget.prayerTimes;
    _displayedCityCountry = widget.cityCountry;
    _displayedIsLoading = widget.isLoading;

    // Listen for prayer time updates
    _prayerCountdownService.addListener((prayerTimes) {
      if (mounted) {
        setState(() {
          _displayedPrayerTimes = prayerTimes;
        });
      }
    });
  }

  @override
  void didUpdateWidget(PrayersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerTimes != widget.prayerTimes ||
        oldWidget.cityCountry != widget.cityCountry ||
        oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _displayedPrayerTimes = widget.prayerTimes;
        _displayedCityCountry = widget.cityCountry;
        _displayedIsLoading = widget.isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with city/country info - fixed visibility
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primary,
            expandedHeight: 100,
            toolbarHeight: 60,
            title: Text(
              'Prayer Times',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_displayedCityCountry.isNotEmpty)
                      Text(
                        _displayedCityCountry,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          // Prayer times content
          SliverFillRemaining(
            hasScrollBody: true,
            child: _buildPrayerTimesContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesContent(BuildContext context) {
    if (_displayedIsLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_displayedPrayerTimes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Prayer times unavailable',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your location settings',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: List.generate(
          _displayedPrayerTimes.length,
          (index) => _buildPrayerCard(
            context,
            _displayedPrayerTimes[index],
            index == _displayedPrayerTimes.length - 1,
          ),
        ),
      ),
    );
  }

  /// Build individual prayer card with enhanced accessibility for users 50+
  Widget _buildPrayerCard(
    BuildContext context,
    PrayerTimeInfo prayer,
    bool isLast,
  ) {
    final isActive = prayer.isCurrentlyActive;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Prayer name (English + Hebrew) with status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prayer name with enhanced font size for older users
                        Text(
                          prayer.name.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 20, // Increased from 15 for readability
                              ),
                        ),
                        const SizedBox(height: 4),
                        // Hebrew name
                        Text(
                          prayer.hebrewName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status badge
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'NOW',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'UPCOMING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Time information with divider
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Start time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Begins',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                              ),
                              Text(
                                prayer.displayStartTime,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Divider
                    Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    // End time
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_send,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ends',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                              ),
                              Text(
                                prayer.displayEndTime,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
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
              const SizedBox(height: 14),

              // Countdown status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isActive)
                      Icon(
                        Icons.play_circle_filled,
                        size: 18,
                        color: AppTheme.primary,
                      )
                    else
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      prayer.countdownText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isActive
                                ? AppTheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
