import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/services/sound_effects_service.dart';

/// Celebration screen shown when a full Academy level is completed.
///
/// This is a MORE INTENSE celebration than the move-unlock celebration,
/// featuring fireworks, confetti, and a distinct celebratory sound.
/// Displays the completed level number and name.
class LevelCompleteCelebrationScreen extends StatefulWidget {
  final int levelNumber;
  final String levelName;

  const LevelCompleteCelebrationScreen({
    super.key,
    required this.levelNumber,
    required this.levelName,
  });

  @override
  State<LevelCompleteCelebrationScreen> createState() =>
      _LevelCompleteCelebrationScreenState();
}

class _LevelCompleteCelebrationScreenState
    extends State<LevelCompleteCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fireworksController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fireworksAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _glowAnimation;

  late SoundEffectsService _soundService;

  // Academy purple theme
  static const _academyPrimary = Color(0xFF9C27B0);
  static const _academySecondary = Color(0xFFBA68C8);

  // Celebration accent colors for confetti/fireworks
  static const _celebrationColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFF69B4), // Hot pink
    Color(0xFF00CED1), // Cyan
    Color(0xFF9C27B0), // Purple
    Color(0xFFBA68C8), // Light purple
    Color(0xFFFFFFFF), // White
    Color(0xFF7B68EE), // Medium slate blue
    Color(0xFFFF6347), // Tomato
  ];

  @override
  void initState() {
    super.initState();

    // Initialize sound service and play celebration sound
    _soundService = SoundEffectsService();
    _soundService.initialize().then((_) {
      _soundService.playLevelComplete();
    });

    // Main animation controller for text elements
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fireworks animation controller (repeating bursts)
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Confetti animation controller (continuous falling)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Fade in animation for text
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Scale animation for text (elastic bounce)
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    // Glow pulsing animation
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Fireworks burst animation
    _fireworksAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireworksController,
      curve: Curves.easeOut,
    ));

    // Confetti falling animation
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.linear,
    ));

    // Start all animations
    _mainController.forward();
    _fireworksController.repeat();
    _confettiController.repeat();

    // Auto-navigate back after delay
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _navigateBack();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _fireworksController.dispose();
    _confettiController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _navigateBack() {
    // Navigate directly to Academy screen (LearningProgressScreen)
    // Use pushAndRemoveUntil to guarantee we land on Academy, not Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LearningProgressScreen(),
      ),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigateBack, // Allow tap to skip
        child: Stack(
          children: [
            // Animated gradient background with purple glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        _academyPrimary.withValues(alpha: 0.4 * _glowAnimation.value),
                        _academySecondary.withValues(alpha: 0.25 * _glowAnimation.value),
                        const Color(0xFF1A0A20).withValues(alpha: 0.9),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),

            // Fireworks layer
            AnimatedBuilder(
              animation: _fireworksAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FireworksPainter(
                    progress: _fireworksAnimation.value,
                    colors: _celebrationColors,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Confetti layer
            AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _confettiAnimation.value,
                    colors: _celebrationColors,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Trophy icon with glow
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFD700).withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.5 * _glowAnimation.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // "LEVEL COMPLETE" headline with glow
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFFFFF),
                                Color(0xFFFFD700),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'LEVEL COMPLETE',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Level number and name badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_academyPrimary, _academySecondary],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _academyPrimary.withValues(alpha: 0.6 * _glowAnimation.value),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'LEVEL ${widget.levelNumber}',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 3.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.levelName,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Motivational text
                          Text(
                            'You\'ve mastered this level. Keep going!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // "Tap to continue" hint
                          Text(
                            'Tap to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for fireworks burst effect
class _FireworksPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final math.Random _random = math.Random(42);

  _FireworksPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple firework bursts at different positions
    final burstCenters = [
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.45),
    ];

    for (int burst = 0; burst < burstCenters.length; burst++) {
      final center = burstCenters[burst];
      final burstOffset = (burst * 0.15) % 1.0;
      final adjustedProgress = ((progress + burstOffset) % 1.0);

      // Each burst has particles radiating outward
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20.0) * 2 * math.pi + burst;
        final distance = 80 + _random.nextDouble() * 60;

        // Particles expand and fade
        final particleProgress = adjustedProgress;
        final x = center.dx + math.cos(angle) * distance * particleProgress;
        final y = center.dy + math.sin(angle) * distance * particleProgress +
                  (50 * particleProgress * particleProgress); // Gravity effect

        // Fade out as they expand
        final opacity = (1.0 - particleProgress).clamp(0.0, 1.0) * 0.9;

        // Pick a color
        final color = colors[(i + burst) % colors.length];
        paint.color = color.withValues(alpha: opacity);

        // Random size
        final radius = 2.0 + _random.nextDouble() * 4.0;
        canvas.drawCircle(Offset(x, y), radius * (1.0 - particleProgress * 0.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom painter for falling confetti effect
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final math.Random _random = math.Random(123);

  _ConfettiPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate confetti pieces
    for (int i = 0; i < 80; i++) {
      // Fixed starting position based on index
      final startX = (_random.nextDouble() * size.width);
      final startY = -20.0 - (_random.nextDouble() * 100);

      // Calculate current position with sway
      final fallSpeed = 0.3 + _random.nextDouble() * 0.4;
      final swayAmount = 30 + _random.nextDouble() * 40;
      final swaySpeed = 2 + _random.nextDouble() * 3;

      final y = startY + (size.height + 150) * ((progress * fallSpeed + i * 0.02) % 1.0);
      final x = startX + math.sin(progress * swaySpeed * math.pi * 2 + i) * swayAmount;

      // Only draw if on screen
      if (y > -20 && y < size.height + 20) {
        final color = colors[i % colors.length];
        paint.color = color.withValues(alpha: 0.85);

        // Random rotation
        final rotation = progress * math.pi * 4 + i;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        // Draw rectangular confetti piece
        final width = 4.0 + _random.nextDouble() * 6.0;
        final height = 8.0 + _random.nextDouble() * 8.0;
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
