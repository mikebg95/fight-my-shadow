import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/training_discipline.dart';

/// Coming Soon screen for disciplines that are not yet implemented.
///
/// Shows a placeholder message with back navigation to discipline selection.
class ComingSoonScreen extends StatelessWidget {
  final TrainingDiscipline discipline;

  const ComingSoonScreen({
    super.key,
    required this.discipline,
  });

  Color _getAccentColor(BuildContext context) {
    switch (discipline) {
      case TrainingDiscipline.boxing:
        return Colors.red.shade600;
      case TrainingDiscipline.kickboxing:
        return Theme.of(context).colorScheme.primary;
      case TrainingDiscipline.muayThai:
        return Colors.orange.shade700;
      case TrainingDiscipline.kungFu:
        return Colors.amber.shade700;
    }
  }

  IconData _getIcon() {
    switch (discipline) {
      case TrainingDiscipline.boxing:
        return Icons.front_hand;
      case TrainingDiscipline.kickboxing:
        return Icons.sports_martial_arts;
      case TrainingDiscipline.muayThai:
        return Icons.fitness_center;
      case TrainingDiscipline.kungFu:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(context),

            // Main content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIcon(),
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        '${discipline.label} Coming Soon',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'This discipline is not available yet.\nCheck back later for updates!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Back button
                      _buildBackButton(context, accentColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              discipline.label.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, Color accentColor) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'BACK TO DISCIPLINES',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
