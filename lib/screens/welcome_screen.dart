import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/training_discipline.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';

/// Welcome screen where users select their training discipline.
///
/// This is the first screen shown when the app launches, allowing users
/// to choose between Boxing, Kickboxing, Muay Thai, or Kung Fu before
/// proceeding to the workout setup.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero section with branding
            SliverToBoxAdapter(
              child: _buildHeroSection(context),
            ),

            // Sport selection grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildStoryModeButton(context),
                    const SizedBox(height: 32),
                    _buildSportGrid(context),
                    const SizedBox(height: 32),
                    _buildFooterText(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            const Color(0xFF0A0A0A).withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          // App icon/logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_martial_arts,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'FIGHT MY SHADOW',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Main heading
          Text(
            'Choose Your Discipline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Select your martial art to customize your training',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSportGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: TrainingDiscipline.values.map((discipline) {
        return _SportCard(discipline: discipline);
      }).toList(),
    );
  }

  Widget _buildStoryModeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade600,
            Colors.purple.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade600.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LearningProgressScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STORY MODE',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Learn moves step by step',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Text(
      'You can change this later in settings',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
      textAlign: TextAlign.center,
    );
  }
}

/// Individual sport selection card.
class _SportCard extends StatelessWidget {
  final TrainingDiscipline discipline;

  const _SportCard({required this.discipline});

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

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(discipline: discipline),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                discipline.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  discipline.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
