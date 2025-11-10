import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/features/home/presentation/bloc/minyan_bloc.dart';

class MinyanPage extends StatefulWidget {
  const MinyanPage({super.key});

  @override
  State<MinyanPage> createState() => _MinyanPageState();
}

class _MinyanPageState extends State<MinyanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPrayerType;
  String _sortBy = 'distance';
  String? _selectedDate;
  double _maxDistance = 10.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChange);
    context.read<MinyanBloc>().add(const LoadMyMinyansEvent());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.index == 1) {
      context.read<MinyanBloc>().add(const LoadNearbyMinyansEvent());
    }
  }

  void _applyFilters() {
    if (_tabController.index == 0) {
      // My Minyans filters
      context.read<MinyanBloc>().add(
        FilterMinyansEvent(
          prayerType: _selectedPrayerType,
          filterByDate: _selectedDate,
          maxDistance: _maxDistance,
          isMyMinyans: true,
        ),
      );
    } else {
      // Nearby Minyans filters
      context.read<MinyanBloc>().add(
        FilterMinyansEvent(
          prayerType: _selectedPrayerType,
          sortBy: _sortBy,
          isMyMinyans: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Minyanim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'MY MINYANS'),
            Tab(text: 'NEARBY'),
          ],
        ),
      ),
      body: BlocListener<MinyanBloc, MinyanState>(
        listener: (context, state) {
          if (state is MinyanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
          } else if (state is MinyanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildFilterSection(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyMinyansList(),
                  _buildNearbyMinyansList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterButton(
              label: 'Prayer Type',
              onTap: () => _showPrayerTypeFilter(),
            ),
            const SizedBox(width: 8),
            if (_tabController.index == 0) ...
              [
                _buildFilterButton(
                  label: 'Date',
                  onTap: () => _showDateFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  label: 'Distance: ${_maxDistance.toStringAsFixed(1)} mi',
                  onTap: () => _showDistanceFilter(),
                ),
              ]
            else
              _buildFilterButton(
                label: 'Sort: $_sortBy',
                onTap: () => _showSortOptions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyMinyansList() {
    return BlocBuilder<MinyanBloc, MinyanState>(
      builder: (context, state) {
        if (state is MinyanLoading && state.isMyMinyans) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MyMinyanLoaded) {
          if (state.minyans.isEmpty) {
            return _buildEmptyState(
              'No minyans created yet',
              'Create your first minyan to get started',
              onAction: () => context.push('/create-minyan'),
            );
          }
          return _buildMinyansList(state.minyans, isMyMinyans: true);
        }

        if (state is MinyanError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildNearbyMinyansList() {
    return BlocBuilder<MinyanBloc, MinyanState>(
      builder: (context, state) {
        if (state is MinyanLoading && !state.isMyMinyans) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NearbyMinyanLoaded) {
          if (state.minyans.isEmpty) {
            return _buildEmptyState(
              'No minyans nearby',
              'Expand your search radius or check back later',
            );
          }
          return _buildMinyansList(state.minyans, isMyMinyans: false);
        }

        if (state is MinyanError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMinyansList(List<Minyan> minyans, {required bool isMyMinyans}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: minyans.length,
      itemBuilder: (context, index) {
        return _buildMinyanCard(minyans[index], isMyMinyans);
      },
    );
  }

  Widget _buildMinyanCard(Minyan minyan, bool isMyMinyans) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(minyan, isMyMinyans),
            const SizedBox(height: 8),
            _buildCardTime(minyan),
            const SizedBox(height: 8),
            _buildCardLocation(minyan),
            const SizedBox(height: 12),
            _buildCardActions(minyan, isMyMinyans),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Minyan minyan, bool isMyMinyans) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  minyan.prayerType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        isMyMinyans
            ? Text(
                minyan.date,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Text(
                '${minyan.distance?.toStringAsFixed(1) ?? '0.0'} mi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ],
    );
  }

  Widget _buildCardTime(Minyan minyan) {
    return Text(
      minyan.time,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCardLocation(Minyan minyan) {
    return Row(
      children: [
        Expanded(
          child: Text(
            minyan.locationName,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '${minyan.participantCount} participant${minyan.participantCount != 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(Minyan minyan, bool isMyMinyans) {
    if (isMyMinyans) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.read<MinyanBloc>().add(DeleteMinyanEvent(minyan.id)),
              icon: const Icon(Icons.delete_outlined, size: 16),
              label: const Text('Delete', style: TextStyle(fontSize: 12)),
            ),
          ),
          if (minyan.status == 'draft') ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context
                    .read<MinyanBloc>()
                    .add(PublishMinyanEvent(minyan.id)),
                icon: const Icon(Icons.publish_outlined, size: 16),
                label: const Text('Publish', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () =>
              context.read<MinyanBloc>().add(JoinMinyanEvent(minyan.id)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          icon: const Icon(Icons.group_add, size: 18),
          label: const Text(
            'Join Minyan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState(
    String title,
    String subtitle, {
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Create Minyan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<MinyanBloc>().add(const LoadMyMinyansEvent());
              } else {
                context.read<MinyanBloc>().add(const LoadNearbyMinyansEvent());
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPrayerTypeFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.surface,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Prayer Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildFilterOptions(
                    ['Shacharit', 'Mincha', 'Maariv'],
                    _selectedPrayerType,
                    (type) {
                      setState(() {
                        _selectedPrayerType = _selectedPrayerType == type ? null : type;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ..._buildFilterOptions(
              ['distance', 'time'],
              _sortBy,
              (sort) {
                setState(() => _sortBy = sort);
                _applyFilters();
                Navigator.pop(context);
              },
              labelMap: {'distance': 'Distance', 'time': 'Time'},
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterOptions(
    List<String> options,
    String? selected,
    Function(String) onSelect, {
    Map<String, String>? labelMap,
  }) {
    return options.map((option) {
      final isSelected = selected == option;
      final label = labelMap?[option] ?? option;
      return InkWell(
        onTap: () => onSelect(option),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showDateFilter() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? DateTime.parse(_selectedDate!) : DateTime.now(),
      firstDate: DateTime(2024, 12, 1),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final formattedDate = picked.toString().split(' ')[0];
      setState(() => _selectedDate = formattedDate);
      _applyFilters();
    }
  }

  void _showDistanceFilter() {
    double tempDistance = _maxDistance;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) => Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter by Distance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '${tempDistance.toStringAsFixed(1)} miles',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: tempDistance,
                min: 0.5,
                max: 50.0,
                divisions: 99,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                label: '${tempDistance.toStringAsFixed(1)} mi',
                onChanged: (value) {
                  setStateLocal(() => tempDistance = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0.5 mi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '50 mi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _maxDistance = tempDistance);
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
