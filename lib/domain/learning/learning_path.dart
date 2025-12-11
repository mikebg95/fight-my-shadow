import 'package:fight_my_shadow/domain/learning/learning_move.dart';

/// The canonical learning path for Story Mode.
///
/// This class defines the fixed, ordered curriculum of 18 learning moves
/// that users progress through in Story Mode. Each learning move maps to
/// underlying Move codes from the main move system.
///
/// The learning path is organized into 6 phases:
/// 1. Basics (4 moves)
/// 2. Basic angles (2 moves)
/// 3. Defense (4 moves)
/// 4. Intermediate punches (4 moves)
/// 5. Advanced footwork (2 moves)
/// 6. Extras (2 moves)
///
/// This class is immutable and knows nothing about user progress.
/// It only defines the curriculum structure and mapping to move codes.
class LearningPath {
  /// The complete, ordered list of all 18 learning moves.
  static const List<LearningMove> _allMoves = [
    // ========== PHASE 1: BASICS (4 moves) ==========
    LearningMove(
      id: 1,
      phase: 1,
      orderInPhase: 0,
      displayName: 'Jab',
      description:
          'The jab is your most important punch. A quick, straight punch thrown with your lead hand. Use it to measure distance, set up combinations, and keep your opponent at bay.',
      moveCodes: ['1'], // Left straight (jab)
    ),
    LearningMove(
      id: 2,
      phase: 1,
      orderInPhase: 1,
      displayName: 'Step forward',
      description:
          'Moving forward by stepping with your lead foot first, then following with your rear foot. Essential for closing distance and adding power to your punches.',
      moveCodes: ['N'], // Step in
    ),
    LearningMove(
      id: 3,
      phase: 1,
      orderInPhase: 2,
      displayName: 'Step backward',
      description:
          'Moving backward by stepping with your rear foot first, then following with your lead foot. Critical for creating space and avoiding pressure.',
      moveCodes: ['O'], // Step back
    ),
    LearningMove(
      id: 4,
      phase: 1,
      orderInPhase: 3,
      displayName: 'Cross',
      description:
          'A powerful straight punch thrown with your rear hand. One of your most powerful weapons, generating force through hip and shoulder rotation.',
      moveCodes: ['2'], // Right straight (cross)
    ),

    // ========== PHASE 2: BASIC ANGLES (2 moves) ==========
    LearningMove(
      id: 5,
      phase: 2,
      orderInPhase: 0,
      displayName: 'Step left',
      description:
          'Lateral movement to the left. Move your lead foot first, then follow with your rear foot. Used to circle, create angles, and avoid being cornered.',
      moveCodes: ['P'], // Step left
    ),
    LearningMove(
      id: 6,
      phase: 2,
      orderInPhase: 1,
      displayName: 'Step right',
      description:
          'Lateral movement to the right. Move your rear foot first, then follow with your lead foot. Essential for ring generalship and angle creation.',
      moveCodes: ['Q'], // Step right
    ),

    // ========== PHASE 3: DEFENSE (4 moves) ==========
    LearningMove(
      id: 7,
      phase: 3,
      orderInPhase: 0,
      displayName: 'Slip left',
      description:
          'A head movement that shifts your head to the left (outside) of an incoming punch. Move your head off the centerline while staying in punching range. Great for setting up counter punches.',
      moveCodes: ['A'], // Slip left
    ),
    LearningMove(
      id: 8,
      phase: 3,
      orderInPhase: 1,
      displayName: 'Slip right',
      description:
          'A head movement that shifts your head to the right (inside) of an incoming punch. Similar to slip left but moving to the inside. Perfect setup for left hooks.',
      moveCodes: ['B'], // Slip right
    ),
    LearningMove(
      id: 9,
      phase: 3,
      orderInPhase: 2,
      displayName: 'Roll',
      description:
          'A circular upper body movement that rotates under hooks and wide punches. Roll your shoulders and torso in a fluid motion, moving under the punch. Come up in position to counter.',
      moveCodes: ['C'], // Roll left (primary roll for beginners)
    ),
    LearningMove(
      id: 10,
      phase: 3,
      orderInPhase: 3,
      displayName: 'Block',
      description:
          'Using your hands or arms to block or deflect incoming punches. Keep your guard up and use your gloves to protect your head and body from strikes.',
      moveCodes: ['G'], // Block straight left (representative block)
    ),

    // ========== PHASE 4: INTERMEDIATE PUNCHES (4 moves) ==========
    LearningMove(
      id: 11,
      phase: 4,
      orderInPhase: 0,
      displayName: 'Lead hook',
      description:
          'A curved punch thrown with your lead hand, traveling in a horizontal arc. Keep your elbow up at shoulder level and pivot your lead foot as you rotate your torso.',
      moveCodes: ['3'], // Left hook
    ),
    LearningMove(
      id: 12,
      phase: 4,
      orderInPhase: 1,
      displayName: 'Rear hook',
      description:
          'A curved punch thrown with your rear hand in a horizontal arc. Generate explosive power by pivoting your rear foot and rotating your entire body. Great for countering.',
      moveCodes: ['4'], // Right hook
    ),
    LearningMove(
      id: 13,
      phase: 4,
      orderInPhase: 2,
      displayName: 'Lead uppercut',
      description:
          'An upward punch thrown with your lead hand, traveling vertically. Devastating at close range. Dip slightly, then drive upward with your legs and hips.',
      moveCodes: ['5'], // Left uppercut
    ),
    LearningMove(
      id: 14,
      phase: 4,
      orderInPhase: 3,
      displayName: 'Rear uppercut',
      description:
          'An upward punch with your rear hand. One of the most powerful close-range strikes. Bend your rear knee, then explosively drive upward while rotating your hips.',
      moveCodes: ['6'], // Right uppercut
    ),

    // ========== PHASE 5: ADVANCED FOOTWORK (2 moves) ==========
    LearningMove(
      id: 15,
      phase: 5,
      orderInPhase: 0,
      displayName: 'Pivot left',
      description:
          'Rotating on your lead foot to turn left, repositioning yourself at an angle. Pivot on the ball of your lead foot and swing your rear leg around. Excellent for escaping pressure.',
      moveCodes: ['R'], // Pivot left
    ),
    LearningMove(
      id: 16,
      phase: 5,
      orderInPhase: 1,
      displayName: 'Pivot right',
      description:
          'Rotating on your rear foot to turn right. Used to reposition and create angles when moving away from pressure. Pivot on the ball of your rear foot.',
      moveCodes: ['S'], // Pivot right
    ),

    // ========== PHASE 6: EXTRAS (2 moves) ==========
    LearningMove(
      id: 17,
      phase: 6,
      orderInPhase: 0,
      displayName: 'Feints',
      description:
          'A deceptive movement that mimics the start of a strike without fully committing. Feints draw reactions from your opponent, create openings, and disrupt their rhythm. Start the motion of a punch, but pull it back before completing, then attack the opening.',
      moveCodes: ['F'], // Feint (single modifier move)
    ),
    LearningMove(
      id: 18,
      phase: 6,
      orderInPhase: 1,
      displayName: 'Rhythm variations',
      description:
          'Changing the speed and timing of your movements to disrupt your opponent\'s expectations. Mix fast and slow punches, add pauses, or burst with quick combinations. Rhythm variations make you unpredictable.',
      moveCodes: [
        'T', // Shuffle forward (quick rhythm change)
        'U', // Shuffle backward (quick rhythm change)
      ],
    ),
  ];

