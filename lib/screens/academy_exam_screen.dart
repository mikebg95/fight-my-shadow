import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/domain/exam/exam_question_generator.dart';

/// Academy Exam Screen - tests CODE → MOVE recognition under time pressure.
///
/// User must identify move names from codes within a time limit.
/// Passing requires >=85% accuracy AND a streak of 8+ correct answers.
class AcademyExamScreen extends StatefulWidget {
  final Move targetMove;
  final List<Move> unlockedMoves;
  final int academyLevel;

  const AcademyExamScreen({
    super.key,
    required this.targetMove,
    required this.unlockedMoves,
    required this.academyLevel,
  });

  @override
  State<AcademyExamScreen> createState() => _AcademyExamScreenState();
}

class _AcademyExamScreenState extends State<AcademyExamScreen> {
  // Exam configuration
  static const int totalExamDurationSeconds = 60;
  late final int questionTimeLimit;
  late final int totalQuestions;

  // Questions
  late final List<ExamQuestion> questions;
  int currentQuestionIndex = 0;

  // Timing
  Timer? _examTimer;
  Timer? _questionTimer;
  int remainingExamSeconds = totalExamDurationSeconds;
  double questionTimeRemaining = 0.0;

  // Scoring
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int currentStreak = 0;
  int longestStreak = 0;

  // UI state
  bool examComplete = false;
  bool showingFeedback = false;
  int? selectedAnswerIndex;

