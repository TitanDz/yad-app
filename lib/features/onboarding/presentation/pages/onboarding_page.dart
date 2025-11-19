import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingScreen> screens = [
    OnboardingScreen(
      title: 'Connect with Your Community',
      description: 'Find or create prayer groups (Minyanim) easily, wherever you are.',
      illustration: 'assets/images/illustrations/Group 79.svg',
    ),
    OnboardingScreen(
      title: 'Find a Minyan\nnear you',
      description: 'Use the map to find a Minyan near you. Tap on a pin to see more details.',
      illustration: 'assets/images/illustrations/Group 80.svg',
    ),
    OnboardingScreen(
      title: 'Create a Minyan',
      description: 'Start by specifying the details of your Minyan, including the location and time. This will help others find and join your prayer group.',
      illustration: 'assets/images/illustrations/Group 81.svg',
    ),
    OnboardingScreen(
      title: 'Enable Permissions',
      description: 'To connect you with nearby Minyanim and keep you informed, we need a few permissions. This ensures you never miss a prayer opportunity.',
      illustration: 'assets/images/illustrations/Group 77.svg',
      showPermissions: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/welcome');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: screens.length,
            itemBuilder: (context, index) => _buildOnboardingScreen(screens[index]),
          ),
          // Top Right Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.divinity,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              color: const Color(0xFFFAF8F2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      screens.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? AppTheme.divinity
                              : AppTheme.divinity.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Next/Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.divinity,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == screens.length - 1 ? 'Allow Permissions' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Go Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _currentPage > 0 ? _previousPage : _skipOnboarding,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.divinity.withValues(alpha: 0.5),
                        side: BorderSide(
                          color: AppTheme.divinity.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.divinity.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingScreen(OnboardingScreen screen) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFFAF8F2),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                // Title and Description
                Column(
                  children: [
                    Text(
                      screen.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.divinity,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      screen.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6B6560),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    screens.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? AppTheme.divinity
                            : AppTheme.divinity.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Illustration
                if (screen.showPermissions)
                  _buildPermissionsContent()
                else
                  SvgPicture.asset(
                    screen.illustration,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsContent() {
    return Column(
      children: [
        // Location Services
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.divinity,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To find Minyanim near you',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.divinity,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Notifications
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.divinity,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To notify you about Minyanim',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.divinity,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Illustration for permissions
        SvgPicture.asset(
          'assets/images/illustrations/Group 77.svg',
          height: 200,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class OnboardingScreen {
  final String title;
  final String description;
  final String illustration;
  final bool showPermissions;

  OnboardingScreen({
    required this.title,
    required this.description,
    required this.illustration,
    this.showPermissions = false,
  });
}
