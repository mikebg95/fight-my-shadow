import 'package:fight_my_shadow/models/move.dart';

/// The canonical list of all Boxing moves in the app.
///
/// This serves as the single source of truth for Boxing moves.
///
/// Structure:
/// - Moves 1-14: Punches (numeric codes 1-14)
/// - Moves 15-26: Defense (letter codes A-M, no F)
/// - Moves 27-37: Footwork (letter codes N-X)
///
/// Each move has:
/// - `id`: Unique identifier
/// - `code`: User-facing code for combinations (numbers or letters)
/// - `name`: Full descriptive name
/// - `category`: punch, defense, or footwork
/// - `discipline`: boxing
/// - `description`: Explanation of what the move is and how to execute it
/// - `tips`: Key coaching points and cues
final List<Move> boxingMoves = [
  // PUNCHES (NUMBERS 1-14)
  const Move(
    id: 1,
    code: '1',
    name: 'Left straight',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A quick, straight punch thrown with the lead hand (jab). The most fundamental strike in boxing, used for ranging, setting up combinations, and controlling distance. Extend your arm straight from your guard, rotating your fist so the palm faces down on impact.',
    tips: [
      'Keep your rear hand up to protect your chin',
      'Snap the punch out and back quickly',
      'Use it to measure distance and set up power shots',
      'Pivot your lead foot slightly for more reach',
    ],
  ),
  const Move(
    id: 2,
    code: '2',
    name: 'Right straight',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A powerful straight punch thrown with the rear hand (cross). One of the most powerful punches in boxing, generating force through hip and shoulder rotation. Pivot your rear foot and rotate your hips as you extend your arm straight toward the target.',
    tips: [
      'Rotate your hips and shoulders for maximum power',
      'Keep your chin tucked behind your lead shoulder',
      'Pivot on the ball of your rear foot',
      'Don\'t drop your rear hand before throwing',
    ],
  ),
  const Move(
    id: 3,
    code: '3',
    name: 'Left hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A curved punch thrown with the lead hand, traveling in a horizontal arc. The hook targets the side of your opponent\'s head or body. Keep your elbow at shoulder height and pivot your lead foot as you rotate your torso.',
    tips: [
      'Keep your elbow up at shoulder level',
      'Pivot your lead foot and rotate your hips',
      'Don\'t wind up or telegraph the punch',
      'Keep your rear hand protecting your chin',
    ],
  ),
  const Move(
    id: 4,
    code: '4',
    name: 'Right hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A curved punch thrown with the rear hand in a horizontal arc. Generate power by pivoting your rear foot and rotating your entire body into the punch. Often used as a counter or to finish combinations.',
    tips: [
      'Rotate your hips explosively',
      'Keep your arm bent at roughly 90 degrees',
      'Use your legs and core, not just your arm',
      'Great for countering jabs',
    ],
  ),
  const Move(
    id: 5,
    code: '5',
    name: 'Left uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward punch thrown with the lead hand, traveling vertically. Uppercuts are devastating at close range and can slip under an opponent\'s guard. Bend your knees slightly, then drive upward with your legs and hips.',
    tips: [
      'Dip slightly before throwing for more power',
      'Drive up with your legs and hips',
      'Keep it tight and compact at close range',
      'Works great after hooks or getting inside',
    ],
  ),
  const Move(
    id: 6,
    code: '6',
    name: 'Right uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward punch with the rear hand. One of the most powerful close-range strikes when executed properly. Bend your rear knee, then explosively drive upward while rotating your hips and shoulders.',
    tips: [
      'Load your rear leg before exploding upward',
      'Rotate your torso as you punch',
      'Excellent in close quarters',
      'Can be devastating to body or head',
    ],
  ),
  const Move(
    id: 7,
    code: '7',
    name: 'Left body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A hook to the body with the lead hand, typically targeting the opponent\'s liver or ribs. Dip slightly and drive the punch horizontally into the body with your knuckles pointing forward.',
    tips: [
      'Dip your level to get under their guard',
      'Rotate through the punch for penetration',
      'Target the soft spot below the ribs',
      'Can slow down aggressive opponents',
    ],
  ),
  const Move(
    id: 8,
    code: '8',
    name: 'Right body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A powerful hook to the body with the rear hand. Targets the opponent\'s midsection to break down their guard or slow their movement. Rotate your hips explosively and aim to punch through the target.',
    tips: [
      'Get your hip rotation into the punch',
      'Aim for solar plexus or ribs',
      'Keep your other hand up for defense',
    ],
  ),
  const Move(
    id: 9,
    code: '9',
    name: 'Left straight to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A straight punch to the body with the lead hand. Similar mechanics to a jab but aimed at the midsection. Used to attack the body while maintaining distance.',
  ),
  const Move(
    id: 10,
    code: '10',
    name: 'Right straight to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A straight power punch to the body with the rear hand. Combines the distance of a cross with body attack. Dip slightly and rotate your hips as you drive straight into the midsection.',
  ),
  const Move(
    id: 11,
    code: '11',
    name: 'Right overhand',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A looping power punch thrown over the opponent\'s guard. The overhand travels in a downward arc and can catch opponents off guard. Especially effective against taller opponents.',
    tips: [
      'Throw it in an arc over their guard',
      'Shift your weight forward',
      'Great for countering jabs',
    ],
  ),
  const Move(
    id: 12,
    code: '12',
    name: 'Check hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'A defensive lead hook thrown while pivoting away from pressure. Used to counter an opponent moving forward, creating separation while landing a power shot.',
  ),
  const Move(
    id: 13,
    code: '13',
    name: 'Left shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward-angled hook with the lead hand, between a hook and uppercut. Effective at close range for targeting the body or chin from an unusual angle.',
  ),
  const Move(
    id: 14,
    code: '14',
    name: 'Right shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
    description: 'An upward-angled hook with the rear hand. Combines the power of the rear hand with an upward trajectory, making it hard to see coming at close range.',
  ),

  // DEFENSE (LETTERS A-M, no F)
  const Move(
    id: 15,
    code: 'A',
    name: 'Slip left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A head movement that shifts your head to the left (outside) of an incoming punch. Move from your waist and knees, not just your neck. Essential for avoiding jabs and setting up counters.',
    tips: [
      'Bend at the waist, not just your neck',
      'Keep your eyes on your opponent',
      'Move just enough to avoid the punch',
      'Perfect setup for a right hand counter',
    ],
  ),
  const Move(
    id: 16,
    code: 'B',
    name: 'Slip right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A head movement that shifts your head to the right (inside) of an incoming punch. Similar mechanics to slip left but moving to the inside of the opponent\'s punch.',
    tips: [
      'Move from your core, not your neck',
      'Stay in position to counter immediately',
      'Keep your hands up while slipping',
      'Great for setting up left hooks',
    ],
  ),
  const Move(
    id: 17,
    code: 'C',
    name: 'Roll left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A circular upper body movement that rotates under hooks and wide punches. Roll your shoulders and torso in a fluid motion, moving under the punch from right to left.',
    tips: [
      'Use a smooth, circular motion',
      'Roll under hooks and wide shots',
      'Stay balanced throughout the movement',
      'Come up in position to counter',
    ],
  ),
  const Move(
    id: 18,
    code: 'D',
    name: 'Roll right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A circular upper body movement that rotates under hooks, moving from left to right. The mirror of roll left, used in combination for continuous defensive flow.',
  ),
  const Move(
    id: 19,
    code: 'E',
    name: 'Duck',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A downward head movement that dips under horizontal punches like hooks. Bend your knees to lower your level while keeping your back relatively straight and eyes forward.',
    tips: [
      'Bend your knees, don\'t lean over',
      'Keep your eyes on your opponent',
      'Don\'t stay low too long',
      'Great against hooks and wide shots',
    ],
  ),
  const Move(
    id: 20,
    code: 'G',
    name: 'Block straight left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your rear hand or glove to block or parry a straight left hand (jab). Position your glove to intercept or deflect the incoming punch.',
  ),
  const Move(
    id: 21,
    code: 'H',
    name: 'Pull back',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Moving your upper body backward to create distance from an incoming punch. Shift your weight to your back leg while maintaining your guard and balance.',
    tips: [
      'Stay balanced as you move back',
      'Keep your hands up',
      'Don\'t lean back too far',
      'Be ready to counter as they miss',
    ],
  ),
  const Move(
    id: 22,
    code: 'I',
    name: 'Block straight right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Using your lead hand to block or parry an incoming straight right (cross). Essential for protecting against power punches.',
  ),
  const Move(
    id: 23,
    code: 'J',
    name: 'Block left hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Raising your rear hand/arm to block an incoming left hook to the head. Keep your elbow up and your glove covering the side of your head.',
  ),
  const Move(
    id: 24,
    code: 'K',
    name: 'Block right hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Raising your lead hand/arm to block an incoming right hook. Position your arm to absorb the impact on your glove and forearm.',
  ),
  const Move(
    id: 25,
    code: 'L',
    name: 'Catch jab',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'Catching an incoming jab with your rear hand, usually using an open glove to catch or parry. Advanced technique that allows immediate counters.',
    tips: [
      'Time it precisely',
      'Use it to set up your own punches',
      'Don\'t reach too far forward',
    ],
  ),
  const Move(
    id: 26,
    code: 'M',
    name: 'Parry',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
    description: 'A quick deflection of an incoming punch with your hand, redirecting it away from its target. More subtle than a full block, using timing and precision.',
    tips: [
      'Small, quick hand movements',
      'Redirect, don\'t try to stop the punch',
      'Creates openings for counters',
    ],
  ),

  // FOOTWORK (LETTERS N-X)
  const Move(
    id: 27,
    code: 'N',
    name: 'Step in',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Moving forward by stepping with your lead foot first, then following with your rear foot. Used to close distance, cut off the ring, or add power to your punches.',
    tips: [
      'Lead foot moves first',
      'Keep your stance width',
      'Stay balanced as you advance',
      'Use it to pressure your opponent',
    ],
  ),
  const Move(
    id: 28,
    code: 'O',
    name: 'Step back',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Moving backward by stepping with your rear foot first, then following with your lead foot. Essential for creating distance and avoiding pressure.',
    tips: [
      'Rear foot moves first',
      'Maintain your stance',
      'Don\'t backpedal straight back repeatedly',
      'Stay ready to counter',
    ],
  ),
  const Move(
    id: 29,
    code: 'P',
    name: 'Step left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Lateral movement to the left. Move your lead foot first, then follow with your rear foot. Used to circle, create angles, and avoid being cornered.',
  ),
  const Move(
    id: 30,
    code: 'Q',
    name: 'Step right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Lateral movement to the right. Move your rear foot first, then follow with your lead foot. Essential for ring generalship and angle creation.',
  ),
  const Move(
    id: 31,
    code: 'R',
    name: 'Pivot left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Rotating on your lead foot to turn left, repositioning yourself at an angle. Excellent for escaping pressure or getting off the center line.',
    tips: [
      'Pivot on the ball of your lead foot',
      'Swing your rear leg around',
      'Creates new angles immediately',
      'Great for avoiding being cornered',
    ],
  ),
  const Move(
    id: 32,
    code: 'S',
    name: 'Pivot right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Rotating on your rear foot to turn right. Used to reposition and create angles when moving away from pressure.',
  ),
  const Move(
    id: 33,
    code: 'T',
    name: 'Shuffle forward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'A quick, short burst forward by pushing off your rear foot. Faster than a regular step, used to quickly close distance or add explosive power.',
  ),
  const Move(
    id: 34,
    code: 'U',
    name: 'Shuffle backward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'A quick, short burst backward by pushing off your lead foot. Used to rapidly create distance or avoid incoming attacks.',
  ),
  const Move(
    id: 35,
    code: 'V',
    name: 'Circle left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Continuous lateral movement to the left in a circular pattern. Used to keep moving and create angles while staying out of range.',
  ),
  const Move(
    id: 36,
    code: 'W',
    name: 'Circle right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Continuous lateral movement to the right. Orthodox boxers typically circle away from the opponent\'s power hand.',
  ),
  const Move(
    id: 37,
    code: 'X',
    name: 'Switch stance',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
    description: 'Quickly switching your stance from orthodox to southpaw or vice versa. A quick hop that exchanges your lead and rear foot positions. Used to confuse opponents or set up different angles.',
    tips: [
      'Keep it quick and explosive',
      'Maintain your guard during the switch',
      'Can set up unexpected punches',
      'Use to change angles',
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

/// Get a move by its code string (works for both numbers and letters).
///
/// Example:
/// ```dart
/// final jab = getMoveByCode('1');     // Returns Move(id: 1, name: "Left straight")
/// final slipLeft = getMoveByCode('A'); // Returns Move(id: 15, name: "Slip left")
/// ```
Move? getMoveByCode(String code) {
  try {
    return boxingMoves.firstWhere((move) => move.code == code);
  } catch (e) {
    return null;
  }
}

/// Get all moves of a specific category.
///
/// Example:
/// ```dart
/// final punches = getMovesByCategory(MoveCategory.punch);    // Returns moves 1-14
/// final defense = getMovesByCategory(MoveCategory.defense);  // Returns moves A-M
/// final footwork = getMovesByCategory(MoveCategory.footwork); // Returns moves N-X
/// ```
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

/// Total number of Boxing moves.
int get totalMoves => boxingMoves.length;