  @override
  void initState() {
    super.initState();

    // Configure question time limit based on academy level
    if (widget.academyLevel <= 3) {
      questionTimeLimit = 2; // 2 seconds for levels 1-3
    } else if (widget.academyLevel <= 7) {
      questionTimeLimit = 2; // 1.5 seconds would be: questionTimeLimit = 2 (using int, so keep 2)
    } else {
      questionTimeLimit = 1; // 1.2 seconds would be: questionTimeLimit = 1 (simplify to 1 for MVP)
    }

    // Calculate total questions
    totalQuestions = (totalExamDurationSeconds / questionTimeLimit).floor();

    // Generate questions
    final generator = ExamQuestionGenerator();
    questions = generator.generateQuestions(
      targetMove: widget.targetMove,
      unlockedMoves: widget.unlockedMoves,
      questionCount: totalQuestions,
    );

    // Start timers
    _startExamTimer();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          remainingExamSeconds--;
          if (remainingExamSeconds <= 0) {
            _endExam();
          }
        });
      }
    });
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    questionTimeRemaining = questionTimeLimit.toDouble();

    _questionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !showingFeedback) {
        setState(() {
          questionTimeRemaining -= 0.1;
          if (questionTimeRemaining <= 0) {
            _handleTimeout();
          }
        });
      }
    });
  }

  void _handleTimeout() {
    _handleAnswer(null); // Timeout counts as wrong
  }

  void _handleAnswer(int? answerIndex) {
    if (showingFeedback || examComplete) return;

    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = answerIndex != null &&
        currentQuestion.options[answerIndex] == currentQuestion.correctMoveName;

    setState(() {
      selectedAnswerIndex = answerIndex;
      showingFeedback = true;

      if (isCorrect) {
        correctAnswers++;
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        wrongAnswers++;
        currentStreak = 0;
      }
    });

    // Brief feedback, then advance
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      setState(() {
        showingFeedback = false;
        selectedAnswerIndex = null;

        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          _startQuestionTimer();
        } else {
          _endExam();
        }
      });
    });
  }

  void _endExam() {
    _examTimer?.cancel();
    _questionTimer?.cancel();

    final totalAnswered = correctAnswers + wrongAnswers;
    final accuracy = totalAnswered > 0 ? (correctAnswers / totalAnswered) : 0.0;
    final passed = accuracy >= 0.85 && longestStreak >= 8;

    setState(() {
      examComplete = true;
    });
  }

  void _exitWithResult({required bool examPassed}) {
    final totalAnswered = correctAnswers + wrongAnswers;
    final accuracy = totalAnswered > 0 ? (correctAnswers / totalAnswered) : 0.0;

    Navigator.pop(
      context,
      ExamSessionResult(
        passed: examPassed,
        correctAnswers: correctAnswers,
        totalQuestions: totalAnswered,
        accuracy: accuracy,
        longestStreak: longestStreak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (examComplete) {
      return _buildResultsScreen();
    }

    return _buildExamScreen();
  }

  Widget _buildExamScreen() {
    final currentQuestion = questions[currentQuestionIndex];
    const academyPurple = Color(0xFF9C27B0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACADEMY EXAM',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                              color: academyPurple,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock: ${widget.targetMove.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: academyPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: academyPurple.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$remainingExamSeconds s',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: academyPurple,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(academyPurple),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
              ),

              const Spacer(),

              // Question prompt (CODE)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: academyPurple.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'CODE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.code,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: academyPurple,
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Question timer bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: questionTimeRemaining / questionTimeLimit,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    questionTimeRemaining < 0.5 ? Colors.red.shade400 : academyPurple,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 32),

              // Answer options
              ...currentQuestion.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrect = option == currentQuestion.correctMoveName;
                final isSelected = selectedAnswerIndex == index;

                Color borderColor = academyPurple.withValues(alpha: 0.3);
                Color? backgroundColor;

                if (showingFeedback && isSelected) {
                  if (isCorrect) {
                    borderColor = Colors.green.shade400;
                    backgroundColor = Colors.green.shade400.withValues(alpha: 0.2);
                  } else {
                    borderColor = Colors.red.shade400;
                    backgroundColor = Colors.red.shade400.withValues(alpha: 0.2);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: showingFeedback ? null : () => _handleAnswer(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    const academyPurple = Color(0xFF9C27B0);
    final totalAnswered = correctAnswers + wrongAnswers;
    final accuracy = totalAnswered > 0 ? (correctAnswers / totalAnswered) : 0.0;
    final passed = accuracy >= 0.85 && longestStreak >= 8;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pass/Fail indicator
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: (passed ? Colors.green.shade900 : Colors.red.shade900)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: passed ? Colors.green.shade400 : Colors.red.shade400,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      passed ? Icons.check_circle : Icons.cancel,
                      color: passed ? Colors.green.shade400 : Colors.red.shade400,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passed ? 'EXAM PASSED!' : 'EXAM FAILED',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: passed ? Colors.green.shade400 : Colors.red.shade400,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Stats
              _buildStatRow('Accuracy', '${(accuracy * 100).toStringAsFixed(1)}%', passed),
              const SizedBox(height: 16),
              _buildStatRow('Correct Answers', '$correctAnswers / $totalAnswered', passed),
              const SizedBox(height: 16),
              _buildStatRow('Longest Streak', '$longestStreak', passed),

              const SizedBox(height: 40),

              // Pass requirements
              if (!passed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade400.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requirements to pass:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Accuracy ≥ 85% ${accuracy >= 0.85 ? "✓" : "✗"}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: accuracy >= 0.85
                                  ? Colors.green.shade400
                                  : Colors.red.shade400,
                            ),
                      ),
                      Text(
                        '• Streak ≥ 8 ${longestStreak >= 8 ? "✓" : "✗"}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: longestStreak >= 8
                                  ? Colors.green.shade400
                                  : Colors.red.shade400,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              if (passed)
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => _exitWithResult(examPassed: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: academyPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: OutlinedButton(
                          onPressed: () => _exitWithResult(examPassed: false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () {
                            // Restart exam
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademyExamScreen(
                                  targetMove: widget.targetMove,
                                  unlockedMoves: widget.unlockedMoves,
                                  academyLevel: widget.academyLevel,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: academyPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Retry Exam',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                          ),
                        ),
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

  Widget _buildStatRow(String label, String value, bool passed) {
    const academyPurple = Color(0xFF9C27B0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: academyPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: academyPurple,
                ),
          ),
        ],
      ),
    );
  }
}
