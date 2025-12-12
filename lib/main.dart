import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fight_my_shadow/screens/library_screen.dart';
import 'package:fight_my_shadow/screens/discipline_selection_screen.dart';
import 'package:fight_my_shadow/models/training_discipline.dart';
import 'package:fight_my_shadow/domain/combos/combo.dart';
import 'package:fight_my_shadow/domain/combos/boxing_combo_generator.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';
import 'package:fight_my_shadow/services/voice_coach_service.dart';
import 'package:fight_my_shadow/services/sound_effects_service.dart';
import 'package:fight_my_shadow/controllers/workout_voice_controller.dart';
import 'package:fight_my_shadow/controllers/story_mode_controller.dart';
import 'package:fight_my_shadow/controllers/training_preferences_controller.dart';
import 'package:fight_my_shadow/repositories/learning_progress_repository.dart';
import 'package:fight_my_shadow/repositories/training_preferences_repository.dart';
import 'package:fight_my_shadow/screens/included_moves_screen.dart';
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/widgets/app_toast.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repositories
  final learningRepository = LearningProgressRepository();
  final trainingRepository = TrainingPreferencesRepository();
  final moveRepository = InMemoryMoveRepository();

  // Initialize Academy controller with persistence
  final storyModeController = StoryModeController(learningRepository);
  await storyModeController.init();

  // Initialize Training Preferences controller with persistence
  final trainingPreferencesController = TrainingPreferencesController(
    trainingRepository,
    moveRepository,
  );
  await trainingPreferencesController.init(storyModeController.state);

  runApp(FightMyShadowApp(
    storyModeController: storyModeController,
    trainingPreferencesController: trainingPreferencesController,
  ));
}

class FightMyShadowApp extends StatelessWidget {
  final StoryModeController storyModeController;
  final TrainingPreferencesController trainingPreferencesController;

