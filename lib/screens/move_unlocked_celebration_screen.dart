import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fight_my_shadow/screens/learning_progress_screen.dart';
import 'package:fight_my_shadow/utils/responsive.dart';

/// Celebration screen shown when a move is unlocked.
///
/// Displays a brief celebration animation with confetti-style effects,
/// then automatically navigates back to the Academy screen.
class MoveUnlockedCelebrationScreen extends StatefulWidget {
  final String moveName;
  final String moveCode;
  final String? nextMoveName;

  const MoveUnlockedCelebrationScreen({
    super.key,
    required this.moveName,
    required this.moveCode,
    this.nextMoveName,
  });

  @override
  State<MoveUnlockedCelebrationScreen> createState() =>
      _MoveUnlockedCelebrationScreenState();
}

class _MoveUnlockedCelebrationScreenState
    extends State<MoveUnlockedCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade in animation for text
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Scale animation for text
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    // Sparkle/particle animation
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation immediately
    _controller.forward();

    // Auto-navigate back after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _navigateBack();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateBack() {
    // Simply pop back to the calling screen
    // The calling screen (move_detail_screen) will handle:
    // 1. Checking if level is complete
    // 2. Showing level celebration if needed
    // 3. Navigating to Academy after all celebrations
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Fallback: Navigate directly to Academy if we can't pop
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LearningProgressScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigateBack, // Allow tap to skip
        child: Stack(
          children: [
            // Animated gradient background burst
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5 * _sparkleAnimation.value,
                      colors: [
                        const Color(0xFF9C27B0).withOpacity(0.3 * _sparkleAnimation.value),
                        const Color(0xFFBA68C8).withOpacity(0.2 * _sparkleAnimation.value),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                );
              },
            ),

            // Sparkle particles
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SparklePainter(_sparkleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final isSmall = Responsive.isSmallPhone(context);
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.horizontalPadding(context),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "Unlocked!" headline
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'UNLOCKED!',
                                style: TextStyle(
                                  fontSize: Responsive.rf(context, isSmall ? 42 : 56),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.rs(context, isSmall ? 24 : 32)),

                            // Move code badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.rs(context, isSmall ? 24 : 32),
                                vertical: Responsive.rs(context, isSmall ? 12 : 16),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9C27B0),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.moveCode,
                                style: TextStyle(
                                  fontSize: Responsive.rf(context, isSmall ? 52 : 72),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.rs(context, isSmall ? 18 : 24)),

                            // Move name
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.moveName,
                                style: TextStyle(
                                  fontSize: Responsive.rf(context, isSmall ? 24 : 32),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: Responsive.rs(context, isSmall ? 36 : 48)),

                            // Optional "Next up" text
                            if (widget.nextMoveName != null) ...[
                              Text(
                                'Next up: ${widget.nextMoveName}',
                                style: TextStyle(
                                  fontSize: Responsive.rf(context, isSmall ? 14 : 18),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Responsive.rs(context, isSmall ? 18 : 24)),
                            ],

                            // "Tap to continue" hint
                            Text(
                              'Tap to continue',
                              style: TextStyle(
                                fontSize: Responsive.rf(context, isSmall ? 14 : 16),
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
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

/// Custom painter for sparkle/confetti particles
class _SparklePainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(42); // Fixed seed for consistent animation

  _SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate sparkles at fixed positions
    for (int i = 0; i < 50; i++) {
      final angle = (i / 50.0) * 2 * math.pi;
      final distance = 200 + _random.nextDouble() * 150;

      final x = size.width / 2 + math.cos(angle) * distance * progress;
      final y = size.height / 2 + math.sin(angle) * distance * progress;

      // Fade out as they move away
      final opacity = (1.0 - progress) * 0.8;

      // Random color between purple shades
      final colorIndex = _random.nextInt(3);
      Color color;
      switch (colorIndex) {
        case 0:
          color = const Color(0xFF9C27B0);
          break;
        case 1:
          color = const Color(0xFFBA68C8);
          break;
        default:
          color = Colors.white;
      }

      paint.color = color.withOpacity(opacity);

      // Random size
      final radius = 2.0 + _random.nextDouble() * 3.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
