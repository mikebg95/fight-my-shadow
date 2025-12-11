import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';

/// The canonical learning path for Academy.
///
/// This class defines the fixed, ordered curriculum of 38 learning moves
/// that users progress through in Academy. Each learning move maps to
/// underlying Move codes from the main move system.
///
/// The learning path is organized into 12 levels:
/// 1. Foundation Fists (4 moves)
/// 2. Rails & Shields (4 moves)
/// 3. Hook City (4 moves)
/// 4. Turn the Corner (2 moves)
/// 5. Uppercut Engine (2 moves)
/// 6. Slipstream (3 moves)
/// 7. Wave & Fade (3 moves)
/// 8. Shield Wall (4 moves)
/// 9. Deception Arts (2 moves)
/// 10. Footwork Fury (2 moves)
/// 11. Body Hunters (4 moves)
/// 12. Shadow Weapons (3 moves)
///
/// This class is immutable and knows nothing about user progress.
/// It only defines the curriculum structure and mapping to move codes.
class LearningPath {
  /// The complete, ordered list of all 38 learning moves.
  static const List<LearningMove> _allMoves = [
    // ========== LEVEL 1: Foundation Fists (4 moves) ==========
    LearningMove(
      id: 1,
      level: 1,
      orderInLevel: 0,
      displayName: 'Left straight (Jab)',
      description:
          'The jab is your most important punch. A quick, straight punch thrown with your lead hand. Use it to measure distance, set up combinations, and keep your opponent at bay.',
      moveCodes: ['1'],
    ),
    LearningMove(
      id: 2,
      level: 1,
      orderInLevel: 1,
      displayName: 'Right straight (Cross)',
      description:
          'A powerful straight punch thrown with your rear hand. One of your most powerful weapons, generating force through hip and shoulder rotation.',
      moveCodes: ['2'],
    ),
    LearningMove(
      id: 3,
      level: 1,
      orderInLevel: 2,
      displayName: 'Step in',
      description:
          'Moving forward by stepping with your lead foot first, then following with your rear foot. Essential for closing distance and adding power to your punches.',
      moveCodes: ['P'],
    ),
    LearningMove(
      id: 4,
      level: 1,
      orderInLevel: 3,
      displayName: 'Step back',
      description:
          'Moving backward by stepping with your rear foot first, then following with your lead foot. Critical for creating space and avoiding pressure.',
      moveCodes: ['Q'],
    ),

    // ========== LEVEL 2: Rails & Shields (4 moves) ==========
    LearningMove(
      id: 5,
      level: 2,
      orderInLevel: 0,
      displayName: 'Step left',
      description:
          'Lateral movement to the left. Move your lead foot first, then follow with your rear foot. Used to circle, create angles, and avoid being cornered.',
      moveCodes: ['R'],
    ),
    LearningMove(
      id: 6,
      level: 2,
      orderInLevel: 1,
      displayName: 'Step right',
      description:
          'Lateral movement to the right. Move your rear foot first, then follow with your lead foot. Essential for ring generalship and angle creation.',
      moveCodes: ['S'],
    ),
    LearningMove(
      id: 7,
      level: 2,
      orderInLevel: 2,
      displayName: 'Block straight left',
      description:
          'Using your rear hand or glove to block or parry a straight left hand (jab). Position your glove to intercept or deflect the incoming punch.',
      moveCodes: ['A'],
    ),
    LearningMove(
      id: 8,
      level: 2,
      orderInLevel: 3,
      displayName: 'Block straight right',
      description:
          'Using your lead hand to block or parry an incoming straight right (cross). Essential for protecting against power punches.',
      moveCodes: ['B'],
    ),

    // ========== LEVEL 3: Hook City (4 moves) ==========
    LearningMove(
      id: 9,
      level: 3,
      orderInLevel: 0,
      displayName: 'Left hook',
      description:
          'A curved punch thrown with your lead hand, traveling in a horizontal arc. Keep your elbow up at shoulder level and pivot your lead foot as you rotate your torso.',
      moveCodes: ['3'],
    ),
    LearningMove(
      id: 10,
      level: 3,
      orderInLevel: 1,
      displayName: 'Right hook',
      description:
          'A curved punch thrown with your rear hand in a horizontal arc. Generate explosive power by pivoting your rear foot and rotating your entire body.',
      moveCodes: ['4'],
    ),
    LearningMove(
      id: 11,
      level: 3,
      orderInLevel: 2,
      displayName: 'Block left hook',
      description:
          'Raising your rear hand/arm to block an incoming left hook to the head. Keep your elbow up and your glove covering the side of your head.',
      moveCodes: ['C'],
    ),
    LearningMove(
      id: 12,
      level: 3,
      orderInLevel: 3,
      displayName: 'Block right hook',
      description:
          'Raising your lead hand/arm to block an incoming right hook. Position your arm to absorb the impact on your glove and forearm.',
      moveCodes: ['D'],
    ),

    // ========== LEVEL 4: Turn the Corner (2 moves) ==========
    LearningMove(
      id: 13,
      level: 4,
      orderInLevel: 0,
      displayName: 'Pivot left',
      description:
          'Rotating on your lead foot to turn left, repositioning yourself at an angle. Pivot on the ball of your lead foot and swing your rear leg around. Excellent for escaping pressure.',
      moveCodes: ['T'],
    ),
    LearningMove(
      id: 14,
      level: 4,
      orderInLevel: 1,
      displayName: 'Pivot right',
      description:
          'Rotating on your rear foot to turn right. Used to reposition and create angles when moving away from pressure. Pivot on the ball of your rear foot.',
      moveCodes: ['U'],
    ),

    // ========== LEVEL 5: Uppercut Engine (2 moves) ==========
    LearningMove(
      id: 15,
      level: 5,
      orderInLevel: 0,
      displayName: 'Left uppercut',
      description:
          'An upward punch thrown with your lead hand, traveling vertically. Devastating at close range. Dip slightly, then drive upward with your legs and hips.',
      moveCodes: ['5'],
    ),
    LearningMove(
      id: 16,
      level: 5,
      orderInLevel: 1,
      displayName: 'Right uppercut',
      description:
          'An upward punch with your rear hand. One of the most powerful close-range strikes. Bend your rear knee, then explosively drive upward while rotating your hips.',
      moveCodes: ['6'],
    ),

    // ========== LEVEL 6: Slipstream (3 moves) ==========
    LearningMove(
      id: 17,
      level: 6,
      orderInLevel: 0,
      displayName: 'Slip left',
      description:
          'A head movement that shifts your head to the left (outside) of an incoming punch. Move your head off the centerline while staying in punching range. Great for setting up counter punches.',
      moveCodes: ['E'],
    ),
    LearningMove(
      id: 18,
      level: 6,
      orderInLevel: 1,
      displayName: 'Slip right',
      description:
          'A head movement that shifts your head to the right (inside) of an incoming punch. Similar to slip left but moving to the inside. Perfect setup for left hooks.',
      moveCodes: ['G'],
    ),
    LearningMove(
      id: 19,
      level: 6,
      orderInLevel: 2,
      displayName: 'Duck',
      description:
          'A downward head movement that dips under horizontal punches like hooks. Bend your knees to lower your level while keeping your back relatively straight and eyes forward.',
      moveCodes: ['H'],
    ),

    // ========== LEVEL 7: Wave & Fade (3 moves) ==========
    LearningMove(
      id: 20,
      level: 7,
      orderInLevel: 0,
      displayName: 'Roll left',
      description:
          'A circular upper body movement that rotates under hooks and wide punches. Roll your shoulders and torso in a fluid motion, moving under the punch. Come up in position to counter.',
      moveCodes: ['I'],
    ),
    LearningMove(
      id: 21,
      level: 7,
      orderInLevel: 1,
      displayName: 'Roll right',
      description:
          'A circular upper body movement that rotates under hooks, moving from left to right. The mirror of roll left, used in combination for continuous defensive flow.',
      moveCodes: ['J'],
    ),
    LearningMove(
      id: 22,
      level: 7,
      orderInLevel: 2,
      displayName: 'Pull back',
      description:
          'Moving your upper body backward to create distance from an incoming punch. Shift your weight to your back leg while maintaining your guard and balance.',
      moveCodes: ['K'],
    ),

    // ========== LEVEL 8: Shield Wall (4 moves) ==========
    LearningMove(
      id: 23,
      level: 8,
      orderInLevel: 0,
      displayName: 'Parry',
      description:
          'A quick deflection of an incoming punch with your hand, redirecting it away from its target. More subtle than a full block, using timing and precision.',
      moveCodes: ['L'],
    ),
    LearningMove(
      id: 24,
      level: 8,
      orderInLevel: 1,
      displayName: 'Catch jab',
      description:
          'Catching an incoming jab with your rear hand, usually using an open glove to catch or parry. Advanced technique that allows immediate counters.',
      moveCodes: ['M'],
    ),
    LearningMove(
      id: 25,
      level: 8,
      orderInLevel: 2,
      displayName: 'Left centerline elbow block',
      description:
          'Using your left elbow to block straight punches or uppercuts aimed at your centerline/solar plexus. Brings your left elbow inward to cover your body.',
      moveCodes: ['N'],
    ),
    LearningMove(
      id: 26,
      level: 8,
      orderInLevel: 3,
      displayName: 'Right centerline elbow block',
      description:
          'Using your right elbow to block straight punches or uppercuts aimed at your centerline. Protects against body shots to the midsection.',
      moveCodes: ['O'],
    ),

    // ========== LEVEL 9: Deception Arts (2 moves) ==========
    LearningMove(
      id: 27,
      level: 9,
      orderInLevel: 0,
      displayName: 'Right overhand',
      description:
          'A looping power punch thrown over the opponent\'s guard. The overhand travels in a downward arc and can catch opponents off guard. Especially effective against taller opponents.',
      moveCodes: ['7'],
    ),
    LearningMove(
      id: 28,
      level: 9,
      orderInLevel: 1,
      displayName: 'Feint',
      description:
          'A deceptive movement that mimics the start of a strike without fully committing. Feints draw reactions from your opponent, create openings, and disrupt their rhythm.',
      moveCodes: ['F'],
    ),

    // ========== LEVEL 10: Footwork Fury (2 moves) ==========
    LearningMove(
      id: 29,
      level: 10,
      orderInLevel: 0,
      displayName: 'Shuffle forward',
      description:
          'A quick, short burst forward by pushing off your rear foot. Faster than a regular step, used to quickly close distance or add explosive power.',
      moveCodes: ['V'],
    ),
    LearningMove(
      id: 30,
      level: 10,
      orderInLevel: 1,
      displayName: 'Shuffle backward',
      description:
          'A quick, short burst backward by pushing off your lead foot. Used to rapidly create distance or avoid incoming attacks.',
      moveCodes: ['W'],
    ),

    // ========== LEVEL 11: Body Hunters (4 moves) ==========
    LearningMove(
      id: 31,
      level: 11,
      orderInLevel: 0,
      displayName: 'Left straight to body',
      description:
          'A straight punch to the body with the lead hand. Similar mechanics to a jab but aimed at the midsection. Used to attack the body while maintaining distance.',
      moveCodes: ['8'],
    ),
    LearningMove(
      id: 32,
      level: 11,
      orderInLevel: 1,
      displayName: 'Right straight to body',
      description:
          'A straight power punch to the body with the rear hand. Combines the distance of a cross with body attack. Dip slightly and rotate your hips as you drive straight into the midsection.',
      moveCodes: ['9'],
    ),
    LearningMove(
      id: 33,
      level: 11,
      orderInLevel: 2,
      displayName: 'Left body hook',
      description:
          'A hook to the body with the lead hand, typically targeting the opponent\'s liver or ribs. Dip slightly and drive the punch horizontally into the body.',
      moveCodes: ['10'],
    ),
    LearningMove(
      id: 34,
      level: 11,
      orderInLevel: 3,
      displayName: 'Right body hook',
      description:
          'A powerful hook to the body with the rear hand. Targets the opponent\'s midsection to break down their guard or slow their movement. Rotate your hips explosively.',
      moveCodes: ['11'],
    ),

    // ========== LEVEL 12: Shadow Weapons (3 moves) ==========
    LearningMove(
      id: 35,
      level: 12,
      orderInLevel: 0,
      displayName: 'Check hook',
      description:
          'A defensive lead hook thrown while pivoting away from pressure. Used to counter an opponent moving forward, creating separation while landing a power shot.',
      moveCodes: ['12'],
    ),
    LearningMove(
      id: 36,
      level: 12,
      orderInLevel: 1,
      displayName: 'Left shovel hook',
      description:
          'An upward-angled hook with the lead hand, between a hook and uppercut. Effective at close range for targeting the body or chin from an unusual angle.',
      moveCodes: ['13'],
    ),
    LearningMove(
      id: 37,
      level: 12,
      orderInLevel: 2,
      displayName: 'Right shovel hook',
      description:
          'An upward-angled hook with the rear hand. Combines the power of the rear hand with an upward trajectory, making it hard to see coming at close range.',
      moveCodes: ['14'],
    ),

    // NOTE: Circle left (X) and Circle right (Y) are not included in the Academy
    // learning path but are available in the full move library for Training Session.
  ];

