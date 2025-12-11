import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/screens/move_detail_screen.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/data/boxing_moves_data.dart';

/// Library screen that displays all available moves grouped by category.
///
/// Shows Boxing moves organized into Punches, Defense, Footwork, and Deception sections.
/// Moves are ordered according to the Academy learning path.
/// Locked moves (not yet unlocked in Academy) are displayed with a lock
/// icon and greyed-out styling.
class MovesScreen extends StatelessWidget {
  const MovesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the controller for state changes
    final controller = context.watch<StoryModeController>();
    final learningState = controller.state;
    final currentMove = learningState.currentMove;

    final repository = InMemoryMoveRepository();

    // Get all moves in Academy order
    final allMovesOrdered = getMovesInAcademyOrder();

    // Group by category while preserving Academy order within each category
    final punches = allMovesOrdered.where((m) => m.category == MoveCategory.punch).toList();
    final defense = allMovesOrdered.where((m) => m.category == MoveCategory.defense).toList();
    final footwork = allMovesOrdered.where((m) => m.category == MoveCategory.footwork).toList();
    final deception = allMovesOrdered.where((m) => m.category == MoveCategory.deception).toList();

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
                        unlockState: MoveLockStatusResolver.getUnlockState(
                          move.code,
                          learningState,
                          currentMove,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                  const SizedBox(height: 16),

                  // Defense section
                  _buildSectionHeader(context, 'Defense', defense.length),
                  ...defense.map((move) => _MoveListItem(
                        move: move,
                        unlockState: MoveLockStatusResolver.getUnlockState(
                          move.code,
                          learningState,
                          currentMove,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                  const SizedBox(height: 16),

                  // Footwork section
                  _buildSectionHeader(context, 'Footwork', footwork.length),
                  ...footwork.map((move) => _MoveListItem(
                        move: move,
                        unlockState: MoveLockStatusResolver.getUnlockState(
                          move.code,
                          learningState,
                          currentMove,
                        ),
                        onTap: () => _navigateToDetail(context, move),
                      )),
                  const SizedBox(height: 16),

                  // Deception section
                  _buildSectionHeader(context, 'Deception', deception.length),
                  ...deception.map((move) => _MoveListItem(
                        move: move,
                        unlockState: MoveLockStatusResolver.getUnlockState(
                          move.code,
                          learningState,
                          currentMove,
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
/// Shows different visual states: Unlocked, Ready to Unlock, or Locked.
class _MoveListItem extends StatelessWidget {
  final Move move;
  final MoveUnlockState unlockState;
  final VoidCallback onTap;

  const _MoveListItem({
    required this.move,
    required this.unlockState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine visual properties based on unlock state
    final isLocked = unlockState == MoveUnlockState.locked;
    final isReadyToUnlock = unlockState == MoveUnlockState.readyToUnlock;

    // Card opacity
    final cardOpacity = isLocked ? 0.5 : 1.0;

    // Border styling for ready-to-unlock state
    final borderColor = isReadyToUnlock
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
        : isLocked
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.05);

    final borderWidth = isReadyToUnlock ? 2.0 : 1.0;

    // Background color
    final backgroundColor = isReadyToUnlock
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
        : isLocked
            ? const Color(0xFF141414)
            : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: cardOpacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            // Subtle glow for ready-to-unlock
            boxShadow: isReadyToUnlock
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
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

                // State indicator badge
                _buildStateBadge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the state badge (checkmark, unlock, or lock icon).
  Widget _buildStateBadge(BuildContext context) {
    switch (unlockState) {
      case MoveUnlockState.unlocked:
        // Green checkmark badge
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade400.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.check_circle,
            color: Colors.green.shade400,
            size: 24,
          ),
        );

      case MoveUnlockState.readyToUnlock:
        // Orange "Unlock" badge with key icon
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.lock_open,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'UNLOCK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );

      case MoveUnlockState.locked:
        // Grey lock icon
        return Container(
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
        );
    }
  }

  Widget _buildCodeBadge(BuildContext context) {
    final isLocked = unlockState == MoveUnlockState.locked;
    final isActive = unlockState == MoveUnlockState.unlocked ||
                     unlockState == MoveUnlockState.readyToUnlock;

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
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
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
      case MoveCategory.deception:
        categoryColor = Colors.amber.shade700;
        categoryIcon = Icons.swap_horiz;
        break;
    }

    // Mute the category color when locked
    final isLocked = unlockState == MoveUnlockState.locked;
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
