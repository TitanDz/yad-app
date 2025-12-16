import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:yad_app/core/services/prayer_times_calculator.dart';

/// Represents a single prayer time with countdown information
class PrayerTimeInfo {
  final String name;
  final String hebrewName;
  final DateTime startTime;
  final DateTime endTime;
  final String displayStartTime;
  final String displayEndTime;
  final Duration timeUntilStart;
  final Duration timeUntilEnd;
  final bool isCurrentlyActive;
  final String countdownText;

  PrayerTimeInfo({
    required this.name,
    required this.hebrewName,
    required this.startTime,
    required this.endTime,
    required this.displayStartTime,
    required this.displayEndTime,
    required this.timeUntilStart,
    required this.timeUntilEnd,
    required this.isCurrentlyActive,
    required this.countdownText,
  });
}

/// Service for calculating prayer times and managing countdown timers
class PrayerCountdownService {
  Timer? _countdownTimer;
  final List<Function(List<PrayerTimeInfo>)> _listeners = [];
  
  late double _latitude;
  late double _longitude;
  late String _timeZone;
  late DateTime _currentDate;
  
  List<PrayerTimeInfo> _cachedPrayerTimes = [];

  /// Initialize the service with location and timezone
  void initialize({
    required double latitude,
    required double longitude,
    required String timeZone,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _timeZone = timeZone;
    _currentDate = DateTime.now();
    
    // Calculate prayer times immediately
    _calculatePrayerTimes();
    
    // Start countdown timer to update every second
    _startCountdownTimer();
  }

  /// Add listener for prayer time updates
  void addListener(Function(List<PrayerTimeInfo>) callback) {
    _listeners.add(callback);
  }

  /// Remove listener
  void removeListener(Function(List<PrayerTimeInfo>) callback) {
    _listeners.remove(callback);
  }

  /// Get current prayer times with countdown
  List<PrayerTimeInfo> getPrayerTimes() => _cachedPrayerTimes;

  /// Dispose resources
  void dispose() {
    _countdownTimer?.cancel();
    _listeners.clear();
  }

  /// Calculate prayer times based on location
  void _calculatePrayerTimes() {
    try {
      final prayerTimes = PrayerTimesCalculator.calculatePrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        date: _currentDate,
        timeZone: _timeZone,
      );

      _cachedPrayerTimes = prayerTimes.map((pt) {
        final now = DateTime.now();
        
        // Estimate prayer duration (roughly 45 mins to 1 hour)
        final endTime = pt.time.add(const Duration(minutes: 50));
        
        final timeUntilStart = pt.time.difference(now);
        final timeUntilEnd = endTime.difference(now);
        final isActive = timeUntilStart.isNegative && !timeUntilEnd.isNegative;
        
        final countdownText = _buildCountdownText(
          timeUntilStart,
          timeUntilEnd,
          isActive,
        );

        return PrayerTimeInfo(
          name: pt.name,
          hebrewName: pt.hebrewName,
          startTime: pt.time,
          endTime: endTime,
          displayStartTime: _formatTime(pt.time),
          displayEndTime: _formatTime(endTime),
          timeUntilStart: timeUntilStart,
          timeUntilEnd: timeUntilEnd,
          isCurrentlyActive: isActive,
          countdownText: countdownText,
        );
      }).toList();

      _notifyListeners();
    } catch (e) {
      debugPrint('[PrayerCountdownService] Error calculating prayer times: $e');
    }
  }

  /// Start the countdown timer to update every second
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculatePrayerTimes();
    });
  }

  /// Build countdown text based on time until prayer
  String _buildCountdownText(
    Duration timeUntilStart,
    Duration timeUntilEnd,
    bool isActive,
  ) {
    if (isActive) {
      // Prayer is currently active, show time until it ends
      return '⏱️ Ends in ${_formatDuration(timeUntilEnd)}';
    } else if (timeUntilStart.isNegative) {
      // Prayer has already ended
      return '✓ Completed';
    } else {
      // Prayer hasn't started yet, show time until it starts
      return '⏱️ Starts in ${_formatDuration(timeUntilStart)}';
    }
  }

  /// Format duration as human-readable string
  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'past';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes != 1 ? 's' : ''} $seconds second${seconds != 1 ? 's' : ''}';
    } else {
      return '$seconds second${seconds != 1 ? 's' : ''}';
    }
  }

  /// Format time as HH:MM
  String _formatTime(DateTime time) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(time);
  }

  /// Notify all listeners of prayer time updates
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_cachedPrayerTimes);
    }
  }
}
