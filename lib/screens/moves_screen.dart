import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/screens/move_detail_screen.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_progress_service.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';

/// Screen that displays all available moves grouped by category.
///
/// Shows Boxing moves organized into Punches, Defense, and Footwork sections.
/// Locked moves (not yet unlocked in Story Mode) are displayed with a lock
/// icon and greyed-out styling.
class MovesScreen extends StatefulWidget {
  const MovesScreen({super.key});

  @override
  State<MovesScreen> createState() => _MovesScreenState();
}

class _MovesScreenState extends State<MovesScreen> {
  late LearningState _learningState;

  @override
  void initState() {
    super.initState();
    // Initialize learning state
    // In future, this will load from persistence
    _learningState = LearningProgressService.initializeFreshState();
  }

  @override
  Widget build(BuildContext context) {
    final repository = InMemoryMoveRepository();

    // Get moves by category
    final punches = repository.getMovesByCategory(MoveCategory.punch);
    final defense = repository.getMovesByCategory(MoveCategory.defense);
    final footwork = repository.getMovesByCategory(MoveCategory.footwork);

    // Sort punches numerically by code (1, 2, 3, ..., 14)
    punches.sort((a, b) {
      final aNum = int.tryParse(a.code) ?? 999;
      final bNum = int.tryParse(b.code) ?? 999;
      return aNum.compareTo(bNum);
    });

    // Sort defense and footwork alphabetically by code
    defense.sort((a, b) => a.code.compareTo(b.code));
    footwork.sort((a, b) => a.code.compareTo(b.code));

    final totalMoves = repository.totalMoves;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, totalMoves),

            // Moves list with category sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // Punches section
                  _buildSectionHeader(context, 'Punches', punches.length),
                  ...punches.map((move) => _MoveListItem(
                        move: move,
                        isLocked: !MoveLockStatusResolver.isUnlocked(
                          move.code,
                          _learningState,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                  const SizedBox(height: 16),

                  // Defense section
                  _buildSectionHeader(context, 'Defense', defense.length),
                  ...defense.map((move) => _MoveListItem(
                        move: move,
                        isLocked: !MoveLockStatusResolver.isUnlocked(
                          move.code,
                          _learningState,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                  const SizedBox(height: 16),

                  // Footwork section
                  _buildSectionHeader(context, 'Footwork', footwork.length),
                  ...footwork.map((move) => _MoveListItem(
                        move: move,
                        isLocked: !MoveLockStatusResolver.isUnlocked(
                          move.code,
                          _learningState,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int moveCount) {
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

          // Title and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOXING MOVES',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$moveCount moves total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),

          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_martial_arts,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Move move) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoveDetailScreen(move: move),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual move list item widget.
///
/// Displays move code, name, and category in a styled card.
/// Shows lock icon and greyed styling when move is locked.
class _MoveListItem extends StatelessWidget {
  final Move move;
  final bool isLocked;
  final VoidCallback onTap;

  const _MoveListItem({
    required this.move,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Apply opacity to entire card when locked
    final cardOpacity = isLocked ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: cardOpacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isLocked
                ? const Color(0xFF141414) // Slightly darker when locked
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: isLocked ? 0.02 : 0.05,
              ),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Code badge
                _buildCodeBadge(context),
                const SizedBox(width: 16),

                // Name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        move.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      _buildCategoryChip(context),
                    ],
                  ),
                ),

                // Lock icon or chevron indicator
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBadge(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isLocked
            ? LinearGradient(
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade700,
                ],
              )
            : LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          move.code,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isLocked
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    Color categoryColor;
    IconData categoryIcon;

    switch (move.category) {
      case MoveCategory.punch:
        categoryColor = Colors.orange.shade700;
        categoryIcon = Icons.front_hand;
        break;
      case MoveCategory.defense:
        categoryColor = Colors.blue.shade700;
        categoryIcon = Icons.shield;
        break;
      case MoveCategory.footwork:
        categoryColor = Colors.purple.shade700;
        categoryIcon = Icons.directions_walk;
        break;
    }

    // Mute the category color when locked
    final displayColor = isLocked
        ? Colors.grey.shade700
        : categoryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: isLocked ? 0.15 : 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: displayColor.withValues(alpha: isLocked ? 0.2 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: 14,
            color: isLocked
                ? displayColor.withValues(alpha: 0.6)
                : displayColor,
          ),
          const SizedBox(width: 6),
          Text(
            move.category.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? displayColor.withValues(alpha: 0.6)
                  : displayColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
