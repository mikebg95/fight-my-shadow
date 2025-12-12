import 'package:fight_my_shadow/models/move.dart';

/// The canonical list of all 39 Boxing moves in the app, ordered by Academy curriculum.
///
/// This serves as the single source of truth for Boxing moves.
///
/// Structure (in Academy learning order):
/// - Punches: codes 1-14 (numeric)
/// - Defense: codes A-E, G-O (letters, skips F)
/// - Footwork: codes P-Y (letters)
/// - Deception: code F (letter)
///
/// Each move has:
/// - `id`: Unique identifier (1-39)
/// - `code`: User-facing code for combinations
/// - `name`: Full descriptive name
/// - `category`: punch, defense, footwork, or deception
/// - `discipline`: boxing
/// - `description`: Explanation of what the move is and how to execute it
/// - `tips`: Key coaching points and cues
final List<Move> boxingMoves = [
  // ========== PUNCHES (CODES 1-14, IN ACADEMY ORDER) ==========

  // Level 1: Foundation Fists - Punches
  const Move(
    id: 1,
    code: '1',
    name: 'Jab',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A quick, straight punch thrown with the lead hand (jab). The most fundamental strike in boxing, used for ranging, setting up combinations, and controlling distance.',
    tips: [
      'Keep your rear hand up to protect your chin',
      'Snap the punch out and back quickly',
      'Use it to measure distance',
    ],
  ),
  const Move(
    id: 2,
    code: '2',
    name: 'Cross',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A powerful straight punch thrown with the rear hand (cross). Generates force through hip and shoulder rotation.',
    tips: [
      'Rotate your hips and shoulders for power',
      'Keep your chin tucked',
      'Pivot on the ball of your rear foot',
    ],
  ),

  // Level 3: Hook City - Punches
  const Move(
    id: 3,
    code: '3',
    name: 'Left hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A curved punch thrown with the lead hand, traveling in a horizontal arc. Keep your elbow at shoulder level.',
    tips: [
      'Keep your elbow up at shoulder level',
      'Pivot your lead foot and rotate your hips',
      'Don\'t wind up',
    ],
  ),
  const Move(
    id: 4,
    code: '4',
    name: 'Right hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A curved punch thrown with the rear hand. Generate power by pivoting your rear foot and rotating your body.',
    tips: [
      'Rotate your hips explosively',
      'Keep your arm bent at roughly 90 degrees',
      'Use your legs and core',
    ],
  ),

  // Level 5: Uppercut Engine - Punches
  const Move(
    id: 5,
    code: '5',
    name: 'Left uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward punch thrown with the lead hand. Devastating at close range. Drive upward with your legs and hips.',
    tips: [
      'Dip slightly before throwing',
      'Drive up with your legs and hips',
      'Keep it tight at close range',
    ],
  ),
  const Move(
    id: 6,
    code: '6',
    name: 'Right uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward punch with the rear hand. Bend your rear knee, then explosively drive upward.',
    tips: [
      'Load your rear leg before exploding',
      'Rotate your torso as you punch',
      'Excellent in close quarters',
    ],
  ),

  // Level 9: Deception Arts - Punches
  const Move(
    id: 7,
    code: '7',
    name: 'Right overhand',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A looping power punch thrown over the opponent\'s guard. Travels in a downward arc.',
    tips: [
      'Throw it over their guard',
      'Dip slightly to the side',
      'Especially effective against taller opponents',
    ],
  ),

  // Level 11: Body Hunters - Punches
  const Move(
    id: 8,
    code: '8',
    name: 'Jab to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A straight punch to the body with the lead hand. Similar mechanics to a jab but aimed at the midsection.',
    tips: [
      'Dip slightly to get under guard',
      'Drive straight into the body',
      'Maintains distance while attacking body',
    ],
  ),
  const Move(
    id: 9,
    code: '9',
    name: 'Cross to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A straight power punch to the body with the rear hand. Rotate your hips as you drive into the midsection.',
    tips: [
      'Dip slightly',
      'Rotate your hips fully',
      'Aim for solar plexus',
    ],
  ),
  const Move(
    id: 10,
    code: '10',
    name: 'Left body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A hook to the body with the lead hand, targeting the liver or ribs. Dip and drive horizontally.',
    tips: [
      'Dip your level',
      'Rotate through the punch',
      'Target the soft spot below the ribs',
    ],
  ),
  const Move(
    id: 11,
    code: '11',
    name: 'Right body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A hook to the body with the rear hand. Targets the midsection with explosive hip rotation.',
    tips: [
      'Drop your level',
      'Rotate hips explosively',
      'Keep rear hand protection',
    ],
  ),

  // Level 12: Shadow Weapons - Punches
  const Move(
    id: 12,
    code: '12',
    name: 'Check hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A defensive lead hook thrown while pivoting away from pressure. Creates separation while landing a power shot.',
    tips: [
      'Pivot away as you throw',
      'Use it when opponent rushes in',
      'Creates distance and angles',
    ],
  ),
  const Move(
    id: 13,
    code: '13',
    name: 'Left shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward-angled hook with the lead hand, between a hook and uppercut. Effective at close range.',
    tips: [
      'Angle upward at 45 degrees',
      'Works great in phone booth range',
      'Hard to see coming',
    ],
  ),
  const Move(
    id: 14,
    code: '14',
    name: 'Right shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward-angled hook with the rear hand. Combines power with unusual trajectory.',
    tips: [
      'Upward angle trajectory',
      'Explosive from close range',
      'Targets body or chin',
    ],
  ),

  // ========== DEFENSE (CODES A-N, IN ACADEMY ORDER) ==========

  // Level 2: Rails & Shields - Defense
  const Move(
    id: 15,
    code: 'A',
    name: 'Block straight left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your rear hand to block a straight left hand (jab). Position your glove to intercept or deflect.',
    tips: [
      'Keep your elbow tucked',
      'Don\'t reach too far',
      'Stay ready to counter',
    ],
  ),
  const Move(
    id: 16,
    code: 'B',
    name: 'Block straight right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your lead hand to block an incoming straight right (cross). Essential for protecting against power punches.',
    tips: [
      'Keep your hand high',
      'Tuck your elbow',
      'Counter immediately',
    ],
  ),

  // Level 3: Hook City - Defense
  const Move(
    id: 17,
    code: 'C',
    name: 'Block left hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Raising your rear hand/arm to block an incoming left hook to the head. Keep your elbow up.',
    tips: [
      'Raise your elbow to ear level',
      'Keep glove covering side of head',
      'Maintain tight guard',
    ],
  ),
  const Move(
    id: 18,
    code: 'D',
    name: 'Block right hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Raising your lead hand/arm to block an incoming right hook. Position to absorb impact on glove and forearm.',
    tips: [
      'Raise lead arm high',
      'Tuck elbow tight',
      'Keep rear hand protecting chin',
    ],
  ),

  // Level 6: Slipstream - Defense
  const Move(
    id: 19,
    code: 'E',
    name: 'Slip left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A head movement that shifts your head to the left (outside) of an incoming punch. Stay in punching range.',
    tips: [
      'Move your head, not your feet',
      'Stay in range to counter',
      'Bend at the waist',
    ],
  ),
  const Move(
    id: 20,
    code: 'G',
    name: 'Slip right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A head movement that shifts your head to the right (inside) of an incoming punch. Perfect setup for left hooks.',
    tips: [
      'Slip to the inside',
      'Great setup for counters',
      'Keep your hands up',
    ],
  ),
  const Move(
    id: 21,
    code: 'H',
    name: 'Duck',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A downward head movement that dips under horizontal punches. Bend your knees while keeping eyes forward.',
    tips: [
      'Bend your knees',
      'Keep your back relatively straight',
      'Eyes always on opponent',
    ],
  ),

  // Level 7: Wave & Fade - Defense
  const Move(
    id: 22,
    code: 'I',
    name: 'Roll left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A circular upper body movement that rotates under hooks. Roll your shoulders in a fluid motion.',
    tips: [
      'Roll shoulders and torso',
      'Move under the punch',
      'Come up ready to counter',
    ],
  ),
  const Move(
    id: 23,
    code: 'J',
    name: 'Roll right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A circular upper body movement to the right. Mirror of roll left for continuous defensive flow.',
    tips: [
      'Fluid circular motion',
      'Can chain with roll left',
      'Maintain balance',
    ],
  ),
  const Move(
    id: 24,
    code: 'K',
    name: 'Pull back',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Moving your upper body backward to create distance from an incoming punch. Shift weight to back leg.',
    tips: [
      'Lean back from the waist',
      'Maintain your guard',
      'Keep balance',
    ],
  ),

  // Level 8: Shield Wall - Defense
  const Move(
    id: 25,
    code: 'L',
    name: 'Parry',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A quick deflection of an incoming punch with your hand, redirecting it. Uses timing and precision.',
    tips: [
      'Small, quick hand movements',
      'Redirect, don\'t stop the punch',
      'Creates openings for counters',
    ],
  ),
  const Move(
    id: 26,
    code: 'M',
    name: 'Catch jab',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Catching an incoming jab with your rear hand. Advanced technique allowing immediate counters.',
    tips: [
      'Open glove to catch',
      'Requires good timing',
      'Sets up instant counters',
    ],
  ),
  const Move(
    id: 27,
    code: 'N',
    name: 'Left centerline elbow block',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your left elbow to block punches aimed at your centerline. Brings elbow inward to cover body.',
    tips: [
      'Tuck elbow to centerline',
      'Protects solar plexus',
      'Keep hands high',
    ],
  ),
  const Move(
    id: 28,
    code: 'O',
    name: 'Right centerline elbow block',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your right elbow to block punches aimed at your centerline. Protects against body shots.',
    tips: [
      'Bring elbow inward',
      'Covers midsection',
      'Maintain high guard',
    ],
  ),

  // ========== FOOTWORK (CODES O-Y, IN ACADEMY ORDER) ==========

  // Level 1: Foundation Fists - Footwork
  const Move(
    id: 29,
    code: 'P',
    name: 'Step in',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Moving forward by stepping with your lead foot first. Used to close distance and add power.',
    tips: [
      'Lead foot moves first',
      'Keep your stance width',
      'Stay balanced',
    ],
  ),
  const Move(
    id: 30,
    code: 'Q',
    name: 'Step back',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Moving backward by stepping with your rear foot first. Essential for creating distance.',
    tips: [
      'Rear foot moves first',
      'Maintain your stance',
      'Stay ready to counter',
    ],
  ),

  // Level 2: Rails & Shields - Footwork
  const Move(
    id: 31,
    code: 'R',
    name: 'Step left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Lateral movement to the left. Move lead foot first. Used to circle and create angles.',
    tips: [
      'Lead foot first',
      'Keep stance width',
      'Circle to create angles',
    ],
  ),
  const Move(
    id: 32,
    code: 'S',
    name: 'Step right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Lateral movement to the right. Move rear foot first. Essential for ring generalship.',
    tips: [
      'Rear foot first',
      'Maintain stance',
      'Control the ring',
    ],
  ),

  // Level 4: Turn the Corner - Footwork
  const Move(
    id: 33,
    code: 'T',
    name: 'Pivot left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Rotating on your lead foot to turn left. Excellent for escaping pressure.',
    tips: [
      'Pivot on ball of lead foot',
      'Swing rear leg around',
      'Creates new angles',
    ],
  ),
  const Move(
    id: 34,
    code: 'U',
    name: 'Pivot right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Rotating on your rear foot to turn right. Used to reposition and create angles.',
    tips: [
      'Pivot on ball of rear foot',
      'Turn body with pivot',
      'Escape pressure',
    ],
  ),

  // Level 10: Footwork Fury - Footwork
  const Move(
    id: 35,
    code: 'V',
    name: 'Shuffle forward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'A quick burst forward by pushing off your rear foot. Faster than a regular step.',
    tips: [
      'Explosive push off',
      'Closes distance quickly',
      'Adds power to punches',
    ],
  ),
  const Move(
    id: 36,
    code: 'W',
    name: 'Shuffle backward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'A quick burst backward by pushing off your lead foot. Rapidly creates distance.',
    tips: [
      'Push off lead foot',
      'Creates distance fast',
      'Avoid incoming attacks',
    ],
  ),

  // Not in Academy - Additional footwork
  const Move(
    id: 37,
    code: 'X',
    name: 'Circle left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Continuous lateral movement to the left in a circular pattern. Keeps you moving and creates angles.',
    tips: [
      'Maintain circular motion',
      'Stay out of range',
      'Create angles constantly',
    ],
  ),
  const Move(
    id: 38,
    code: 'Y',
    name: 'Circle right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Continuous lateral movement to the right. Orthodox boxers circle away from power hand.',
    tips: [
      'Circle away from power',
      'Stay mobile',
      'Control distance',
    ],
  ),

  // ========== DECEPTION (CODE F) ==========

  // Level 9: Deception Arts - Deception
  const Move(
    id: 39,
    code: 'F',
    name: 'Feint',
    category: MoveCategory.deception,
    discipline: Discipline.boxing,
    description: 'A deceptive movement mimicking a strike without committing. Draws reactions and creates openings.',
    tips: [
      'Make it look real',
      'Watch for their reaction',
      'Create openings',
    ],
  ),
];

