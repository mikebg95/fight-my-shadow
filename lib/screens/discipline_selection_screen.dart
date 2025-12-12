import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/training_discipline.dart';
import 'package:fight_my_shadow/screens/boxing_home_screen.dart';
import 'package:fight_my_shadow/screens/coming_soon_screen.dart';
import 'package:fight_my_shadow/utils/responsive.dart';

/// Root screen where users select their training discipline.
///
/// This is the first screen shown when the app launches, allowing users
/// to choose between Boxing, Kickboxing, Muay Thai, or Kung Fu.
class DisciplineSelectionScreen extends StatelessWidget {
  const DisciplineSelectionScreen({super.key});

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

            // Discipline selection grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.horizontalPadding(context)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: Responsive.rs(context, 24)),
                    _buildDisciplineGrid(context),
                    SizedBox(height: Responsive.rs(context, 32)),
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
    final isSmall = Responsive.isSmallPhone(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, Responsive.rs(context, 32), horizontalPadding, Responsive.rs(context, 40)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            const Color(0xFF0A0A0A).withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          // App icon/logo
          Container(
            padding: EdgeInsets.all(Responsive.rs(context, 20)),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.sports_martial_arts,
              color: Colors.white,
              size: Responsive.iconSize(context, isSmall ? 40 : 48),
            ),
          ),
          SizedBox(height: Responsive.rs(context, 32)),

          // Title
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'FIGHT MY SHADOW',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: Responsive.rf(context, 28),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          SizedBox(height: Responsive.rs(context, 16)),

          // Main heading
          Text(
            'Choose Your Discipline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: Responsive.rf(context, 22),
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.rs(context, 12)),

          // Subtitle
          Text(
            'Select your martial art to customize your training',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: Responsive.rf(context, 16),
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineGrid(BuildContext context) {
    final spacing = Responsive.rs(context, 16);
    // Adjust aspect ratio for smaller screens to prevent overflow
    final aspectRatio = Responsive.isSmallPhone(context) ? 0.88 : 0.95;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
      children: TrainingDiscipline.values.map((discipline) {
        return _DisciplineCard(discipline: discipline);
      }).toList(),
    );
  }

}

/// Individual discipline selection card.
class _DisciplineCard extends StatelessWidget {
  final TrainingDiscipline discipline;

  const _DisciplineCard({required this.discipline});

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

  void _handleTap(BuildContext context) {
    if (discipline == TrainingDiscipline.boxing) {
      // Navigate to Boxing home screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BoxingHomeScreen(),
        ),
      );
    } else {
      // Navigate to Coming Soon screen for other disciplines
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComingSoonScreen(discipline: discipline),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(context);
    final isSmall = Responsive.isSmallPhone(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.rs(context, 12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 12 : 16)),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: Responsive.iconSize(context, isSmall ? 26 : 32),
                  ),
                ),
                SizedBox(height: Responsive.rs(context, 12)),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.rs(context, 8)),
                  child: Text(
                    discipline.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.rf(context, isSmall ? 14 : 16),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: Responsive.rs(context, 4)),

                // Description
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.rs(context, 10)),
                    child: Text(
                      discipline.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: Responsive.rf(context, isSmall ? 10 : 11),
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
