import 'package:flutter/material.dart';
import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_progress_service.dart';
import 'package:fight_my_shadow/domain/learning/next_action.dart';

/// Story Mode home screen showing learning progress and next action.
///
/// Displays:
/// - Global progress bar showing unlocked moves
/// - All 18 learning moves grouped by phase (1-6)
/// - Status for each move (Locked / In Progress / Unlocked)
/// - Large CTA button reflecting the next action (Drill/Progression/Exam/Complete)
class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({super.key});

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> {
  late LearningState _learningState;

  @override
  void initState() {
    super.initState();
    // Initialize with fresh state for now
    // In future, this will load from persistence
    _learningState = LearningProgressService.initializeFreshState();
  }

  // Helper to determine move status
  MoveStatus _getMoveStatus(LearningMove move) {
    final progress = _learningState.getProgressForMove(move.id);
    if (progress == null) return MoveStatus.locked;

    if (progress.isUnlocked) {
      return MoveStatus.unlocked;
    }

    final currentMove = _learningState.currentMove;
    if (currentMove != null && currentMove.id == move.id) {
      return MoveStatus.inProgress;
    }

    return MoveStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    final allMoves = LearningPath.getAllMoves();
    final unlockedCount = _learningState.moveProgress
        .where((p) => p.isUnlocked)
        .length;
    final nextAction = LearningProgressService.computeNextAction(_learningState);

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
                    // Global progress section
                    _buildGlobalProgressSection(context, unlockedCount, 18),
                    const SizedBox(height: 24),

                    // Moves list grouped by phase
                    _buildMovesListByPhase(context, allMoves),
                    const SizedBox(height: 100), // Space for CTA button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA button (pinned)
      bottomNavigationBar: _buildBottomCTA(context, nextAction),
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

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STORY MODE',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Learning Phase',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalProgressSection(
    BuildContext context,
    int unlockedCount,
    int totalMoves,
  ) {
    final progress = unlockedCount / totalMoves;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and subtitle
              Text(
                'YOUR PROGRESS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 1.5,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock moves step by step with drills, sessions, and exams',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 20),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFF0F0F0F),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Progress text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$unlockedCount of $totalMoves moves unlocked',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovesListByPhase(
    BuildContext context,
    List<LearningMove> allMoves,
  ) {
    // Group moves by phase
    final movesByPhase = <int, List<LearningMove>>{};
    for (final move in allMoves) {
      movesByPhase.putIfAbsent(move.phase, () => []).add(move);
    }

    // Sort phases
    final sortedPhases = movesByPhase.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedPhases.map((phase) {
          final moves = movesByPhase[phase]!;
          // Sort moves by orderInPhase
          moves.sort((a, b) => a.orderInPhase.compareTo(b.orderInPhase));

          return _buildPhaseSection(context, phase, moves);
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseSection(
    BuildContext context,
    int phase,
    List<LearningMove> moves,
  ) {
    // Get phase name from first move
    final phaseName = moves.first.phaseName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PHASE $phase',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                phaseName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),

        // Moves in this phase
        ...moves.map((move) => _buildMoveRow(context, move)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMoveRow(BuildContext context, LearningMove move) {
    final status = _getMoveStatus(move);
    final isCurrentMove = status == MoveStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentMove
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentMove
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          width: isCurrentMove ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to move detail or show info
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Status icon
                _buildStatusIcon(context, status),
                const SizedBox(width: 14),

                // Move info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        move.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      if (move.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          move.description,
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
                _buildStatusBadge(context, status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MoveStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MoveStatus.unlocked:
        icon = Icons.check_circle;
        color = Colors.green.shade400;
        break;
      case MoveStatus.inProgress:
        icon = Icons.radio_button_checked;
        color = Theme.of(context).colorScheme.primary;
        break;
      case MoveStatus.locked:
        icon = Icons.lock;
        color = Colors.white.withValues(alpha: 0.3);
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildStatusBadge(BuildContext context, MoveStatus status) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case MoveStatus.unlocked:
        label = 'Done';
        bgColor = Colors.green.shade400.withValues(alpha: 0.15);
        textColor = Colors.green.shade400;
        break;
      case MoveStatus.inProgress:
        label = 'Current';
        bgColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
        textColor = Theme.of(context).colorScheme.primary;
        break;
      case MoveStatus.locked:
        label = 'Locked';
        bgColor = Colors.white.withValues(alpha: 0.05);
        textColor = Colors.white.withValues(alpha: 0.5);
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

  Widget _buildBottomCTA(BuildContext context, NextAction nextAction) {
    String buttonLabel;
    String? subtitleText;
    IconData buttonIcon;

    switch (nextAction.type) {
      case NextActionType.drill:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        buttonLabel = move != null
            ? 'Start Drill: ${move.displayName}'
            : 'Start Drill';
        buttonIcon = Icons.school;
        subtitleText = 'Learn the move with guided practice';
        break;

      case NextActionType.progression:
        final move = nextAction.moveId != null
            ? LearningPath.getMoveById(nextAction.moveId!)
            : null;
        final progress = nextAction.moveId != null
            ? _learningState.getProgressForMove(nextAction.moveId!)
            : null;
        buttonLabel = 'Do Progression Session';
        buttonIcon = Icons.fitness_center;

        if (move != null && progress != null) {
          final required = LearningProgressService.getRequiredProgressionSessions(
            move.phase,
          );
          subtitleText =
              'Session ${progress.progressionSessionsDone + 1} of $required';
        }
        break;

      case NextActionType.exam:
        buttonLabel = 'Take Exam';
        buttonIcon = Icons.assignment_turned_in;
        subtitleText = 'Test your mastery of the move';
        break;

      case NextActionType.learningComplete:
        buttonLabel = 'Continue to Training Mode';
        buttonIcon = Icons.play_arrow_rounded;
        subtitleText = 'All moves unlocked! You\'ve completed the Learning Phase.';
        break;
    }

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
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleCTAPressed(nextAction),
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
          ],
        ),
      ),
    );
  }

  void _handleCTAPressed(NextAction nextAction) {
    switch (nextAction.type) {
      case NextActionType.drill:
        // TODO: Navigate to drill session
        _showPlaceholder(context, 'Drill', 'Drill session coming soon!');
        break;

      case NextActionType.progression:
        // TODO: Navigate to progression session
        _showPlaceholder(context, 'Progression', 'Progression session coming soon!');
        break;

      case NextActionType.exam:
        // TODO: Navigate to exam screen
        _showPlaceholder(context, 'Exam', 'Exam coming soon!');
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status of a learning move for UI display.
enum MoveStatus {
  locked,
  inProgress,
  unlocked,
}
