import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_progress_service.dart';
import 'package:fight_my_shadow/domain/learning/next_action.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/screens/move_detail_screen.dart';
import 'package:fight_my_shadow/widgets/collapsible_section.dart';

// Academy color theme (purple instead of orange)
const _academyPrimary = Color(0xFF9C27B0);  // Purple 500
const _academySecondary = Color(0xFFBA68C8); // Purple 300

/// Academy home screen showing learning progress and next action.
///
/// Displays:
/// - Global progress bar showing unlocked moves
/// - All learning moves grouped by level (1-12), using actual Move objects from repository
/// - Status for each move (Locked / Ready to Unlock / Unlocked) using same logic as Library
/// - Large CTA button reflecting the next action (Drill/Progression/Exam/Complete)
class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({super.key});

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> {
  late final AccordionController _accordionController;

  @override
  void initState() {
    super.initState();
    _accordionController = AccordionController();
  }

  @override
  void dispose() {
    _accordionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get global state from controller
    final controller = context.watch<StoryModeController>();
    final learningState = controller.state;
    final repository = InMemoryMoveRepository();

    final allLearningMoves = LearningPath.getAllMoves();
    final nextAction = LearningProgressService.computeNextAction(learningState);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Celebratory hero banner showing highest completed level
                    _buildCompletedLevelHero(context, allLearningMoves, learningState),
                    const SizedBox(height: 16),

                    // Moves list grouped by level
                    _buildMovesListByLevel(context, allLearningMoves, repository, learningState, _accordionController),
                    const SizedBox(height: 100), // Space for CTA button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA button (pinned)
      bottomNavigationBar: _buildBottomCTA(context, nextAction, learningState),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF0A0A0A).withValues(alpha: 0.0),
          ],
        ),
      ),
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
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACADEMY',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'My Progress Path',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),

          // Academy logo icon (purple)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _academyPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _academyPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.school,
              color: _academyPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a celebratory hero banner showing the highest completed level.
  ///
  /// UI-only feature: displays "LEVEL X - Name" where X is the highest level
  /// with all moves unlocked. If no levels are complete, shows "LEVEL 0 - The First Bell"
  /// as a purely visual placeholder (not a real curriculum level).
  Widget _buildCompletedLevelHero(
    BuildContext context,
    List<LearningMove> allLearningMoves,
    LearningState learningState,
  ) {
    // Calculate highest completed level
    int highestCompletedLevel = 0;

    // Group moves by level to check completion
    final movesByLevel = <int, List<LearningMove>>{};
    for (final learningMove in allLearningMoves) {
      movesByLevel.putIfAbsent(learningMove.level, () => []).add(learningMove);
    }

    // Check each level from 1 to max to find highest completed
    for (int level = 1; level <= LearningPath.totalLevels; level++) {
      final movesInLevel = movesByLevel[level] ?? [];
      if (movesInLevel.isEmpty) continue;

      // Check if ALL moves in this level are unlocked
      final allUnlocked = movesInLevel.every((lm) {
        final progress = learningState.getProgressForMove(lm.id);
        return progress != null && progress.isUnlocked;
      });

      if (allUnlocked) {
        highestCompletedLevel = level;
      } else {
        // Stop at first incomplete level
        break;
      }
    }

    // Determine display text
    final String levelText;
    final String levelName;

    if (highestCompletedLevel == 0) {
      levelText = 'LEVEL 0';
      levelName = 'The First Bell';
    } else {
      levelText = 'LEVEL $highestCompletedLevel';
      // Get level name from first move in that level
      final firstMoveInLevel = movesByLevel[highestCompletedLevel]?.first;
      levelName = firstMoveInLevel?.levelName ?? 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _academyPrimary,
            _academySecondary,
            _academyPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _academyPrimary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative sparkle elements
          Positioned(
            top: 12,
            right: 20,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.3),
              size: 40,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 24,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.2),
              size: 28,
            ),
          ),
          Positioned(
            top: 40,
            left: 60,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.15),
              size: 20,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level number
                Text(
                  levelText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 8),
                // Level name
                Text(
                  levelName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 12),
                // Subtle subtitle
                Text(
                  highestCompletedLevel == 0
                      ? 'Begin your journey'
                      : 'Keep pushing forward',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovesListByLevel(
    BuildContext context,
    List<LearningMove> allLearningMoves,
    MoveRepository repository,
    LearningState learningState,
    AccordionController accordionController,
  ) {
    // Group learning moves by level
    final movesByLevel = <int, List<LearningMove>>{};
    for (final learningMove in allLearningMoves) {
      movesByLevel.putIfAbsent(learningMove.level, () => []).add(learningMove);
    }

    // Sort levels
    final sortedLevels = movesByLevel.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedLevels.map((level) {
          final learningMoves = movesByLevel[level]!;
          // Sort moves by orderInLevel
          learningMoves.sort((a, b) => a.orderInLevel.compareTo(b.orderInLevel));

          return _buildLevelSection(context, level, learningMoves, repository, learningState, accordionController);
        }).toList(),
      ),
    );
  }

  Widget _buildLevelSection(
    BuildContext context,
    int level,
    List<LearningMove> learningMoves,
    MoveRepository repository,
    LearningState learningState,
    AccordionController accordionController,
  ) {
    // Get level name from first move
    final levelName = learningMoves.first.levelName;

    // Calculate progress within this level
    final unlockedInLevel = learningMoves.where((lm) {
      final progress = learningState.getProgressForMove(lm.id);
      return progress != null && progress.isUnlocked;
    }).length;

    // Determine if this level should be initially expanded
    // Only expand the level that contains the current move
    final currentMove = learningState.currentMove;
    final isCurrentLevel = currentMove != null && currentMove.level == level;

    // Build title with "In Progress" indicator if this is the current level
    final titleText = 'LEVEL $level — $levelName';
    final subtitle = isCurrentLevel
        ? '🔥 In Progress · $unlockedInLevel/${learningMoves.length} unlocked'
        : '$unlockedInLevel/${learningMoves.length} unlocked';

    return CollapsibleSection(
      title: titleText,
      subtitle: subtitle,
      accentColor: _academyPrimary,
      initiallyExpanded: isCurrentLevel,
      accordionController: accordionController,
      sectionId: level, // Use level number as unique ID
      children: learningMoves.map((learningMove) =>
        _buildMoveRow(context, learningMove, repository, learningState)).toList(),
    );
  }

  Widget _buildMoveRow(
    BuildContext context,
    LearningMove learningMove,
    MoveRepository repository,
    LearningState learningState,
  ) {
    // Get the actual Move object(s) for this learning move
    final actualMoves = LearningPath.getActualMovesForLearningMove(learningMove, repository);

    // For lock state, use the first move code (primary move)
    final primaryMoveCode = learningMove.moveCodes.first;
    final currentMove = learningState.currentMove;
    final unlockState = MoveLockStatusResolver.getUnlockState(
      primaryMoveCode,
      learningState,
      currentMove,
    );

    final isReadyToUnlock = unlockState == MoveUnlockState.readyToUnlockDrillPending ||
                             unlockState == MoveUnlockState.readyToUnlockArsenalPending;

    // Get the display name from actual Move or fallback to learning move name
    final displayName = actualMoves.isNotEmpty
        ? actualMoves.first.name
        : learningMove.displayName;

    // Get description from learning move (it provides better educational context)
    final description = learningMove.description;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isReadyToUnlock
            ? _academyPrimary.withValues(alpha: 0.1)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReadyToUnlock
              ? _academyPrimary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.12),
          width: isReadyToUnlock ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to move detail page
            if (actualMoves.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoveDetailScreen(move: actualMoves.first),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Status icon
                _buildStatusIcon(context, unlockState),
                const SizedBox(width: 14),

                // Move info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status badge
                _buildStatusBadge(context, unlockState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MoveUnlockState unlockState) {
    IconData icon;
    Color color;

    switch (unlockState) {
      case MoveUnlockState.unlocked:
        icon = Icons.check_circle;
        color = Colors.green.shade400;
        break;
      case MoveUnlockState.readyToUnlockDrillPending:
      case MoveUnlockState.readyToUnlockArsenalPending:
      case MoveUnlockState.readyToUnlockExamPending:
        icon = Icons.radio_button_checked;
        color = _academyPrimary;
        break;
      case MoveUnlockState.locked:
        icon = Icons.lock;
        color = Colors.white.withValues(alpha: 0.5);
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildStatusBadge(BuildContext context, MoveUnlockState unlockState) {
    String label;
    Color bgColor;
    Color textColor;

    switch (unlockState) {
      case MoveUnlockState.unlocked:
        label = 'Done';
        bgColor = Colors.green.shade400.withValues(alpha: 0.15);
        textColor = Colors.green.shade400;
        break;
      case MoveUnlockState.readyToUnlockDrillPending:
      case MoveUnlockState.readyToUnlockArsenalPending:
      case MoveUnlockState.readyToUnlockExamPending:
        label = 'Ready';
        bgColor = _academyPrimary.withValues(alpha: 0.15);
        textColor = _academyPrimary;
        break;
      case MoveUnlockState.locked:
        label = 'Locked';
        bgColor = Colors.white.withValues(alpha: 0.1);
        textColor = Colors.white.withValues(alpha: 0.65);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context, NextAction nextAction, LearningState learningState) {
    String buttonLabel;
    String? subtitleText;
    IconData buttonIcon;

    switch (nextAction.type) {
      case NextActionType.drill:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        buttonLabel = move != null
            ? '${move.displayName}: Drill'
            : 'Next';
        buttonIcon = Icons.arrow_forward;
        break;

      case NextActionType.addToArsenal:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        buttonLabel = move != null
            ? '${move.displayName}: Add to arsenal'
            : 'Add to arsenal';
        buttonIcon = Icons.add_circle;
        subtitleText = 'Practice this move';
        break;

      case NextActionType.progression:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        final progress = nextAction.moveId != null
            ? learningState.getProgressForMove(nextAction.moveId!)
            : null;
        buttonLabel = move != null
            ? '${move.displayName}: Progression'
            : 'Do Progression Session';
        buttonIcon = Icons.fitness_center;

        if (move != null && progress != null) {
          final required = LearningProgressService.getRequiredProgressionSessions(
            move.level,
          );
          subtitleText =
              'Session ${progress.progressionSessionsDone + 1} of $required';
        }
        break;

      case NextActionType.exam:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        buttonLabel = move != null
            ? '${move.displayName}: Exam'
            : 'Exam';
        buttonIcon = Icons.assignment_turned_in;
        subtitleText = 'Prove your mastery';
        break;

      case NextActionType.learningComplete:
        buttonLabel = 'Continue to Training Mode';
        buttonIcon = Icons.play_arrow_rounded;
        subtitleText = 'All moves unlocked! You\'ve completed all levels.';
        break;
    }

    // Calculate completion progress
    final completedCount = learningState.moveProgress
        .where((p) => p.isUnlocked)
        .length;
    final totalMoves = LearningPath.totalMoves;
    final completionPercentage = ((completedCount / totalMoves) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtitle text (if any)
            if (subtitleText != null) ...[
              Text(
                subtitleText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // CTA Button
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _academyPrimary,
                    _academySecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _academyPrimary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleCTAPressed(context, nextAction),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        buttonIcon,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          buttonLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                fontSize: 15,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Progress row
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount out of $totalMoves moves completed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
                Text(
                  '$completionPercentage%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _academyPrimary.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completedCount / totalMoves,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _academyPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCTAPressed(BuildContext context, NextAction nextAction) {
    switch (nextAction.type) {
      case NextActionType.drill:
      case NextActionType.addToArsenal:
      case NextActionType.exam:
        // Navigate to Move Detail Page for the current move
        if (nextAction.moveId != null) {
          final learningMove = LearningPath.getMoveById(nextAction.moveId!);
          if (learningMove != null) {
            final repository = InMemoryMoveRepository();
            final moveCode = learningMove.moveCodes.first;
            final move = repository.getMoveByCode(moveCode);
            if (move != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoveDetailScreen(move: move),
                ),
              );
            }
          }
        }
        break;

      case NextActionType.progression:
        // TODO: Navigate to progression session
        _showPlaceholder(context, 'Progression', 'Progression session coming soon!');
        break;

      case NextActionType.learningComplete:
        // TODO: Navigate to training mode setup
        _showPlaceholder(context, 'Training Mode', 'Navigate to workout setup!');
        break;
    }
  }

  void _showPlaceholder(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: const TextStyle(
                color: _academyPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
