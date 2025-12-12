import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/controllers/training_preferences_controller.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/services/move_lock_status_resolver.dart';
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/data/boxing_moves_data.dart';

/// Screen for selecting which unlocked moves to include in Training Sessions.
///
/// Shows all moves in Academy order with toggle controls:
/// - UNLOCKED moves: GREEN toggle (included) / GRAY toggle (excluded)
/// - LOCKED moves: Darker gray + lock icon, disabled toggle
///
/// This is a selection-only screen - no navigation to Move Detail Page.
class IncludedMovesScreen extends StatelessWidget {
  const IncludedMovesScreen({super.key});

  // Included Moves theme colors (blue)
  static const _includedMovesPrimary = Color(0xFF1976D2); // Blue 700
  static const _includedMovesSecondary = Color(0xFF42A5F5); // Blue 400

  // Academy theme colors (purple)
  static const _academyPrimary = Color(0xFF9C27B0); // Purple 500
  static const _academySecondary = Color(0xFFBA68C8); // Purple 300

  // Static overlay entry to prevent stacking
  static OverlayEntry? _currentOverlay;

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
                  _buildSectionHeader(context, 'Punches', punches.length),
                  ...punches.map((move) {
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
                  }),
                  const SizedBox(height: 16),

                  // Defense section
                  _buildSectionHeader(context, 'Defense', defense.length),
                  ...defense.map((move) {
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
                  }),
                  const SizedBox(height: 16),

                  // Footwork section
                  _buildSectionHeader(context, 'Footwork', footwork.length),
                  ...footwork.map((move) {
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
                  }),
                  const SizedBox(height: 16),

                  // Deception section
                  _buildSectionHeader(context, 'Deception', deception.length),
                  ...deception.map((move) {
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
                  }),
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
        _showModernError(context);
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

  /// Shows a modern, sleek error overlay when user tries to deselect all moves.
  /// Dismisses automatically after 2 seconds.
  /// Only one overlay can be shown at a time (prevents stacking).
  void _showModernError(BuildContext context) {
    // Remove existing overlay if present
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Create new overlay entry
    late OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) => _ModernErrorOverlay(
        message: 'At least one move must be included',
        onDismiss: () {
          overlay.remove();
          _currentOverlay = null;
        },
      ),
    );

    // Store reference and insert
    _currentOverlay = overlay;
    Overlay.of(context).insert(overlay);

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_currentOverlay == overlay) {
        overlay.remove();
        _currentOverlay = null;
      }
    });
  }
}

/// Modern, sleek error overlay widget that matches the app's design language.
/// Features smooth animations, glassmorphic design, and tap-to-dismiss.
class _ModernErrorOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ModernErrorOverlay({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_ModernErrorOverlay> createState() => _ModernErrorOverlayState();
}

class _ModernErrorOverlayState extends State<_ModernErrorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFD32F2F); // Training red

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () {
              // Dismiss on tap
              _controller.reverse().then((_) => widget.onDismiss());
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      errorColor,
                      errorColor.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: errorColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Warning icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Message text
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Close icon button
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
