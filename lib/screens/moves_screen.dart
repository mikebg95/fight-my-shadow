import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';

/// Screen that displays all available moves in a scrollable list.
///
/// This is a read-only view of the moves catalog.
class MovesScreen extends StatelessWidget {
  const MovesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = InMemoryMoveRepository();
    final moves = repository.getAllMoves();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, moves.length),

            // Moves list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: moves.length,
                itemBuilder: (context, index) {
                  return _MoveListItem(move: moves[index]);
                },
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
                color: Colors.white.withOpacity(0.1),
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
                  'MOVES',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$moveCount punches & kicks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.6),
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
}

/// Individual move list item widget.
///
/// Displays move code, name, and category in a styled card.
class _MoveListItem extends StatelessWidget {
  final Move move;

  const _MoveListItem({required this.move});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
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
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 6),
                  _buildCategoryChip(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBadge(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          move.code,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
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
      case MoveCategory.kick:
        categoryColor = Colors.blue.shade700;
        categoryIcon = Icons.sports_martial_arts;
        break;
      case MoveCategory.other:
        categoryColor = Colors.grey.shade700;
        categoryIcon = Icons.more_horiz;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: 14,
            color: categoryColor,
          ),
          const SizedBox(width: 6),
          Text(
            move.category.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: categoryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