  const FightMyShadowApp({
    super.key,
    required this.storyModeController,
    required this.trainingPreferencesController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StoryModeController>.value(
          value: storyModeController,
        ),
        ChangeNotifierProvider<TrainingPreferencesController>.value(
          value: trainingPreferencesController,
        ),
        Provider<MoveRepository>(
          create: (_) => InMemoryMoveRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Fight My Shadow',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const DisciplineSelectionScreen(),
        routes: {
          '/academy': (context) => const LearningProgressScreen(),
        },
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFFF5722), // Punchy orange-red
        secondary: const Color(0xFFFF6E40),
        surface: const Color(0xFF1A1A1A),
        background: const Color(0xFF0A0A0A),
        error: Colors.red.shade400,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFB0B0B0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF808080),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// Session Mode Enum
enum SessionMode {
  training,     // Regular training session with all moves
  drill,        // Focused drill on a single move
  addToArsenal, // Academy session integrating newly drilled move
}

// Drill Session Result
class DrillSessionResult {
  final bool completed;

  const DrillSessionResult({required this.completed});
}

// Add to Arsenal Session Result
class AddToArsenalSessionResult {
  final bool completed;

  const AddToArsenalSessionResult({required this.completed});
}

// Exam Session Result
class ExamSessionResult {
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int longestStreak;

  const ExamSessionResult({
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.longestStreak,
  });
}

// Exam Question Model
class ExamQuestion {
  final String code;
  final String correctMoveName;
  final List<String> options; // 3 options total (1 correct + 2 distractors), shuffled

  const ExamQuestion({
    required this.code,
    required this.correctMoveName,
    required this.options,
  });

  int get correctAnswerIndex => options.indexOf(correctMoveName);
}

// Workout Configuration Model
class WorkoutConfiguration {
  final int rounds;
  final int roundDurationSeconds;
  final int restDurationSeconds;
  final Difficulty difficulty;
  final Intensity intensity;
  final SessionMode mode;
  final String? drillMoveCode; // Single move code for drill mode
  final String? arsenalTargetMoveCode; // Target move code for arsenal mode
  final List<String>? allowedMoveCodes; // Allowed moves for arsenal mode (unlocked + target)

  WorkoutConfiguration({
    required this.rounds,
    required this.roundDurationSeconds,
    required this.restDurationSeconds,
    required this.difficulty,
    required this.intensity,
    this.mode = SessionMode.training,
    this.drillMoveCode,
    this.arsenalTargetMoveCode,
    this.allowedMoveCodes,
  });

  // Backward compatibility: legacy isDrillMode getter
  bool get isDrillMode => mode == SessionMode.drill;

  /// Factory for creating a drill session configuration
  factory WorkoutConfiguration.drill({
    required String moveCode,
    required Difficulty difficulty,
  }) {
    return WorkoutConfiguration(
      rounds: 1,
      roundDurationSeconds: 60,
      restDurationSeconds: 0,
      difficulty: difficulty,
      intensity: Intensity.medium, // Fixed for drills
      mode: SessionMode.drill,
      drillMoveCode: moveCode,
    );
  }

  /// Factory for creating an Add to Arsenal session configuration
  ///
  /// Round structure based on Academy level:
  /// - Level 1: 1 round × 2 minutes
  /// - Level 2: 2 rounds × 2 minutes
  /// - Level 3: 3 rounds × 2 minutes
  /// - Level 4 & 5: 3 rounds × 3 minutes
  /// - Level 6 & 7: 4 rounds × 3 minutes
  /// - Level 8-12: 5 rounds × 3 minutes
  factory WorkoutConfiguration.addToArsenal({
    required String targetMoveCode,
    required List<String> allowedMoveCodes,
    required Difficulty difficulty,
    required int academyLevel, // 1-12
  }) {
    int rounds;
    int roundDurationSeconds;

    if (academyLevel == 1) {
      rounds = 1;
      roundDurationSeconds = 120; // 2 minutes
    } else if (academyLevel == 2) {
      rounds = 2;
      roundDurationSeconds = 120;
    } else if (academyLevel == 3) {
      rounds = 3;
      roundDurationSeconds = 120;
    } else if (academyLevel == 4 || academyLevel == 5) {
      rounds = 3;
      roundDurationSeconds = 180; // 3 minutes
    } else if (academyLevel == 6 || academyLevel == 7) {
      rounds = 4;
      roundDurationSeconds = 180;
    } else {
      // academyLevel 8-12
      rounds = 5;
      roundDurationSeconds = 180;
    }

    return WorkoutConfiguration(
      rounds: rounds,
      roundDurationSeconds: roundDurationSeconds,
      restDurationSeconds: 60, // 1 minute rest between rounds
      difficulty: difficulty,
      intensity: Intensity.medium, // Fixed for academy sessions
      mode: SessionMode.addToArsenal,
      arsenalTargetMoveCode: targetMoveCode,
      allowedMoveCodes: allowedMoveCodes,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final TrainingDiscipline? discipline;

  const HomeScreen({super.key, this.discipline});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Training color palette (red)
  static const _trainingPrimary = Color(0xFFD32F2F); // Red 700
  static const _trainingSecondary = Color(0xFFEF5350); // Red 400

  // UI state for configuration
  int rounds = 3;
  int roundMinutes = 3;
  int roundSeconds = 0;
  int restMinutes = 1;
  int restSeconds = 0;
  Difficulty difficulty = Difficulty.intermediate;
  Intensity intensity = Intensity.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header section with branding
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Main content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildConfigurationCard(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEW SESSION',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure your workout',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),

          // Training icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _trainingPrimary,
                  _trainingSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORKOUT SETUP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontSize: 12,
                    color: _trainingPrimary,
                  ),
            ),
            const SizedBox(height: 24),

            // Included Moves button (at top)
            _buildIncludedMovesButton(),
            const SizedBox(height: 24),

            // Rounds
            _buildRoundsStepper(),
            const SizedBox(height: 24),

            // Round Duration
            _buildDurationPicker(
              label: 'Round Duration',
              minutes: roundMinutes,
              seconds: roundSeconds,
              onMinutesChanged: (value) => setState(() => roundMinutes = value),
              onSecondsChanged: (value) => setState(() => roundSeconds = value),
            ),
            const SizedBox(height: 24),

            // Rest Duration
            _buildDurationPicker(
              label: 'Rest Duration',
              minutes: restMinutes,
              seconds: restSeconds,
              onMinutesChanged: (value) => setState(() => restMinutes = value),
              onSecondsChanged: (value) => setState(() => restSeconds = value),
            ),
            const SizedBox(height: 32),

            // Difficulty
            _buildDifficultySelector(),
            const SizedBox(height: 24),

            // Intensity
            _buildIntensitySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundsStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rounds',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: rounds > 1 ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: rounds > 1
                    ? () => setState(() => rounds--)
                    : null,
              ),
              Text(
                '$rounds',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      color: _trainingPrimary,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: rounds < 12 ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: rounds < 12
                    ? () => setState(() => rounds++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker({
    required String label,
    required int minutes,
    required int seconds,
    required Function(int) onMinutesChanged,
    required Function(int) onSecondsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                value: minutes,
                label: 'MIN',
                maxValue: 10,
                onChanged: onMinutesChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(
                value: seconds,
                label: 'SEC',
                maxValue: 59,
                step: 15,
                onChanged: onSecondsChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required int value,
    required String label,
    required int maxValue,
    int step = 1,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: value > 0 ? () => onChanged((value - step).clamp(0, maxValue)) : null,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: value > 0 ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: value < maxValue ? () => onChanged((value + step).clamp(0, maxValue)) : null,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: value < maxValue ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Difficulty.values.map((diff) {
            final isSelected = difficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: diff.label,
                  isSelected: isSelected,
                  onTap: () => setState(() => difficulty = diff),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensity',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Intensity.values.map((intens) {
            final isSelected = intensity == intens;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: intens.label,
                  subtitle: intens.subtitle,
                  isSelected: isSelected,
                  onTap: () => setState(() => intensity = intens),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _trainingPrimary
              : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _trainingPrimary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _trainingPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedMovesButton() {
    return Consumer2<TrainingPreferencesController, StoryModeController>(
      builder: (context, trainingController, storyController, _) {
        final includedCount = trainingController.includedCount;
        final unlockedCount = storyController.state.moveProgress
            .where((p) => p.isUnlocked)
            .length;

        // If zero unlocked moves, show Academy CTA instead
        if (unlockedCount == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get Started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/academy');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9C27B0), // Purple for Academy
                        Color(0xFFBA68C8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unlock moves to start training',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Go to Academy to unlock your first move',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Otherwise show normal Included Moves button
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Included Moves',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncludedMovesScreen(),
                  ),
                );
                // State automatically updates via Provider when returning
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade600.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade600.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select moves',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Included moves: $includedCount',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartButton() {
    return Consumer2<TrainingPreferencesController, StoryModeController>(
      builder: (context, trainingController, storyController, _) {
        final includedCount = trainingController.includedCount;
        final canStart = includedCount > 0;

        return Opacity(
          opacity: canStart ? 1.0 : 0.5,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _trainingPrimary,
                  _trainingSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: canStart
                  ? [
                      BoxShadow(
                        color: _trainingPrimary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canStart
                    ? () {
                        // Get included unlocked move codes
                        final includedMoveCodes = trainingController
                            .getIncludedUnlockedMoveCodes(storyController.state);

                        // Create workout configuration and navigate
                        final config = WorkoutConfiguration(
                          rounds: rounds,
                          roundDurationSeconds: (roundMinutes * 60) + roundSeconds,
                          restDurationSeconds: (restMinutes * 60) + restSeconds,
                          difficulty: difficulty,
                          intensity: intensity,
                          allowedMoveCodes: includedMoveCodes,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutScreen(config: config),
                          ),
                        );
                      }
                    : () {
                        // Show informational message
                        AppToast.info(
                          context,
                          'Select at least one unlocked move to start training',
                        );
                      },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'START WORKOUT',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Workout Screen with Timer Logic
class WorkoutScreen extends StatefulWidget {
  final WorkoutConfiguration config;

  const WorkoutScreen({super.key, required this.config});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

enum WorkoutPhase { round, rest, complete }

/// Represents the phase of a combo cycle during a round.
enum ComboPhase {
  /// No combo is active (idle state between combos or during rest).
  idle,

  /// Combo is being announced (voice will call out the combo in future step).
  announce,

  /// User is executing the combo.
  execute,

  /// Recovery phase after combo execution (breathing/resetting).
  recover,
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // ========== Training Mode Timing Constants ==========
  // Execution timing (seconds per move) for normal Training Sessions
  static const double _trainingExecutionBeginner = 2.0;
  static const double _trainingExecutionIntermediate = 1.5;
  static const double _trainingExecutionAdvanced = 1.2;

  // Recovery timing (seconds) for normal Training Sessions
  static const double _trainingRecoveryLow = 4.0;
  static const double _trainingRecoveryMedium = 2.5;
  static const double _trainingRecoveryHigh = 1.5;

  late int currentRound;
  late WorkoutPhase currentPhase;
  late int remainingSeconds;
  late bool isPaused;
  Timer? _timer;

  // Combo-related state
  late BoxingComboGenerator _comboGenerator;
  late MoveRepository _moveRepository;
  Combo? _currentCombo;
  ComboPhase _comboPhase = ComboPhase.idle;
  double _comboPhaseRemainingSeconds = 0.0;
  Combo? _previousCombo;

  // Voice coaching and sound effects
  late WorkoutVoiceController _voiceController;
  late SoundEffectsService _soundService;

  // Drill/Arsenal-specific state
  bool _isInGetReadyDelay = false;
  double _getReadyRemainingSeconds = 0.0;

  // UI visibility state (separate from engine state)
  // This controls whether combo text is shown, but does NOT affect the combo state machine
  // Starts false for Academy modes (will be set true when first combo appears)
  bool _isComboVisible = false;
  double _comboHideDelaySeconds = 0.0;

  // Combo sequence counter for unique identification
  // Increments each time a new combo is created, ensuring voice speaks every combo
  int _comboSequenceCounter = 0;

  @override
  void initState() {
    super.initState();
    currentRound = 1;
    currentPhase = WorkoutPhase.round;
    remainingSeconds = widget.config.roundDurationSeconds;
    isPaused = false;

    // Initialize combo generator
    _moveRepository = InMemoryMoveRepository();
    _comboGenerator = BoxingComboGenerator(_moveRepository);

    // Set allowed move codes if specified (for Training Session filtering)
    if (widget.config.allowedMoveCodes != null) {
      _comboGenerator.setAllowedMoveCodes(widget.config.allowedMoveCodes);
    }

    // Initialize voice coaching and sound effects
    final voiceService = VoiceCoachService();
    _voiceController = WorkoutVoiceController(voiceService);
    _soundService = SoundEffectsService();
    _soundService.initialize();

    // For Drill and Add-to-Arsenal: play bell and start with 3-second "Get Ready" delay
    final isAcademyMode = widget.config.mode == SessionMode.drill ||
                          widget.config.mode == SessionMode.addToArsenal;
    if (isAcademyMode) {
      _soundService.playBell();
      _isInGetReadyDelay = true;
      _getReadyRemainingSeconds = 3.0;
      _isComboVisible = false; // Start hidden, will show when first combo appears
    } else {
      // Training mode: start with combo visible immediately
      _isComboVisible = true;
    }

    _startTimer();

    // Only start combo immediately if NOT in Academy mode
    if (!isAcademyMode) {
      _startNewComboIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voiceController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && mounted) {
        setState(() {
          // Handle combo auto-hide timer FIRST (before starting new combos)
          // This ONLY hides the UI, does NOT affect combo engine state
          if (_isComboVisible && _comboHideDelaySeconds > 0) {
            _comboHideDelaySeconds -= 1.0;
            if (_comboHideDelaySeconds <= 0) {
              // Hide the combo text from display
              _isComboVisible = false;
            }
          }

          // Handle "Get Ready" delay for Academy modes
          if (_isInGetReadyDelay) {
            _getReadyRemainingSeconds -= 1.0;
            if (_getReadyRemainingSeconds <= 0) {
              _isInGetReadyDelay = false;
              _startNewComboIfNeeded(); // Start first callout after delay
            }
          }

          // Update round timer
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            _handlePhaseTransition();
          }

          // Update combo phase during active rounds (only if not in get-ready delay)
          if (currentPhase == WorkoutPhase.round && !_isInGetReadyDelay) {
            _updateComboPhase(1.0); // 1 second elapsed
          }
        });

        // Update voice controller with current workout state
        // Always pass the actual combo to voice controller (engine state, not UI state)
        _voiceController.update(
          currentCombo: _currentCombo,
          comboPhase: _comboPhase,
          workoutPhase: currentPhase,
          isPaused: isPaused,
        );
      }
    });
  }

  void _handlePhaseTransition() {
    final isAcademyMode = widget.config.mode == SessionMode.drill ||
                          widget.config.mode == SessionMode.addToArsenal;

    if (currentPhase == WorkoutPhase.round) {
      // Just finished a round
      _clearCombo();
      _previousCombo = null;

      // Play bell at round end (Academy modes only)
      if (isAcademyMode) {
        _soundService.playBell();
      }

      if (currentRound < widget.config.rounds) {
        // Move to rest phase
        currentPhase = WorkoutPhase.rest;
        remainingSeconds = widget.config.restDurationSeconds;
      } else {
        // Finished the last round
        currentPhase = WorkoutPhase.complete;
        _timer?.cancel();

        // In academy modes (drill/arsenal), auto-return after brief delay
        if (isAcademyMode) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _endWorkout(completed: true);
            }
          });
        }
      }
    } else if (currentPhase == WorkoutPhase.rest) {
      // Just finished rest, move to next round
      currentRound++;
      currentPhase = WorkoutPhase.round;
      remainingSeconds = widget.config.roundDurationSeconds;

      // For Academy modes: play bell and start with get-ready delay
      if (isAcademyMode) {
        _soundService.playBell();
        _isInGetReadyDelay = true;
        _getReadyRemainingSeconds = 3.0;
      } else {
        // Start combo immediately for normal training
        _startNewComboIfNeeded();
      }
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    // Update voice controller immediately when pause state changes
    _voiceController.update(
      currentCombo: _currentCombo,
      comboPhase: _comboPhase,
      workoutPhase: currentPhase,
      isPaused: isPaused,
    );
  }

  void _endWorkout({bool completed = false}) {
    _timer?.cancel();
    _voiceController.stop();
    _clearCombo();
    _previousCombo = null;

    // Return appropriate result based on session mode
    if (widget.config.mode == SessionMode.drill) {
      Navigator.pop(context, DrillSessionResult(completed: completed));
    } else if (widget.config.mode == SessionMode.addToArsenal) {
      Navigator.pop(context, AddToArsenalSessionResult(completed: completed));
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    // In drill or arsenal mode, show confirmation if workout is in progress
    final isAcademyMode = widget.config.mode == SessionMode.drill ||
                          widget.config.mode == SessionMode.addToArsenal;

    if (isAcademyMode && currentPhase != WorkoutPhase.complete) {
      final modeName = widget.config.mode == SessionMode.drill ? 'drill' : 'arsenal session';
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Exit $modeName?'),
          content: Text('Your $modeName won\'t count if you leave early.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Exit',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        _endWorkout(completed: false);
      }

      return false; // Prevent default back navigation
    }

    // For training mode, allow normal back navigation
    return true;
  }

  /// Returns true for modes that use fast Academy cadence (Drill and Add-to-Arsenal).
  /// These modes share identical timing: minimal announce/execute durations and
  /// calculated recovery to keep total cycle in 3-5 second range.
  bool get _isFastAcademyCadence =>
      widget.config.mode == SessionMode.drill ||
      widget.config.mode == SessionMode.addToArsenal;

  /// Returns true if this is an Academy session (Drill or Add-to-Arsenal).
  bool get _isAcademySession =>
      widget.config.mode == SessionMode.drill ||
      widget.config.mode == SessionMode.addToArsenal;

  /// Returns the primary color for the current session mode.
  /// Academy sessions use purple, training sessions use red.
  Color get _primaryColor => _isAcademySession
      ? const Color(0xFF9C27B0) // Purple for Academy
      : const Color(0xFFD32F2F); // Red for Training

  /// Returns the secondary color for the current session mode.
  /// Academy sessions use lighter purple, training sessions use lighter red.
  Color get _secondaryColor => _isAcademySession
      ? const Color(0xFFBA68C8) // Light purple for Academy
      : const Color(0xFFEF5350); // Light red for Training

  /// Returns the session title based on mode and target move.
  String get _sessionTitle {
    if (widget.config.mode == SessionMode.drill && widget.config.drillMoveCode != null) {
      // Drill mode: "Drill: <MoveName>"
      final move = _moveRepository.getMoveByCode(widget.config.drillMoveCode!);
      return 'DRILL: ${move?.name.toUpperCase() ?? widget.config.drillMoveCode}';
    } else if (widget.config.mode == SessionMode.addToArsenal && widget.config.arsenalTargetMoveCode != null) {
      // Add-to-Arsenal mode: "Add to Arsenal: <MoveName>"
      final move = _moveRepository.getMoveByCode(widget.config.arsenalTargetMoveCode!);
      return 'ADD TO ARSENAL: ${move?.name.toUpperCase() ?? widget.config.arsenalTargetMoveCode}';
    } else {
      // Training mode: standard title
      return 'WORKOUT IN PROGRESS';
    }
  }

  /// Determines whether the configuration summary card should be shown.
  ///
  /// In Academy modes (Drill/Arsenal) with only 1 round, hide the config card.
  /// Otherwise show it (with Difficulty/Intensity hidden for Academy modes).
  bool get _shouldShowConfigCard {
    final isAcademyMode = widget.config.mode == SessionMode.drill ||
                          widget.config.mode == SessionMode.addToArsenal;

    if (!isAcademyMode) {
      // Training mode: always show
      return true;
    }

    // Academy modes: hide if only 1 round, otherwise show
    return widget.config.rounds > 1;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ========== Combo Management Methods ==========

  /// Calculates the announce phase duration based on combo length.
  /// Base duration + per-move duration.
  /// Fast Academy modes (Drill/Arsenal) use minimal announce times for frequent callouts.
  double _calculateAnnounceDuration(Combo combo) {
    if (_isFastAcademyCadence) {
      // Fast Academy cadence: minimal announce time - just enough for TTS
      // Total cycle should be dominated by recovery gap (1-5s)
      return 0.3 + (combo.moveCodes.length * 0.15); // ~0.3-0.75s
    }

    // Training mode: longer announce for clearer guidance
    const baseSeconds = 1.0;
    const secondsPerMove = 0.3;
    return baseSeconds + (combo.moveCodes.length * secondsPerMove);
  }

  /// Calculates the execution phase duration based on difficulty and combo length.
  /// Fast Academy modes (Drill/Arsenal) use minimal execution times for frequent callouts.
  double _calculateExecutionDuration(Combo combo) {
    if (_isFastAcademyCadence) {
      // Fast Academy cadence: minimal execution time
      // Total cycle should be dominated by recovery gap (1-5s)
      return combo.moveCodes.length * 0.4; // 0.4-1.2s
    }

    // Training mode: shifted timing - Intermediate uses old Beginner, Advanced uses old Intermediate
    double secondsPerMove;
    switch (widget.config.difficulty) {
      case Difficulty.beginner:
        // Beginner unchanged
        secondsPerMove = _trainingExecutionBeginner; // 2.0
        break;
      case Difficulty.intermediate:
        // Intermediate now uses old Beginner timing
        secondsPerMove = _trainingExecutionBeginner; // 2.0
        break;
      case Difficulty.advanced:
        // Advanced now uses old Intermediate timing
        secondsPerMove = _trainingExecutionIntermediate; // 1.5
        break;
    }

    // Slightly adjust for intensity (higher intensity = slightly faster)
    switch (widget.config.intensity) {
      case Intensity.low:
        secondsPerMove *= 1.1;
        break;
      case Intensity.medium:
        // no adjustment
        break;
      case Intensity.high:
        secondsPerMove *= 0.9;
        break;
    }

    return combo.moveCodes.length * secondsPerMove;
  }

  /// Calculates the recovery phase duration based on intensity.
  /// Fast Academy modes (Drill/Arsenal) use controlled recovery to keep total cycle time 3-5 seconds.
  double _calculateRecoveryDuration() {
    if (_isFastAcademyCadence && _currentCombo != null) {
      // Fast Academy cadence: calculate recovery to keep total cycle in 3-5 second range
      final announceDuration = _calculateAnnounceDuration(_currentCombo!);
      final executeDuration = _calculateExecutionDuration(_currentCombo!);

      // Target cycle time: random between 3.0 and 5.0 seconds
      final random = Random();
      final targetCycle = 3.0 + random.nextDouble() * 2.0; // 3.0-5.0s

      // Calculate needed recovery time
      double recovery = targetCycle - announceDuration - executeDuration;

      // Clamp recovery to reasonable bounds (min 0.6s, max 3.0s)
      recovery = recovery.clamp(0.6, 3.0);

      return recovery;
    }

    // Training mode: shifted timing based on difficulty + intensity
    // Intermediate uses old Beginner recovery, Advanced uses old Intermediate but faster
    double recoverySeconds;

    switch (widget.config.difficulty) {
      case Difficulty.beginner:
        // Beginner unchanged
        switch (widget.config.intensity) {
          case Intensity.low:
            recoverySeconds = _trainingRecoveryLow; // 4.0
            break;
          case Intensity.medium:
            recoverySeconds = _trainingRecoveryMedium; // 2.5
            break;
          case Intensity.high:
            recoverySeconds = _trainingRecoveryHigh; // 1.5
            break;
        }
        break;

      case Difficulty.intermediate:
        // Intermediate now uses old Beginner recovery timing
        switch (widget.config.intensity) {
          case Intensity.low:
            recoverySeconds = _trainingRecoveryLow; // 4.0
            break;
          case Intensity.medium:
            recoverySeconds = _trainingRecoveryMedium; // 2.5
            break;
          case Intensity.high:
            recoverySeconds = _trainingRecoveryHigh; // 1.5
            break;
        }
        break;

      case Difficulty.advanced:
        // Advanced uses old Intermediate timing, then reduces by 0.75s for faster pace
        switch (widget.config.intensity) {
          case Intensity.low:
            recoverySeconds = _trainingRecoveryLow - 0.75; // 3.25
            break;
          case Intensity.medium:
            recoverySeconds = _trainingRecoveryMedium - 0.75; // 1.75
            break;
          case Intensity.high:
            recoverySeconds = _trainingRecoveryHigh - 0.75; // 0.75
            break;
        }
        break;
    }

    // Ensure recovery never goes below 0.5 seconds
    return recoverySeconds.clamp(0.5, double.infinity);
  }

  /// Checks if there is enough time remaining in the round to start a new combo.
  bool _hasEnoughTimeForNewCombo() {
    if (currentPhase != WorkoutPhase.round) {
      return false;
    }

    // Need at least a minimum buffer before round ends
    // Reduced from 5.0s to 1.0s to keep combos flowing until the very end
    const minCycleTime = 1.0;
    return remainingSeconds >= minCycleTime;
  }

  /// Starts a new combo cycle if conditions are right.
  void _startNewComboIfNeeded() {
    // Only start combos during active rounds
    if (currentPhase != WorkoutPhase.round) {
      return;
    }

    // Check if we have enough time
    if (!_hasEnoughTimeForNewCombo()) {
      _clearCombo();
      return;
    }

    // Generate a new combo based on session mode
    final Combo newCombo;
    if (widget.config.mode == SessionMode.drill && widget.config.drillMoveCode != null) {
      // In drill mode, create a combo with 1-3 repetitions of the drill move
      // Probabilities: 70% single, 25% double, 5% triple
      final random = Random();
      final roll = random.nextDouble();
      final int repetitions;
      if (roll < 0.70) {
        repetitions = 1; // 70%
      } else if (roll < 0.95) {
        repetitions = 2; // 25%
      } else {
        repetitions = 3; // 5%
      }

      // Assign unique sequence ID to ensure voice speaks every combo
      _comboSequenceCounter++;
      newCombo = Combo(
        moveCodes: List.filled(repetitions, widget.config.drillMoveCode!),
        difficulty: widget.config.difficulty,
        name: 'Drill Practice',
        sequenceId: _comboSequenceCounter,
      );
    } else if (widget.config.mode == SessionMode.addToArsenal &&
               widget.config.arsenalTargetMoveCode != null &&
               widget.config.allowedMoveCodes != null) {
      // In arsenal mode, use weighted combo generation
      _comboSequenceCounter++;
      newCombo = _comboGenerator.generateArsenalCombo(
        difficulty: widget.config.difficulty,
        targetMoveCode: widget.config.arsenalTargetMoveCode!,
        allowedMoveCodes: widget.config.allowedMoveCodes!,
        previousCombo: _previousCombo,
      ).copyWith(sequenceId: _comboSequenceCounter);
    } else {
      // Normal training mode - generate varied combos
      _comboSequenceCounter++;
      newCombo = _comboGenerator.generateCombo(
        difficulty: widget.config.difficulty,
        previousCombo: _previousCombo,
      ).copyWith(sequenceId: _comboSequenceCounter);
    }

    // Start the announce phase
    _currentCombo = newCombo;
    _comboPhase = ComboPhase.announce;
    _comboPhaseRemainingSeconds = _calculateAnnounceDuration(newCombo);

    // Reset UI visibility for new combo with auto-hide timer
    _isComboVisible = true;
    // Hide delay: 1 second for short combos (≤3 moves), 2 seconds for longer combos
    // Add 1.0 to account for the current tick (timer will decrement on next tick)
    _comboHideDelaySeconds = newCombo.moveCodes.length <= 3 ? 2.0 : 3.0;

    // Immediately trigger voice for this new combo (event-driven, not timer-based)
    // This ensures voice speaks even for very short announce durations (<1s in drill mode)
    if (!isPaused && currentPhase == WorkoutPhase.round) {
      _voiceController.update(
        currentCombo: _currentCombo,
        comboPhase: ComboPhase.announce,
        workoutPhase: currentPhase,
        isPaused: false,
      );
    }
  }

  /// Updates the combo phase based on elapsed time.
  void _updateComboPhase(double elapsedSeconds) {
    if (_comboPhase == ComboPhase.idle || _currentCombo == null) {
      return;
    }

    _comboPhaseRemainingSeconds -= elapsedSeconds;

    if (_comboPhaseRemainingSeconds <= 0) {
      _transitionComboPhase();
    }
  }

  /// Transitions to the next combo phase.
  void _transitionComboPhase() {
    if (_currentCombo == null) {
      return;
    }

    switch (_comboPhase) {
      case ComboPhase.announce:
        // Move to execution
        _comboPhase = ComboPhase.execute;
        _comboPhaseRemainingSeconds = _calculateExecutionDuration(_currentCombo!);

        // For Academy modes: start hiding combo UI after a short delay
        final isAcademyMode = widget.config.mode == SessionMode.drill ||
                              widget.config.mode == SessionMode.addToArsenal;
        if (isAcademyMode) {
          _isComboVisible = false; // Mark as hidden (UI only)
          final random = Random();
          _comboHideDelaySeconds = 1.0 + random.nextDouble(); // 1.0-2.0 seconds
        }
        break;

      case ComboPhase.execute:
        // Move to recovery
        _comboPhase = ComboPhase.recover;
        _comboPhaseRemainingSeconds = _calculateRecoveryDuration();
        break;

      case ComboPhase.recover:
        // Combo cycle complete, prepare for next combo
        _previousCombo = _currentCombo;
        _clearCombo();
        _startNewComboIfNeeded();
        break;

      case ComboPhase.idle:
        // Should not reach here
        break;
    }
  }

  /// Clears the current combo state.
  void _clearCombo() {
    _currentCombo = null;
    _comboPhase = ComboPhase.idle;
    _comboPhaseRemainingSeconds = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (currentPhase == WorkoutPhase.complete) {
      return _buildCompleteScreen();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Main timer area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Phase indicator
                      _buildPhaseIndicator(),
                      const SizedBox(height: 20),

                      // Round info
                      _buildRoundInfo(),
                      const SizedBox(height: 24),

                      // Timer
                      _buildTimer(),
                      const SizedBox(height: 24),

                      // Combo display - all modes use same inline rendering
                      _buildAcademyComboDisplay(),
                      // Only add spacing if combo is actually rendered
                      if (_currentCombo != null && _comboPhase != ComboPhase.idle && !_isInGetReadyDelay && currentPhase != WorkoutPhase.rest) ...[
                        const SizedBox(height: 24),
                      ],

                      // Configuration summary (conditionally shown)
                      if (_shouldShowConfigCard) ...[
                        _buildConfigSummary(),
                      ],
                    ],
                  ),
                ),
              ),

              // Controls
              _buildControls(),

              // TEMPORARY - FOR TESTING ONLY: Skip button for Academy modes
              if (widget.config.mode == SessionMode.drill ||
                  widget.config.mode == SessionMode.addToArsenal) ...[
                const SizedBox(height: 12),
                _buildSkipButton(),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryColor,
                    _secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_martial_arts,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _sessionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseIndicator() {
    final isRound = currentPhase == WorkoutPhase.round;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRound
              ? [
                  _primaryColor,
                  _secondaryColor,
                ]
              : [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isRound
                    ? _primaryColor
                    : Colors.blue.shade600)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        isRound ? 'ROUND' : 'REST',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRoundInfo() {
    return Text(
      'Round $currentRound of ${widget.config.rounds}',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Text(
        _formatTime(remainingSeconds),
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.w900,
          color: _primaryColor,
          letterSpacing: 4,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildConfigSummary() {
    final isAcademyMode = widget.config.mode == SessionMode.drill ||
                          widget.config.mode == SessionMode.addToArsenal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'CONFIGURATION',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildConfigItem(
                  'Rounds',
                  '${widget.config.rounds}',
                ),
                _buildConfigItem(
                  'Round',
                  _formatTime(widget.config.roundDurationSeconds),
                ),
                _buildConfigItem(
                  'Rest',
                  _formatTime(widget.config.restDurationSeconds),
                ),
              ],
            ),
            // Only show Difficulty and Intensity for Training mode, not for Drill/Arsenal
            if (!isAcademyMode) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildConfigItem(
                    'Difficulty',
                    widget.config.difficulty.label,
                  ),
                  _buildConfigItem(
                    'Intensity',
                    widget.config.intensity.label,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds inline combo display for Academy modes (Drill/Arsenal).
  ///
  /// Shows combo codes directly as large white text (no card).
  /// Returns SizedBox.shrink() when nothing should be shown.
  ///
  /// Builds the combo display for Academy modes (drill/add-to-arsenal).
  ///
  /// Shows large centered text with combo codes that auto-hides after 1-2 seconds.
  /// Rendering rules:
  /// - _currentCombo != null
  /// - _comboPhase != ComboPhase.idle
  /// - _isComboVisible == true (controlled by auto-hide timer)
  Widget _buildAcademyComboDisplay() {
    // During rest phase
    if (currentPhase == WorkoutPhase.rest) {
      return const SizedBox.shrink(); // Rest is shown elsewhere
    }

    // During get-ready delay
    if (_isInGetReadyDelay) {
      return const SizedBox.shrink(); // Show nothing during countdown
    }

    // Show combo only if:
    // - We have a combo
    // - Phase is active (not idle)
    // - UI visibility flag is true (respects auto-hide timer)
    if (_currentCombo != null && _comboPhase != ComboPhase.idle && _isComboVisible) {
      final codes = _currentCombo!.moveCodes;
      final codesText = codes.join(' – ');

      return Center(
        child: Text(
          codesText,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Otherwise show nothing
    return const SizedBox.shrink();
  }

  Widget _buildConfigItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            icon: isPaused ? Icons.play_arrow : Icons.pause,
            label: isPaused ? 'RESUME' : 'PAUSE',
            onTap: _togglePause,
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildControlButton(
            icon: Icons.stop,
            label: 'END',
            onTap: _endWorkout,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  _primaryColor,
                  _secondaryColor,
                ],
              )
            : null,
        color: isPrimary ? null : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TEMPORARY - FOR TESTING ONLY
  /// Skip button for Academy modes (Drill/Add-to-Arsenal).
  /// Marks the session as completed and advances Story Mode state correctly.
  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: _skipSession,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: Colors.purple.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.purple.withOpacity(0.3)),
          ),
        ),
        child: Text(
          'Skip (testing)',
          style: TextStyle(
            color: Colors.purple.shade300,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // TEMPORARY - FOR TESTING ONLY
  /// Immediately completes the current Academy session (Drill/Add-to-Arsenal).
  /// Stops timers, clears state, and returns completed result to trigger proper progression.
  void _skipSession() {
    // Stop the timer and voice immediately
    _timer?.cancel();
    _voiceController.stop();
    _clearCombo();
    _previousCombo = null;

    // Mark as completed and return the appropriate result
    if (widget.config.mode == SessionMode.drill) {
      Navigator.pop(context, DrillSessionResult(completed: true));
    } else if (widget.config.mode == SessionMode.addToArsenal) {
      Navigator.pop(context, AddToArsenalSessionResult(completed: true));
    }
  }

  Widget _buildCompleteScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor,
                      _secondaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'WORKOUT COMPLETE!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You completed ${widget.config.rounds} rounds',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildControlButton(
                icon: Icons.home,
                label: 'BACK TO HOME',
                onTap: _endWorkout,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enums for difficulty and intensity
enum Difficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String label;
  const Difficulty(this.label);
}

enum Intensity {
  low('Low', 'Chill'),
  medium('Medium', 'Focused'),
  high('High', 'Relentless');

  final String label;
  final String subtitle;
  const Intensity(this.label, this.subtitle);
}
