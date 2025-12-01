import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

/// Quick action floating action button with expandable menu
class QuickActionFAB extends StatefulWidget {
  final VoidCallback? onCreateMinyan;
  final VoidCallback? onSearch;
  final VoidCallback? onToggleAvailability;
  final bool isAvailable;

  const QuickActionFAB({
    super.key,
    this.onCreateMinyan,
    this.onSearch,
    this.onToggleAvailability,
    this.isAvailable = true,
  });

  @override
  State<QuickActionFAB> createState() => _QuickActionFABState();
}

class _QuickActionFABState extends State<QuickActionFAB>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blur background when menu is open
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: Colors.black.withValues(alpha: _animationController.value * 0.3),
            ),
          ),
        // Menu items (expanded)
        if (_isExpanded) ..._buildMenuItems(context),
        // Main FAB button
        Positioned(
          bottom: 24,
          right: 24,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.8).animate(_animationController),
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppTheme.divinity,
              child: RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(_animationController),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      // Create Minyan action
      Positioned(
        bottom: 120,
        right: 24,
        child: ScaleTransition(
          scale: _buildItemScale(0),
          child: SlideTransition(
            position: _buildItemOffset(0),
            child: _buildActionButton(
              icon: Icons.add_location_alt_outlined,
              label: 'Create Minyan',
              onTap: () {
                _toggleMenu();
                widget.onCreateMinyan?.call();
                context.push('/create-minyan');
              },
            ),
          ),
        ),
      ),
      // Search action
      Positioned(
        bottom: 180,
        right: 24,
        child: ScaleTransition(
          scale: _buildItemScale(1),
          child: SlideTransition(
            position: _buildItemOffset(1),
            child: _buildActionButton(
              icon: Icons.search,
              label: 'Quick Search',
              onTap: () {
                _toggleMenu();
                widget.onSearch?.call();
              },
            ),
          ),
        ),
      ),
      // Availability toggle action
      Positioned(
        bottom: 240,
        right: 24,
        child: ScaleTransition(
          scale: _buildItemScale(2),
          child: SlideTransition(
            position: _buildItemOffset(2),
            child: _buildActionButton(
              icon: widget.isAvailable
                  ? Icons.do_not_disturb_off_outlined
                  : Icons.do_not_disturb_on_outlined,
              label: widget.isAvailable ? 'Set Unavailable' : 'Back Online',
              onTap: () {
                _toggleMenu();
                widget.onToggleAvailability?.call();
              },
            ),
          ),
        ),
      ),
    ];
  }

  Animation<double> _buildItemScale(int index) {
    final staggerInterval = 50.0;
    final delay = index * staggerInterval / 300.0;
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _buildItemOffset(int index) {
    final staggerInterval = 50.0;
    final delay = index * staggerInterval / 300.0;
    return Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.divinity.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.divinity.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.divinity,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.divinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
