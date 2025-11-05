import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MinyanData {
  String? prayerType;
  DateTime? date;
  TimeOfDay? time;
  String? notes;
  String? locationName;
  double? latitude;
  double? longitude;

  MinyanData({
    this.prayerType,
    this.date,
    this.time,
    this.notes,
    this.locationName,
    this.latitude,
    this.longitude,
  });
}

class CreateMinyanPage extends StatefulWidget {
  const CreateMinyanPage({super.key});

  @override
  State<CreateMinyanPage> createState() => _CreateMinyanPageState();
}

class _CreateMinyanPageState extends State<CreateMinyanPage> {
  int _currentStep = 0;
  late MinyanData _minyanData;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedPrayerType = '';

  @override
  void initState() {
    super.initState();
    _minyanData = MinyanData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Minyan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildStepContent(_currentStep),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildPrayerTypeStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildConfirmStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildPrayerTypeStep();
    }
  }

  Widget _buildPrayerTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prayer Type Section
          const Text(
            'Prayer Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPrayerTypeButton('Shacharit'),
              _buildPrayerTypeButton('Mincha'),
              _buildPrayerTypeButton('Maariv'),
            ],
          ),
          const SizedBox(height: 32),

          // Date Section
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _minyanData.date ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (selectedDate != null && mounted) {
                setState(() {
                  _minyanData.date = selectedDate;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Date selected: ${selectedDate.toString().split(' ')[0]}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _minyanData.date != null
                        ? _minyanData.date.toString().split(' ')[0]
                        : 'Select Date',
                    style: TextStyle(
                      color: _minyanData.date != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: _minyanData.date != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Time Section
          const Text(
            'Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: _minyanData.time ?? TimeOfDay.now(),
              );
              if (selectedTime != null && mounted) {
                setState(() {
                  _minyanData.time = selectedTime;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Time selected: ${selectedTime.format(context)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _minyanData.time != null
                        ? _minyanData.time!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      color: _minyanData.time != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: _minyanData.time != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Notes Section
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            onChanged: (value) {
              setState(() {
                _minyanData.notes = value.isNotEmpty ? value : null;
              });
            },
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Add notes about your minyan...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPrayerType.isEmpty || _minyanData.date == null || _minyanData.time == null
                  ? null
                  : () {
                      setState(() => _currentStep = 1);
                    },
              child: const Text('Continue to Location'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTypeButton(String label) {
    final isSelected = _selectedPrayerType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrayerType = isSelected ? '' : label;
          _minyanData.prayerType = isSelected ? null : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Placeholder for map with tap detection
              GestureDetector(
                onTapDown: (details) {
                  // Simulate map tap to select location
                  _showLocationConfirmDialog(
                    'Tapped Location',
                    40.7128,
                    -74.0060,
                    'Tapped Location on Map',
                  );
                },
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap on map to select location',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        if (_minyanData.locationName != null) ...
                          [
                            const SizedBox(height: 8),
                            Text(
                              _minyanData.locationName!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
              // Search Bar
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _minyanData.locationName = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Location set to: $value'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for location',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _minyanData.locationName != null
                    ? () {
                        setState(() => _currentStep = 2);
                      }
                    : null,
                child: const Text('Set Location'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Set Location Privacy'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavIcon(Icons.location_on, 'Map', true),
                  _buildBottomNavIcon(Icons.notifications, 'Notifications', false),
                  _buildBottomNavIcon(Icons.settings, 'Settings', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLocationConfirmDialog(
    String locationName,
    double lat,
    double lng,
    String address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locationName),
            const SizedBox(height: 8),
            Text(
              address,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _minyanData.locationName = locationName;
                _minyanData.latitude = lat;
                _minyanData.longitude = lng;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location set to: $locationName'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    final dateStr = _minyanData.date != null
        ? '${_minyanData.date!.toString().split(' ')[0]} (${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_minyanData.date!.weekday - 1]})'
        : 'Not selected';
    final timeStr = _minyanData.time != null
        ? _minyanData.time!.format(context)
        : 'Not selected';
    final prayerTypeStr = _minyanData.prayerType ?? 'Not selected';
    final locationStr = _minyanData.locationName ?? 'Not selected';
    final notesStr = _minyanData.notes ?? 'No notes added';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minyan Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailItem(Icons.menu_book, 'Prayer Type', prayerTypeStr),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.calendar_today, 'Date', dateStr),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.access_time, 'Time', timeStr),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.location_on, 'Location', locationStr),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.note, 'Notes', notesStr),
          const SizedBox(height: 48),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep = 0);
                  },
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _currentStep = 3);
                  },
                  child: const Text('Publish Minyan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        // Header illustration area
        Expanded(
          child: Container(
            color: const Color(0xFFFAE8D8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Minyan is live!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Share the link below or the QR code to invite others to join your Minyan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Link and QR Code section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Link field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'https://yad-yad.app/minyan/abc123',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.content_copy,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // QR Code placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAE8D8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Share Link'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Share QR Code'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavIcon(Icons.location_on, 'Map', true),
                  _buildBottomNavIcon(Icons.notifications, 'Notifications', false),
                  _buildBottomNavIcon(Icons.settings, 'Settings', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
