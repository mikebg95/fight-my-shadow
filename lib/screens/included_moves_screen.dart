import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/controllers/training_preferences_controller.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/data/boxing_moves_data.dart';
import 'package:fight_my_shadow/widgets/collapsible_section.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/widgets/app_toast.dart';

/// Screen for selecting which unlocked moves to include in Training Sessions.
///
/// Shows all moves in Academy order with toggle controls:
/// - UNLOCKED moves: GREEN toggle (included) / GRAY toggle (excluded)
/// - LOCKED moves: Darker gray + lock icon, disabled toggle
///
/// This is a selection-only screen - no navigation to Move Detail Page.
class IncludedMovesScreen extends StatefulWidget {
  const IncludedMovesScreen({super.key});

  @override
  State<IncludedMovesScreen> createState() => _IncludedMovesScreenState();
}

class _IncludedMovesScreenState extends State<IncludedMovesScreen> {
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

  // Included Moves theme colors (blue)
  static const _includedMovesPrimary = Color(0xFF1976D2); // Blue 700
  static const _includedMovesSecondary = Color(0xFF42A5F5); // Blue 400

  // Academy theme colors (purple)
  static const _academyPrimary = Color(0xFF9C27B0); // Purple 500
  static const _academySecondary = Color(0xFFBA68C8); // Purple 300

  /// Calculates how many moves in a category are currently included in training.
  /// Only counts unlocked moves that are toggled ON.
  int _getIncludedCount(
    List<Move> moves,
    TrainingPreferencesController trainingController,
    LearningState learningState,
    LearningMove? currentMove,
  ) {
    return moves.where((move) {
      final unlockState = MoveLockStatusResolver.getUnlockState(
        move.code,
        learningState,
        currentMove,
      );
      final isUnlocked = unlockState == MoveUnlockState.unlocked;
      final isIncluded = trainingController.isIncluded(move.code);
      return isUnlocked && isIncluded;
    }).length;
  }

  /// Formats the included count label for section headers.
  String _formatIncludedLabel(int count) {
    if (count == 0) return '0 moves included';
    if (count == 1) return '1 move included';
    return '$count moves included';
  }

  @override
  Widget build(BuildContext context) {
    final trainingController = Provider.of<TrainingPreferencesController>(context);
    final storyController = Provider.of<StoryModeController>(context);

    final learningState = storyController.state;
    final currentMove = learningState.currentMove;

    // Get all moves in Academy order
    final allMovesOrdered = getMovesInAcademyOrder();

    // Group by category while preserving Academy order within each category
    final punches = allMovesOrdered.where((m) => m.category == MoveCategory.punch).toList();
    final defense = allMovesOrdered.where((m) => m.category == MoveCategory.defense).toList();
    final footwork = allMovesOrdered.where((m) => m.category == MoveCategory.footwork).toList();
    final deception = allMovesOrdered.where((m) => m.category == MoveCategory.deception).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, trainingController),

            // Move list with category sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // Punches section
                  CollapsibleSection(
                    title: 'Punches',
                    subtitle: _formatIncludedLabel(_getIncludedCount(punches, trainingController, learningState, currentMove)),
                    leadingIcon: Icons.sports_martial_arts,
                    accentColor: _includedMovesPrimary,
                    initiallyExpanded: false,
                    accordionController: _accordionController,
                    sectionId: 'punches',
                    children: punches.map((move) {
                      final unlockState = MoveLockStatusResolver.getUnlockState(
                        move.code,
                        learningState,
                        currentMove,
                      );
                      final isUnlocked = unlockState == MoveUnlockState.unlocked;
                      final isIncluded = trainingController.isIncluded(move.code);

                      return _buildMoveRow(
                        context,
                        trainingController: trainingController,
                        move: move,
                        isUnlocked: isUnlocked,
                        isIncluded: isIncluded,
                        moveCode: move.code,
                      );
                    }).toList(),
                  ),

                  // Defense section
                  CollapsibleSection(
                    title: 'Defense',
                    subtitle: _formatIncludedLabel(_getIncludedCount(defense, trainingController, learningState, currentMove)),
                    leadingIcon: Icons.shield,
                    accentColor: _includedMovesPrimary,
                    initiallyExpanded: false,
                    accordionController: _accordionController,
                    sectionId: 'defense',
                    children: defense.map((move) {
                      final unlockState = MoveLockStatusResolver.getUnlockState(
                        move.code,
                        learningState,
                        currentMove,
                      );
                      final isUnlocked = unlockState == MoveUnlockState.unlocked;
                      final isIncluded = trainingController.isIncluded(move.code);

                      return _buildMoveRow(
                        context,
                        trainingController: trainingController,
                        move: move,
                        isUnlocked: isUnlocked,
                        isIncluded: isIncluded,
                        moveCode: move.code,
                      );
                    }).toList(),
                  ),

