import 'package:flutter/material.dart';
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/screens/library_screen.dart';
import 'package:fight_my_shadow/screens/combinations_screen.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/models/training_discipline.dart';
import 'package:fight_my_shadow/utils/responsive.dart';

/// Boxing home screen - hub for all boxing-specific features.
///
/// Contains navigation to Academy, Training Session, Move Library, and Combinations.
class BoxingHomeScreen extends StatelessWidget {
  const BoxingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(context),

            // Main content
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  Responsive.horizontalPadding(context),
                  8,
                  Responsive.horizontalPadding(context),
                  20,
                ),
                children: [
                  SizedBox(height: Responsive.rs(context, 16)),

                  // Academy option
                  _buildOptionCard(
                    context,
                    title: 'ACADEMY',
                    subtitle: 'Learn moves step by step',
                    icon: Icons.school,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade600,
                        Colors.purple.shade800,
                      ],
                    ),
                    glowColor: Colors.purple.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LearningProgressScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.rs(context, 16)),

                  // Training Session option
                  _buildOptionCard(
                    context,
                    title: 'TRAINING SESSION',
                    subtitle: 'Create and start workouts',
                    icon: Icons.fitness_center,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade600,
                        Colors.red.shade800,
                      ],
                    ),
                    glowColor: Colors.red.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            discipline: TrainingDiscipline.boxing,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.rs(context, 16)),

                  // Move Library option
                  _buildOptionCard(
                    context,
                    title: 'MOVE LIBRARY',
                    subtitle: 'Browse boxing moves',
                    icon: Icons.library_books,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    glowColor: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LibraryScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.rs(context, 16)),

                  // Combinations option
                  _buildOptionCard(
                    context,
                    title: 'COMBINATIONS',
                    subtitle: 'Strike sequences',
                    icon: Icons.view_timeline,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.yellow.shade700,
                      ],
                    ),
                    glowColor: Colors.amber.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CombinationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    return Container(
      padding: EdgeInsets.all(padding),
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
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: Responsive.iconSize(context, 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: Responsive.rs(context, 16)),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOXING',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: Responsive.rf(context, 20),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your training mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: Responsive.rf(context, 14),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Boxing icon
          Container(
            padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 10 : 12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade600,
                  Colors.red.shade800,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.front_hand,
              color: Colors.white,
              size: Responsive.iconSize(context, isSmall ? 20 : 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    final isSmall = Responsive.isSmallPhone(context);
    final cardHeight = Responsive.rs(context, isSmall ? 88 : 100);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.rs(context, isSmall ? 14 : 20),
              vertical: Responsive.rs(context, 14),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 10 : 14)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: Responsive.iconSize(context, isSmall ? 26 : 32),
                  ),
                ),
                SizedBox(width: Responsive.rs(context, isSmall ? 14 : 20)),

                // Text content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              fontSize: Responsive.rf(context, isSmall ? 15 : 18),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: Responsive.rf(context, isSmall ? 12 : 14),
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: Responsive.iconSize(context, isSmall ? 16 : 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
