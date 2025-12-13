import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/controllers/training_preferences_controller.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/screens/academy_exam_screen.dart';
import 'package:fight_my_shadow/screens/move_unlocked_celebration_screen.dart';
import 'package:fight_my_shadow/screens/level_complete_celebration_screen.dart';
import 'package:fight_my_shadow/utils/responsive.dart';

/// Screen that displays detailed information about a single move.
///
/// Shows the move's name, code, category, discipline, description, tips,
/// and a placeholder area for future images/animations.
/// Also shows an UNLOCK button for moves that are ready to unlock.
class MoveDetailScreen extends StatelessWidget {
  final Move move;

  const MoveDetailScreen({super.key, required this.move});

  /// Checks if all moves in a given level are unlocked.
  /// Returns true if the level is complete (all moves unlocked).
  bool _isLevelComplete(int level, LearningState learningState) {
    final movesInLevel = LearningPath.getMovesByLevel(level);
    return movesInLevel.every((lm) {
      final progress = learningState.getProgressForMove(lm.id);
      return progress != null && progress.isUnlocked;
    });
  }

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

      // Special case: Jab (first move) unlocks immediately after Add-to-Arsenal
      // For all other moves, they need to pass the exam
      if (targetLearningMove.id == 1) {
        // Unlock the move
        await controller.markExamPassed(targetLearningMove.id);

        // Get the level of the just-unlocked move (for level completion check)
        final unlockedMoveLevel = targetLearningMove.level;
        final unlockedMoveLevelName = targetLearningMove.levelName;

        // Sync training preferences to include Jab
        if (context.mounted) {
          final trainingController = Provider.of<TrainingPreferencesController>(
            context,
            listen: false,
          );
          await trainingController.syncWithLearningState(controller.state);

          // Show celebration screen
          if (context.mounted) {
            // Find the next move for "Next up" text
            final nextMove = allLearningMoves.firstWhere(
              (m) => m.id == 2,
              orElse: () => allLearningMoves[1],
            );

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoveUnlockedCelebrationScreen(
                  moveName: targetLearningMove!.displayName,
                  moveCode: move.code,
                  nextMoveName: nextMove.displayName,
                ),
                settings: const RouteSettings(name: '/celebration'),
              ),
            );

            // After move celebration, check if the LEVEL is now complete
            if (context.mounted) {
              final updatedState = context.read<StoryModeController>().state;

              if (_isLevelComplete(unlockedMoveLevel, updatedState)) {
                // Show the LEVEL COMPLETE celebration!
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelCompleteCelebrationScreen(
                      levelNumber: unlockedMoveLevel,
                      levelName: unlockedMoveLevelName,
                    ),
                    settings: const RouteSettings(name: '/level-celebration'),
                  ),
                );
                // After level celebration, navigate to Academy
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) {
                    return route.isFirst || route.settings.name == '/academy';
                  });
                }
              } else {
                // No level complete, pop back to Academy
                // This preserves the stack: BoxingHome stays underneath Academy
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) {
                    // Pop until we reach Academy (LearningProgressScreen) or root
                    return route.isFirst || route.settings.name == '/academy';
                  });
                }
              }
            }
          }
        }
      }
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

      // Get the level of the just-unlocked move (for level completion check)
      final unlockedMoveLevel = targetLearningMove.level;
      final unlockedMoveLevelName = targetLearningMove.levelName;

      // Sync training preferences to auto-include the newly unlocked move
      if (context.mounted) {
        final trainingController = Provider.of<TrainingPreferencesController>(
          context,
          listen: false,
        );
        await trainingController.syncWithLearningState(controller.state);

        // Show move unlock celebration screen
        if (context.mounted) {
          // Find the next move for "Next up" text
          String? nextMoveName;
          final nextMoveIndex = allLearningMoves.indexWhere(
            (m) => m.id == targetLearningMove!.id + 1,
          );
          if (nextMoveIndex != -1) {
            nextMoveName = allLearningMoves[nextMoveIndex].displayName;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoveUnlockedCelebrationScreen(
                moveName: targetLearningMove!.displayName,
                moveCode: move.code,
                nextMoveName: nextMoveName,
              ),
              settings: const RouteSettings(name: '/celebration'),
            ),
          );

          // After move celebration, check if the LEVEL is now complete
          // (all moves in that level are unlocked)
          if (context.mounted) {
            // Re-read the learning state after the celebration
            final updatedState = context.read<StoryModeController>().state;

            if (_isLevelComplete(unlockedMoveLevel, updatedState)) {
              // Show the LEVEL COMPLETE celebration!
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LevelCompleteCelebrationScreen(
                    levelNumber: unlockedMoveLevel,
                    levelName: unlockedMoveLevelName,
                  ),
                  settings: const RouteSettings(name: '/level-celebration'),
                ),
              );
              // After level celebration, navigate to Academy
              if (context.mounted) {
                Navigator.of(context).popUntil((route) {
                  return route.isFirst || route.settings.name == '/academy';
                });
              }
            } else {
              // No level complete, pop back to Academy
              // This preserves the stack: BoxingHome stays underneath Academy
              if (context.mounted) {
                Navigator.of(context).popUntil((route) {
                  // Pop until we reach Academy (LearningProgressScreen) or root
                  return route.isFirst || route.settings.name == '/academy';
                });
              }
            }
          }
        }
      }
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

          // Title (move name)
          Expanded(
            child: Text(
              move.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                    fontSize: Responsive.rf(context, isSmall ? 18 : 20),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Code badge
          _buildCodeBadge(context),
        ],
      ),
    );
  }

  Widget _buildCodeBadge(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final badgeSize = Responsive.rs(context, isSmall ? 48 : 56);

    return Container(
      width: badgeSize,
      height: badgeSize,
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
          style: TextStyle(
            fontSize: Responsive.rf(context, isSmall ? 20 : 24),
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockStatusBanner(BuildContext context, MoveUnlockState unlockState, LearningMove? currentMove) {
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    switch (unlockState) {
      case MoveUnlockState.readyToUnlockDrillPending:
        // Show START DRILL button
        return Container(
          margin: EdgeInsets.all(padding),
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
              child: Padding(
                padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 28 : 32),
                    ),
                    SizedBox(width: Responsive.rs(context, isSmall ? 12 : 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START DRILL',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 16 : 18),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn this move with guided practice',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 12 : 13),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 20 : 24),
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
          margin: EdgeInsets.all(padding),
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
              child: Padding(
                padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 28 : 32),
                    ),
                    SizedBox(width: Responsive.rs(context, isSmall ? 12 : 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADD TO ARSENAL',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 16 : 18),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Practice with unlocked moves',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 12 : 13),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 20 : 24),
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
          margin: EdgeInsets.all(padding),
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
              child: Padding(
                padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 28 : 32),
                    ),
                    SizedBox(width: Responsive.rs(context, isSmall ? 12 : 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START EXAM',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 16 : 18),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prove your mastery to unlock',
                            style: TextStyle(
                              fontSize: Responsive.rf(context, isSmall ? 12 : 13),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: Responsive.iconSize(context, isSmall ? 20 : 24),
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
          margin: EdgeInsets.all(padding),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.rs(context, isSmall ? 16 : 20),
            vertical: Responsive.rs(context, isSmall ? 12 : 16),
          ),
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
                size: Responsive.iconSize(context, isSmall ? 24 : 28),
              ),
              SizedBox(width: Responsive.rs(context, 12)),
              Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: Responsive.rf(context, isSmall ? 14 : 16),
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
          margin: EdgeInsets.all(padding),
          padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
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
                    size: Responsive.iconSize(context, isSmall ? 20 : 24),
                  ),
                  SizedBox(width: Responsive.rs(context, 12)),
                  Text(
                    'LOCKED',
                    style: TextStyle(
                      fontSize: Responsive.rf(context, isSmall ? 12 : 14),
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (currentMove != null) ...[
                SizedBox(height: Responsive.rs(context, 12)),
                Text(
                  'Before unlocking this move, first unlock',
                  style: TextStyle(
                    fontSize: Responsive.rf(context, isSmall ? 12 : 13),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: Responsive.rs(context, 8)),
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
                      fontSize: Responsive.rf(context, isSmall ? 13 : 15),
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
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 0, padding, Responsive.rs(context, 20)),
      height: Responsive.rs(context, isSmall ? 160 : 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: Responsive.iconSize(context, isSmall ? 48 : 64),
              color: Colors.white.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.rs(context, 12)),
            Text(
              'Animation coming soon',
              style: TextStyle(
                fontSize: Responsive.rf(context, isSmall ? 12 : 14),
                color: Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveSummary(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 0, padding, Responsive.rs(context, 24)),
      padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
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
                  fontSize: Responsive.rf(context, isSmall ? 20 : 24),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.rs(context, 16)),

          // Category and discipline chips
          Wrap(
            spacing: Responsive.rs(context, 8),
            runSpacing: Responsive.rs(context, 8),
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
    final isSmall = Responsive.isSmallPhone(context);
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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.rs(context, isSmall ? 10 : 12),
        vertical: Responsive.rs(context, 6),
      ),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: Responsive.iconSize(context, isSmall ? 14 : 16),
            color: categoryColor,
          ),
          SizedBox(width: Responsive.rs(context, 6)),
          Text(
            move.category.label,
            style: TextStyle(
              fontSize: Responsive.rf(context, isSmall ? 11 : 13),
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
    final isSmall = Responsive.isSmallPhone(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.rs(context, isSmall ? 10 : 12),
        vertical: Responsive.rs(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_martial_arts,
            size: Responsive.iconSize(context, isSmall ? 14 : 16),
            color: Colors.white.withValues(alpha: 0.6),
          ),
          SizedBox(width: Responsive.rs(context, 6)),
          Text(
            move.discipline.label,
            style: TextStyle(
              fontSize: Responsive.rf(context, isSmall ? 11 : 13),
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 0, padding, Responsive.rs(context, 24)),
      padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
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
                size: Responsive.iconSize(context, isSmall ? 18 : 20),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: Responsive.rs(context, 8)),
              Text(
                'DESCRIPTION',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.rf(context, isSmall ? 11 : 12),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          SizedBox(height: Responsive.rs(context, 12)),
          Text(
            move.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: Responsive.rf(context, isSmall ? 14 : 16),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final padding = Responsive.horizontalPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 0, padding, Responsive.rs(context, 24)),
      padding: EdgeInsets.all(Responsive.rs(context, isSmall ? 16 : 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
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
                size: Responsive.iconSize(context, isSmall ? 18 : 20),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: Responsive.rs(context, 8)),
              Text(
                'COACHING TIPS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.rf(context, isSmall ? 11 : 12),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          SizedBox(height: Responsive.rs(context, 16)),
          ...move.tips!.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.rs(context, 12)),
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
                  SizedBox(width: Responsive.rs(context, 12)),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: Responsive.rf(context, isSmall ? 13 : 14),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