  /// Returns the complete list of all learning moves in unlock order.
  static List<LearningMove> getAllMoves() => List.unmodifiable(_allMoves);

  /// Returns a learning move by its ID (1-38).
  ///
  /// Returns null if no move with the given ID exists.
  static LearningMove? getMoveById(int id) {
    try {
      return _allMoves.firstWhere((move) => move.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Returns all learning moves in a given level (1-12).
  ///
  /// Returns an empty list if the level number is invalid.
  static List<LearningMove> getMovesByLevel(int level) {
    return _allMoves.where((move) => move.level == level).toList();
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

  /// Returns the total number of levels.
  static const int totalLevels = 12;

  /// Returns the number of moves in a given level.
  ///
  /// Returns 0 if the level number is invalid.
  static int getMovesCountInLevel(int level) {
    return _allMoves.where((move) => move.level == level).length;
  }

  /// Returns the actual Move objects for a given LearningMove from the repository.
  ///
  /// A LearningMove can reference multiple move codes (e.g., old Rhythm variations used T and U).
  /// This method resolves all those codes to actual Move objects.
  ///
  /// Returns an empty list if no moves could be resolved.
  static List<Move> getActualMovesForLearningMove(
    LearningMove learningMove,
    MoveRepository repository,
  ) {
    final moves = <Move>[];
    for (final code in learningMove.moveCodes) {
      final move = repository.getMoveByCode(code);
      if (move != null) {
        moves.add(move);
      }
    }
    return moves;
  }

  /// Returns a map of LearningMove ID to its corresponding actual Move(s).
  ///
  /// For learning moves with single move codes, the list will have one item.
  /// For learning moves with multiple codes (if any), it will have multiple.
  static Map<int, List<Move>> getAllLearningMoveToActualMovesMap(
    MoveRepository repository,
  ) {
    final map = <int, List<Move>>{};
    for (final learningMove in _allMoves) {
      map[learningMove.id] = getActualMovesForLearningMove(learningMove, repository);
    }
    return map;
  }

  /// Returns all unique Move codes used in the learning path, in unlock order.
  ///
  /// This represents the complete set of moves that participate in Academy.
  static List<String> getAllMoveCodesInOrder() {
    final codes = <String>[];
    for (final learningMove in _allMoves) {
      codes.addAll(learningMove.moveCodes);
    }
    return codes;
  }

  /// Returns all unique actual Moves used in the learning path, in unlock order.
  ///
  /// This represents the complete set of Move objects that should appear in Academy.
  static List<Move> getAllActualMovesInOrder(MoveRepository repository) {
    final moves = <Move>[];
    for (final learningMove in _allMoves) {
      final actualMoves = getActualMovesForLearningMove(learningMove, repository);
      moves.addAll(actualMoves);
    }
    return moves;
  }
}