  /// Returns the complete list of all learning moves in unlock order.
  static List<LearningMove> getAllMoves() => List.unmodifiable(_allMoves);

  /// Returns a learning move by its ID (1-18).
  ///
  /// Returns null if no move with the given ID exists.
  static LearningMove? getMoveById(int id) {
    try {
      return _allMoves.firstWhere((move) => move.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Returns all learning moves in a given phase (1-6).
  ///
  /// Returns an empty list if the phase number is invalid.
  static List<LearningMove> getMovesByPhase(int phase) {
    return _allMoves.where((move) => move.phase == phase).toList();
  }

  /// Returns the index (0-based) of a learning move in the unlock order.
  ///
  /// Returns -1 if the move is not found.
  static int getUnlockIndex(LearningMove move) {
    return _allMoves.indexOf(move);
  }

  /// Returns the index (0-based) of a learning move by its ID.
  ///
  /// Returns -1 if no move with the given ID exists.
  static int getUnlockIndexById(int id) {
    final move = getMoveById(id);
    return move != null ? getUnlockIndex(move) : -1;
  }

  /// Returns the total number of learning moves.
  static int get totalMoves => _allMoves.length;

  /// Returns the total number of phases.
  static const int totalPhases = 6;

  /// Returns the number of moves in a given phase.
  ///
  /// Returns 0 if the phase number is invalid.
  static int getMovesCountInPhase(int phase) {
    return _allMoves.where((move) => move.phase == phase).length;
  }
}
