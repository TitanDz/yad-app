import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class TravelModePage extends StatefulWidget {
  const TravelModePage({super.key});

  @override
  State<TravelModePage> createState() => _TravelModePageState();
}

class _TravelModePageState extends State<TravelModePage> {
  bool _travelModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Travel Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: AppTheme.purity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mode Section Title
                    Text(
                      'Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Travel Mode Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.celestial.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Travel Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Use your current location to suggest Minyanim near you',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                            value: _travelModeEnabled,
                            onChanged: (value) {
                              setState(() => _travelModeEnabled = value);
                            },
                            activeColor: AppTheme.primary,
                            thumbColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.white;
                              }
                              return Colors.white;
                            }),
                            trackColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppTheme.primary;
                              }
                              return AppTheme.celestial.withValues(alpha: 0.3);
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Text 1
                    Text(
                      'When Travel Mode is on, the app will use your current location to suggest Minyanim near you.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Text 2
                    Text(
                      'This is useful when you are traveling and want to find a Minyan near your current location.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preferences saved!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Save Preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
