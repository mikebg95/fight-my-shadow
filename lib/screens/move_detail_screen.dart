import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/controllers/training_preferences_controller.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/screens/academy_exam_screen.dart';

/// Screen that displays detailed information about a single move.
///
/// Shows the move's name, code, category, discipline, description, tips,
/// and a placeholder area for future images/animations.
/// Also shows an UNLOCK button for moves that are ready to unlock.
class MoveDetailScreen extends StatelessWidget {
  final Move move;

  const MoveDetailScreen({super.key, required this.move});

  void _handleUnlock(BuildContext context) async {
    // Find the LearningMove that corresponds to this Move
    final allLearningMoves = LearningPath.getAllMoves();
    LearningMove? targetLearningMove;

    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(move.code)) {
        targetLearningMove = learningMove;
        break;
      }
    }

    if (targetLearningMove == null) return;

    // Get controller and unlock the move
    final controller = context.read<StoryModeController>();
    await controller.unlockMove(targetLearningMove.id);
  }

  void _handleStartDrill(BuildContext context) async {
    // Find the LearningMove that corresponds to this Move
    final allLearningMoves = LearningPath.getAllMoves();
    LearningMove? targetLearningMove;

    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(move.code)) {
        targetLearningMove = learningMove;
        break;
      }
    }

    if (targetLearningMove == null) return;

    // Launch drill session with this move
    final config = WorkoutConfiguration.drill(
      moveCode: move.code,
      difficulty: Difficulty.beginner, // Always beginner for learning drills
    );

    final result = await Navigator.push<DrillSessionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(config: config),
      ),
    );

    // If drill was completed, mark it as done
    if (result != null && result.completed) {
      final controller = context.read<StoryModeController>();
      await controller.markDrillDone(targetLearningMove.id);
    }
  }

  void _handleAddToArsenal(BuildContext context) async {
    // Find the LearningMove that corresponds to this Move
    final allLearningMoves = LearningPath.getAllMoves();
    LearningMove? targetLearningMove;

    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(move.code)) {
        targetLearningMove = learningMove;
        break;
      }
    }

    if (targetLearningMove == null) return;

    // Get all unlocked moves from learning state
    final controller = context.read<StoryModeController>();
    final learningState = controller.state;

    // Collect all unlocked move codes
    final unlockedMoveCodes = <String>[];

    for (final learningMove in allLearningMoves) {
      final progress = learningState.getProgressForMove(learningMove.id);
      if (progress != null && progress.isUnlocked) {
        // Add all move codes from this learning move
        unlockedMoveCodes.addAll(learningMove.moveCodes);
      }
    }

    // Add the target move code (even though it's not unlocked yet)
    final allowedMoveCodes = [...unlockedMoveCodes, move.code];

    // Launch Arsenal session with weighted combo generation
    final config = WorkoutConfiguration.addToArsenal(
      targetMoveCode: move.code,
      allowedMoveCodes: allowedMoveCodes,
      difficulty: Difficulty.beginner, // Always beginner for learning sessions
      academyLevel: targetLearningMove.level,
    );

    final result = await Navigator.push<AddToArsenalSessionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(config: config),
      ),
    );

    // If arsenal session was completed, mark it as done
    if (result != null && result.completed) {
      await controller.markAddToArsenalDone(targetLearningMove.id);
    }
  }

  void _handleStartExam(BuildContext context) async {
    // Find the LearningMove that corresponds to this Move
    final allLearningMoves = LearningPath.getAllMoves();
    LearningMove? targetLearningMove;

    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(move.code)) {
        targetLearningMove = learningMove;
        break;
      }
    }

    if (targetLearningMove == null) return;

    // Get all unlocked moves from learning state
    final controller = context.read<StoryModeController>();
    final learningState = controller.state;

    // Collect all unlocked moves
    final unlockedMoves = <Move>[];
    final moveRepository = InMemoryMoveRepository();

    for (final learningMove in allLearningMoves) {
      final progress = learningState.getProgressForMove(learningMove.id);
      if (progress != null && progress.isUnlocked) {
        // Add all moves from this learning move
        for (final moveCode in learningMove.moveCodes) {
          final unlockedMove = moveRepository.getMoveByCode(moveCode);
          if (unlockedMove != null) {
            unlockedMoves.add(unlockedMove);
          }
        }
      }
    }

    // Launch Exam screen
    final result = await Navigator.push<ExamSessionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => AcademyExamScreen(
          targetMove: move,
          unlockedMoves: unlockedMoves,
          academyLevel: targetLearningMove?.level ?? 1,
        ),
      ),
    );

    // If exam was passed, mark it and unlock the move
    if (result != null && result.passed && targetLearningMove != null) {
      await controller.markExamPassed(targetLearningMove.id);

      // Sync training preferences to auto-include the newly unlocked move
      final trainingController = Provider.of<TrainingPreferencesController>(
        context,
        listen: false,
      );
      await trainingController.syncWithLearningState(controller.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller for state changes
    final controller = context.watch<StoryModeController>();
    final learningState = controller.state;
    final currentMove = learningState.currentMove;
    final unlockState = MoveLockStatusResolver.getUnlockState(
      move.code,
      learningState,
      currentMove,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unlock status banner
                    _buildUnlockStatusBanner(context, unlockState, currentMove),

                    // Visual placeholder area
                    _buildVisualPlaceholder(context),

                    // Move summary section
                    _buildMoveSummary(context),

                    // Description section
                    if (move.description != null) ...[
                      _buildDescription(context),
                    ],

                    // Tips section
                    if (move.tips != null && move.tips!.isNotEmpty) ...[
                      _buildTips(context),
                    ],

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
                color: Colors.white.withOpacity(0.1),
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
              'MOVE DETAILS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),

          // Code badge
          _buildCodeBadge(context),
        ],
      ),
    );
  }

  Widget _buildCodeBadge(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          move.code,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockStatusBanner(BuildContext context, MoveUnlockState unlockState, LearningMove? currentMove) {
    switch (unlockState) {
      case MoveUnlockState.readyToUnlockDrillPending:
        // Show START DRILL button
        return Container(
          margin: const EdgeInsets.all(20),
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
                color: Colors.purple.shade600.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleStartDrill(context),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START DRILL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Learn this move with guided practice',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case MoveUnlockState.readyToUnlockArsenalPending:
        // Show ADD TO ARSENAL button
        return Container(
          margin: const EdgeInsets.all(20),
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
                color: Colors.purple.shade600.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleAddToArsenal(context),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADD TO ARSENAL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Practice with unlocked moves',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case MoveUnlockState.readyToUnlockExamPending:
        // Show START EXAM button
        return Container(
          margin: const EdgeInsets.all(20),
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
                color: Colors.purple.shade600.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleStartExam(context),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START EXAM',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Prove your mastery to unlock',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case MoveUnlockState.unlocked:
        // Show unlocked label
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade400.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.shade400.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );

      case MoveUnlockState.locked:
        // Show locked label with next move to unlock
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LOCKED',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (currentMove != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Before unlocking this move, first unlock',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Navigate to the current move's detail page
                    final repository = InMemoryMoveRepository();
                    final nextMoveCode = currentMove.moveCodes.first;
                    final nextMove = repository.getMoveByCode(nextMoveCode);
                    if (nextMove != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoveDetailScreen(move: nextMove),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    currentMove.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.purple.shade400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _buildVisualPlaceholder(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Animation coming soon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Move name
          Text(
            move.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),

          // Category and discipline chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(context),
              _buildDisciplineChip(context),
            ],
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
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
            size: 16,
            color: categoryColor,
          ),
          const SizedBox(width: 6),
          Text(
            move.category.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: categoryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_martial_arts,
            size: 16,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            move.discipline.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'DESCRIPTION',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            move.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white.withOpacity(0.85),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'COACHING TIPS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...move.tips!.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Colors.white.withOpacity(0.85),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
