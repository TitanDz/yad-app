import 'package:intl/intl.dart';

/// Prayer time data model
class PrayerTime {
  final String name;
  final String hebrewName;
  final DateTime time;
  final String displayTime;
  final String description;
  final int priority; // 1 = highest (most commonly prayed)

  PrayerTime({
    required this.name,
    required this.hebrewName,
    required this.time,
    required this.displayTime,
    required this.description,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'hebrewName': hebrewName,
    'time': time.toIso8601String(),
    'displayTime': displayTime,
    'description': description,
    'priority': priority,
  };
}

/// Calculates prayer times based on location and date
class PrayerTimesCalculator {
  /// Calculate prayer times for a given location and date
  /// latitude, longitude in decimal degrees
  static List<PrayerTime> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String timeZone,
  }) {
    final times = <PrayerTime>[];
    
    // Calculate sunrise/sunset for the date
    final sunrise = _calculateSunrise(latitude, longitude, date);
    final sunset = _calculateSunset(latitude, longitude, date);
    
    // Jewish prayer times follow the sun
    // Calculate midday (Hatzot)
    final midday = sunrise.add(
      Duration(seconds: (sunset.difference(sunrise).inSeconds ~/ 2).toInt()),
    );

    // Shacharit (morning prayer) - 1 hour after sunrise, or early morning
    final shacharitTime = sunrise.subtract(const Duration(minutes: 30));
    times.add(PrayerTime(
      name: 'Shacharit',
      hebrewName: 'שחרית',
      time: _setTimeOfDay(date, shacharitTime),
      displayTime: _formatTime(shacharitTime),
      description: 'Morning prayer service',
      priority: 1,
    ));

    // Musaf (additional prayer) - typically around 10 AM on Shabbat/Holidays
    final musafTime = sunrise.add(const Duration(hours: 1, minutes: 30));
    times.add(PrayerTime(
      name: 'Musaf',
      hebrewName: 'מוסף',
      time: _setTimeOfDay(date, musafTime),
      displayTime: _formatTime(musafTime),
      description: 'Additional prayer service',
      priority: 3,
    ));

    // Mincha (afternoon prayer) - 2-3 hours before sunset
    final minchaTime = sunset.subtract(const Duration(hours: 2));
    times.add(PrayerTime(
      name: 'Mincha',
      hebrewName: 'מנחה',
      time: _setTimeOfDay(date, minchaTime),
      displayTime: _formatTime(minchaTime),
      description: 'Afternoon prayer service',
      priority: 2,
    ));

    // Maariv (evening prayer) - at sunset
    final maarivTime = sunset;
    times.add(PrayerTime(
      name: 'Maariv',
      hebrewName: 'מעריב',
      time: _setTimeOfDay(date, maarivTime),
      displayTime: _formatTime(maarivTime),
      description: 'Evening prayer service',
      priority: 2,
    ));

    // Sort by priority (most important first)
    times.sort((a, b) => a.priority.compareTo(b.priority));
    
    return times;
  }

  /// Get recommended prayer type suggestions based on current time and location
  static List<String> getSuggestedPrayerTypes({
    required double latitude,
    required double longitude,
    required DateTime now,
    required String timeZone,
  }) {
    final prayerTimes = calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: now,
      timeZone: timeZone,
    );

    final suggestions = <String>[];
    
    for (final prayer in prayerTimes) {
      final timeUntilPrayer = prayer.time.difference(now);
      
      // If prayer is within next 2 hours, suggest it
      if (timeUntilPrayer.isNegative && timeUntilPrayer.inMinutes > -120) {
        suggestions.add(prayer.name);
      } else if (timeUntilPrayer.inMinutes > 0 && timeUntilPrayer.inMinutes <= 120) {
        suggestions.add(prayer.name);
      }
    }

    // If no suggestions match current time, suggest next prayer
    if (suggestions.isEmpty && prayerTimes.isNotEmpty) {
      for (final prayer in prayerTimes) {
        if (prayer.time.isAfter(now)) {
          suggestions.add(prayer.name);
          break;
        }
      }
    }

    return suggestions;
  }

  /// Calculate sunrise time for a given date and location
  /// Using simplified algorithm (not astronomically accurate but good enough for minyan times)
  static DateTime _calculateSunrise(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    // Simplified sunrise calculation
    // In reality, would use more complex astronomical formulas
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    
    // Approximate sunrise time based on latitude
    var sunriseHour = 6.0;
    var sunriseMinute = 0;
    
    if (latitude > 40) {
      // Northern latitudes have earlier sunrise in summer
      if (dayOfYear > 80 && dayOfYear < 270) {
        sunriseHour = 5.0 + ((dayOfYear - 80) * 0.002);
      }
    } else if (latitude < -40) {
      // Southern latitudes
      if (dayOfYear > 80 && dayOfYear < 270) {
        sunriseHour = 6.5 - ((dayOfYear - 80) * 0.002);
      }
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      sunriseHour.toInt(),
      (sunriseMinute + ((sunriseHour - sunriseHour.toInt()) * 60)).toInt(),
    );
  }

  /// Calculate sunset time for a given date and location
  static DateTime _calculateSunset(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    // Simplified sunset calculation
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    
    // Approximate sunset time based on latitude
    var sunsetHour = 18.0;
    var sunsetMinute = 0;
    
    if (latitude > 40) {
      // Northern latitudes have later sunset in summer
      if (dayOfYear > 80 && dayOfYear < 270) {
        sunsetHour = 19.0 + ((dayOfYear - 80) * 0.002);
      }
    } else if (latitude < -40) {
      // Southern latitudes
      if (dayOfYear > 80 && dayOfYear < 270) {
        sunsetHour = 17.5 - ((dayOfYear - 80) * 0.002);
      }
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      sunsetHour.toInt(),
      (sunsetMinute + ((sunsetHour - sunsetHour.toInt()) * 60)).toInt(),
    );
  }

  /// Helper: Set time of day on a date
  static DateTime _setTimeOfDay(DateTime date, DateTime timeOfDay) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay.hour,
      timeOfDay.minute,
      timeOfDay.second,
    );
  }

  /// Helper: Format time as HH:MM AM/PM
  static String _formatTime(DateTime time) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(time);
  }
}