                  // Footwork section
                  CollapsibleSection(
                    title: 'Footwork',
                    subtitle: _formatIncludedLabel(_getIncludedCount(footwork, trainingController, learningState, currentMove)),
                    leadingIcon: Icons.directions_walk,
                    accentColor: _includedMovesPrimary,
                    initiallyExpanded: false,
                    accordionController: _accordionController,
                    sectionId: 'footwork',
                    children: footwork.map((move) {
                      final unlockState = MoveLockStatusResolver.getUnlockState(
                        move.code,
                        learningState,
                        currentMove,
                      );
                      final isUnlocked = unlockState == MoveUnlockState.unlocked;
                      final isIncluded = trainingController.isIncluded(move.code);

                      return _buildMoveRow(
                        context,
                        trainingController: trainingController,
                        move: move,
                        isUnlocked: isUnlocked,
                        isIncluded: isIncluded,
                        moveCode: move.code,
                      );
                    }).toList(),
                  ),

                  // Deception section
                  if (deception.isNotEmpty)
                    CollapsibleSection(
                      title: 'Deception',
                      subtitle: _formatIncludedLabel(_getIncludedCount(deception, trainingController, learningState, currentMove)),
                      leadingIcon: Icons.psychology,
                      accentColor: _includedMovesPrimary,
                      initiallyExpanded: false,
                      accordionController: _accordionController,
                      sectionId: 'deception',
                      children: deception.map((move) {
                        final unlockState = MoveLockStatusResolver.getUnlockState(
                          move.code,
                          learningState,
                          currentMove,
                        );
                        final isUnlocked = unlockState == MoveUnlockState.unlocked;
                        final isIncluded = trainingController.isIncluded(move.code);

                        return _buildMoveRow(
                          context,
                          trainingController: trainingController,
                          move: move,
                          isUnlocked: isUnlocked,
                          isIncluded: isIncluded,
                          moveCode: move.code,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Academy link at bottom
            _buildAcademyLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TrainingPreferencesController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _includedMovesPrimary,
            _includedMovesSecondary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _includedMovesPrimary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INCLUDED MOVES',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select moves for Training Sessions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),

              // Fitness icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Included count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${controller.includedCount} moves included',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
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
                  color: _includedMovesPrimary,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _includedMovesPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _includedMovesPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveRow(
    BuildContext context, {
    required TrainingPreferencesController trainingController,
    required Move move,
    required bool isUnlocked,
    required bool isIncluded,
    required String moveCode,
  }) {
    // Handler for toggle with validation
    void handleToggle() {
      // If this is included and it's the last one, prevent deselection
      if (isIncluded && trainingController.includedCount == 1) {
        AppToast.error(context, 'At least one move must be included');
        return;
      }

      // Otherwise, toggle normally
      trainingController.toggleMove(moveCode);
    }
    // Color scheme based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color codeColor;
    double opacity;

    if (isUnlocked && isIncluded) {
      // GREEN - included
      backgroundColor = const Color(0xFF1A1A1A);
      borderColor = Colors.green.withValues(alpha: 0.3);
      textColor = Colors.white;
      codeColor = Colors.green;
      opacity = 1.0;
    } else if (isUnlocked && !isIncluded) {
      // GRAY - excluded but available
      backgroundColor = const Color(0xFF1A1A1A);
      borderColor = Colors.white.withValues(alpha: 0.1);
      textColor = Colors.white.withValues(alpha: 0.6);
      codeColor = Colors.white.withValues(alpha: 0.4);
      opacity = 0.75;
    } else {
      // LOCKED - darker gray
      backgroundColor = const Color(0xFF141414);
      borderColor = Colors.white.withValues(alpha: 0.05);
      textColor = Colors.white.withValues(alpha: 0.4);
      codeColor = Colors.white.withValues(alpha: 0.3);
      opacity = 0.6;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // Move code badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: codeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: codeColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    move.code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: codeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Move info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      move.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      move.category.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withValues(alpha: 0.6),
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),

              // Toggle or lock icon
              if (isUnlocked)
                _buildToggleSwitch(isIncluded, handleToggle)
              else
                _buildLockIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isIncluded, VoidCallback? onToggle) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: isIncluded
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isIncluded
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: isIncluded ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isIncluded ? Colors.green : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.lock,
        color: Colors.white.withValues(alpha: 0.3),
        size: 20,
      ),
    );
  }

  Widget _buildAcademyLink(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to Academy screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LearningProgressScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _academyPrimary,
                _academySecondary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _academyPrimary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _academyPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'To unlock more moves, visit the Academy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