/// Get a move by its unique ID.
Move? getMoveById(int id) {
  try {
    return boxingMoves.firstWhere((move) => move.id == id);
  } catch (e) {
    return null;
  }
}

/// Get a move by its code string.
Move? getMoveByCode(String code) {
  try {
    return boxingMoves.firstWhere((move) => move.code == code);
  } catch (e) {
    return null;
  }
}

/// Get all moves of a specific category.
List<Move> getMovesByCategory(MoveCategory category) {
  return boxingMoves.where((move) => move.category == category).toList();
}

/// Get all moves for a specific discipline.
List<Move> getMovesByDiscipline(Discipline discipline) {
  return boxingMoves.where((move) => move.discipline == discipline).toList();
}

/// Get all punches.
List<Move> getAllPunches() {
  return getMovesByCategory(MoveCategory.punch);
}

/// Get all defense moves.
List<Move> getAllDefense() {
  return getMovesByCategory(MoveCategory.defense);
}

/// Get all footwork moves.
List<Move> getAllFootwork() {
  return getMovesByCategory(MoveCategory.footwork);
}

/// Get all deception moves.
List<Move> getAllDeception() {
  return getMovesByCategory(MoveCategory.deception);
}

/// Total number of Boxing moves.
int get totalMoves => boxingMoves.length;

/// Returns all moves ordered by Academy learning path.
///
/// Moves are already in Academy order in the boxingMoves list.
/// This function simply returns them in that order.
List<Move> getMovesInAcademyOrder() {
  // First return all moves that are part of Academy (first 37 in list)
  // Then append the two that aren't (Circle left/right)
  final academyMoves = boxingMoves.sublist(0, 37);
  final nonAcademyMoves = boxingMoves.sublist(37);
  return [...academyMoves, ...nonAcademyMoves];
}
