import 'package:flutter/material.dart';
import 'package:fight_my_shadow/screens/moves_screen.dart';
import 'package:fight_my_shadow/screens/combinations_screen.dart';
import 'package:fight_my_shadow/utils/responsive.dart';

/// Move Library screen that provides access to the moves catalog.
///
/// This screen shows all available boxing moves organized by category.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content area
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 20),
                children: [
                  const SizedBox(height: 8),

                  // Moves card - navigate directly to moves list
                  _LibraryCard(
                    title: 'Moves',
                    subtitle: 'Punches & kicks catalog',
                    icon: Icons.sports_martial_arts,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MovesScreen(),
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
                size: Responsive.iconSize(context, isSmall ? 20 : 24),
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
                  'MOVE LIBRARY',
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
                  'Browse boxing moves',
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

          // Icon
          Container(
            padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 10 : 12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.library_books,
              color: Colors.white,
              size: Responsive.iconSize(context, isSmall ? 20 : 24),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual library item card widget.
///
/// Displays a navigable card with icon, title, and subtitle.
class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final iconBoxSize = Responsive.rs(context, isSmall ? 48 : 56);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: Responsive.iconSize(context, isSmall ? 24 : 28),
                ),
              ),
              SizedBox(width: Responsive.rs(context, isSmall ? 14 : 20)),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.rf(context, isSmall ? 16 : 18),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: Responsive.rf(context, isSmall ? 12 : 14),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
                size: Responsive.iconSize(context, isSmall ? 24 : 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
