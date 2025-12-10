import 'package:fight_my_shadow/models/move.dart';

/// The canonical list of all predefined moves in the app.
///
/// This serves as the single source of truth for the 23 core moves
/// used in kickboxing/Muay Thai combinations.
///
/// Structure:
/// - Moves 1-11: Hand techniques (punches)
/// - Moves 12-13: Guard manipulation (other)
/// - Moves 14-21: Kicks
/// - Moves 22-23: Feints and footwork (other)
///
/// Each move has:
/// - `id`: Unique identifier (1-23)
/// - `code`: String representation of the ID for combo notation (1-21, F, S)
/// - `name`: Full descriptive name
/// - `category`: Classification (punch, kick, other)
/// - `description`: Explanation of the move and basic execution
/// - `tips`: Optional coaching cues and key points
final List<Move> allMoves = [
  // PUNCHES (1-11)
  const Move(
    id: 1,
    code: '1',
    name: 'Left straight (jab)',
    category: MoveCategory.punch,
    description: 'A quick, straight punch thrown with the lead hand. The jab is the most fundamental strike in boxing and kickboxing, used for ranging, setting up combinations, and disrupting your opponent\'s rhythm. Extend your arm straight forward from your guard, rotating your fist so the palm faces down on impact.',
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
    name: 'Right straight (cross)',
    category: MoveCategory.punch,
    description: 'A powerful straight punch thrown with the rear hand across your body. The cross is one of the most powerful punches in boxing, generating force through hip and shoulder rotation. Pivot your rear foot and rotate your hips as you extend your arm straight toward the target.',
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
    description: 'A curved punch thrown with the lead hand, traveling in a horizontal arc. The hook targets the side of your opponent\'s head or body. Keep your elbow at shoulder height and pivot your lead foot as you rotate your torso, generating power from your hips and core.',
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
    description: 'A curved punch thrown with the rear hand in a horizontal arc. Similar to the lead hook but with different mechanics due to the rear hand position. Generate power by pivoting your rear foot and rotating your entire body into the punch.',
    tips: [
      'Rotate your hips explosively',
      'Keep your arm bent at roughly 90 degrees',
      'Don\'t drop your hand before throwing',
      'Use your legs and core, not just your arm',
    ],
  ),
  const Move(
    id: 5,
    code: '5',
    name: 'Left uppercut',
    category: MoveCategory.punch,
    description: 'An upward punch thrown with the lead hand, traveling vertically from a lowered position. Uppercuts are devastating at close range and can slip under an opponent\'s guard. Bend your knees slightly, then drive upward with your legs and hips as you punch.',
    tips: [
      'Dip slightly before throwing for more power',
      'Drive up with your legs and hips',
      'Keep it tight and compact at close range',
      'Great for following hooks or getting inside',
    ],
  ),
  const Move(
    id: 6,
    code: '6',
    name: 'Right uppercut',
    category: MoveCategory.punch,
    description: 'An upward punch thrown with the rear hand, traveling vertically upward. One of the most powerful close-range strikes when executed properly. Bend your rear knee, then explosively drive upward while rotating your hips and shoulders.',
    tips: [
      'Load your rear leg before exploding upward',
      'Rotate your torso as you punch',
      'Works great in close quarters',
      'Can be devastating to the body or head',
    ],
  ),
  const Move(
    id: 7,
    code: '7',
    name: 'Left body hook (liver shot)',
    category: MoveCategory.punch,
    description: 'A hook to the body with the lead hand, typically targeting the opponent\'s liver on their right side. This is one of the most fight-ending shots in combat sports. Dip slightly and drive the punch horizontally into the body with your knuckles pointing forward.',
    tips: [
      'Target the soft spot below the ribs',
      'Dip your level to get under their guard',
      'Rotate through the punch for penetration',
      'Can end a fight instantly if landed clean',
    ],
  ),
  const Move(
    id: 8,
    code: '8',
    name: 'Right body hook',
    category: MoveCategory.punch,
    description: 'A powerful hook to the body with the rear hand. Targets the opponent\'s midsection and can break down their guard or slow their movement. Rotate your hips explosively and aim to punch through the target, not just at it.',
    tips: [
      'Get your hip rotation into the punch',
      'Aim for the solar plexus or ribs',
      'Keep your other hand up for defense',
      'Great for slowing down aggressive opponents',
    ],
  ),
  const Move(
    id: 9,
    code: '9',
    name: 'Left straight to body (jab)',
    category: MoveCategory.punch,
    description: 'A straight punch to the body with the lead hand. Similar mechanics to a regular jab but aimed at the midsection. Used to attack the body while maintaining distance and can set up head punches effectively.',
    tips: [
      'Dip slightly to change levels',
      'Keep it straight and fast',
      'Use it to attack the body from distance',
      'Great for opening up head shots',
    ],
  ),
  const Move(
    id: 10,
    code: '10',
    name: 'Right straight to body (cross)',
    category: MoveCategory.punch,
    description: 'A straight power punch to the body with the rear hand. Combines the distance of a cross with body attack. Dip your level slightly and rotate your hips as you drive the punch straight into the opponent\'s midsection.',
    tips: [
      'Rotate your hips for power',
      'Change levels to get under their guard',
      'Can take the wind out of opponents',
      'Follow up with head shots as they bend',
    ],
  ),
  const Move(
    id: 11,
    code: '11',
    name: 'Right overhand',
    category: MoveCategory.punch,
    description: 'A looping power punch thrown with the rear hand over the top of the opponent\'s guard. The overhand travels in a downward arc and can catch opponents off guard. Especially effective against taller opponents or those with a high guard.',
    tips: [
      'Throw it in an arc over their guard',
      'Shift your weight forward as you punch',
      'Great for countering jabs',
      'Don\'t telegraph by winding up',
    ],
  ),

  // GUARD MANIPULATION (12-13)
  const Move(
    id: 12,
    code: '12',
    name: 'Pull down guard (left)',
    category: MoveCategory.other,
    description: 'A technique where you pull down your opponent\'s left hand/guard to create an opening. Grab or push their glove down with your lead hand, immediately creating space for a follow-up strike to their now-exposed head.',
    tips: [
      'Quickly pull and immediately strike',
      'Usually followed by an overhand or hook',
      'Timing is crucial',
      'Don\'t hold on - pull and release',
    ],
  ),
  const Move(
    id: 13,
    code: '13',
    name: 'Pull down guard (right)',
    category: MoveCategory.other,
    description: 'A technique where you pull down your opponent\'s right hand/guard to create an opening. Similar to the left guard pull but targeting their rear hand, which can expose their chin for powerful rear hand shots.',
    tips: [
      'Use your rear hand to pull their rear guard',
      'Create opening for lead hooks',
      'Quick execution is key',
      'Common in clinch range',
    ],
  ),

  // KICKS (14-21)
  const Move(
    id: 14,
    code: '14',
    name: 'Left low kick (inside)',
    category: MoveCategory.kick,
    description: 'A powerful roundhouse kick to the inside of the opponent\'s lead leg with your lead leg. Targets the inner thigh and calf. Step out slightly at an angle, pivot on your support foot, and swing your shin through the target with hip rotation.',
    tips: [
      'Step out at an angle first',
      'Turn your hips over completely',
      'Strike with your shin, not your foot',
      'Keep your hands up for balance and defense',
    ],
  ),
  const Move(
    id: 15,
    code: '15',
    name: 'Right low kick',
    category: MoveCategory.kick,
    description: 'A devastating roundhouse kick to the opponent\'s lead leg with your rear leg. The low kick is one of the most effective strikes in Muay Thai and kickboxing, capable of immobilizing opponents over time. Pivot on your lead foot and rotate your hips through the kick, striking with your shin.',
    tips: [
      'Pivot your standing foot away',
      'Rotate your hips all the way through',
      'Strike through the target',
      'Accumulative damage is the goal',
    ],
  ),
  const Move(
    id: 16,
    code: '16',
    name: 'Left teep/push kick',
    category: MoveCategory.kick,
    description: 'A straight pushing kick with the lead leg, similar to a front kick. The teep is a versatile tool used for maintaining distance, off-balancing opponents, and setting up other strikes. Lift your knee and thrust your foot forward, pushing through with your heel or ball of your foot.',
    tips: [
      'Keep it straight and fast',
      'Use it to control distance',
      'Can target body, thighs, or face',
      'Great for interrupting opponent\'s rhythm',
    ],
  ),
  const Move(
    id: 17,
    code: '17',
    name: 'Right push kick',
    category: MoveCategory.kick,
    description: 'A straight pushing kick with the rear leg. More powerful than the lead teep due to the longer distance and hip drive. Excellent for creating space, stopping forward pressure, or setting up punching combinations.',
    tips: [
      'Drive through with your hips',
      'Push them back, don\'t just tap',
      'Works well after punch combinations',
      'Keep your hands ready to follow up',
    ],
  ),
  const Move(
    id: 18,
    code: '18',
    name: 'Left body kick',
    category: MoveCategory.kick,
    description: 'A roundhouse kick to the body/ribs with the lead leg. Targets the opponent\'s torso with a horizontal kick. Though less powerful than the rear kick, it\'s faster and can catch opponents by surprise. Rotate your hips and strike with your shin.',
    tips: [
      'Aim for the floating ribs or liver',
      'Faster than rear kicks',
      'Keep your hands up',
      'Good for switching levels from punches',
    ],
  ),
  const Move(
    id: 19,
    code: '19',
    name: 'Right body kick',
    category: MoveCategory.kick,
    description: 'A powerful roundhouse kick to the body/ribs with the rear leg. One of the most powerful strikes in kickboxing and Muay Thai. Pivot your lead foot, swing your rear leg in a wide arc, and drive your shin through the opponent\'s ribs or liver.',
    tips: [
      'Full hip rotation for maximum power',
      'Strike through, not at the target',
      'Can break ribs if landed clean',
      'Set it up with punches first',
    ],
  ),
  const Move(
    id: 20,
    code: '20',
    name: 'Left head kick',
    category: MoveCategory.kick,
    description: 'A high roundhouse kick targeting the opponent\'s head with your lead leg. Requires good flexibility and timing. When landed, it can be a fight-ender. Chamber your knee high, pivot your base foot, and rotate your hip to whip your shin toward their head.',
    tips: [
      'Requires good flexibility',
      'Set it up with low attacks first',
      'Faster but less powerful than rear head kick',
      'High risk, high reward',
    ],
  ),
  const Move(
    id: 21,
    code: '21',
    name: 'Right head kick',
    category: MoveCategory.kick,
    description: 'The most spectacular and powerful kick in striking arts. A high roundhouse kick to the opponent\'s head with the rear leg. Requires excellent technique, timing, and setup. When landed cleanly, often results in a knockout. Chamber high, pivot completely, and rotate your entire body through the kick.',
    tips: [
      'Must be set up properly',
      'Full body rotation is essential',
      'Can knock opponents out cold',
      'Practice flexibility and balance first',
    ],
  ),

  // FEINTS AND FOOTWORK (22-23)
  const Move(
    id: 22,
    code: 'F',
    name: 'Feint',
    category: MoveCategory.other,
    description: 'A deceptive movement that mimics the start of a strike without fully committing. Feints are used to draw reactions from your opponent, create openings, or disrupt their rhythm. Start the motion of a punch or kick, but pull it back before completing, then attack the opening they create when reacting.',
    tips: [
      'Make it look realistic',
      'Watch for their reaction',
      'Immediately capitalize on openings',
      'Mix real and fake strikes',
    ],
  ),
  const Move(
    id: 23,
    code: 'S',
    name: 'Switch',
    category: MoveCategory.other,
    description: 'A quick stance switch where you hop and exchange your lead and rear foot positions. The switch is used to set up rear leg kicks from the front position, confuse opponents, or adjust angles. Execute with a small hop, landing with your opposite foot forward.',
    tips: [
      'Keep it quick and explosive',
      'Often used before rear kicks',
      'Maintains your guard during transition',
      'Can be used to change angles',
    ],
  ),
];

/// Get a move by its unique ID.
///
/// Returns the [Move] if found, or `null` if no move with that ID exists.
///
/// Example:
/// ```dart
/// final jab = getMoveById(1);  // Returns Move(id: 1, name: "Left straight (jab)", ...)
/// ```
Move? getMoveById(int id) {
  try {
    return allMoves.firstWhere((move) => move.id == id);
  } catch (e) {
    return null;
  }
}

/// Get a move by its code string.
///
/// Returns the [Move] if found, or `null` if no move with that code exists.
///
/// Example:
/// ```dart
/// final cross = getMoveByCode('2');  // Returns Move(id: 2, name: "Right straight (cross)", ...)
/// final feint = getMoveByCode('F');  // Returns Move(id: 22, name: "Feint", ...)
/// ```
Move? getMoveByCode(String code) {
  try {
    return allMoves.firstWhere((move) => move.code == code);
  } catch (e) {
    return null;
  }
}

/// Get all moves of a specific category.
///
/// Returns a list of all moves that match the given [category].
///
/// Example:
/// ```dart
/// final punches = getMovesByCategory(MoveCategory.punch);  // Returns moves 1-11
/// final kicks = getMovesByCategory(MoveCategory.kick);     // Returns moves 14-21
/// ```
List<Move> getMovesByCategory(MoveCategory category) {
  return allMoves.where((move) => move.category == category).toList();
}

/// Get all punches (moves 1-11).
///
/// Convenience method for retrieving all punch moves.
List<Move> getAllPunches() {
  return getMovesByCategory(MoveCategory.punch);
}

/// Get all kicks (moves 14-21).
///
/// Convenience method for retrieving all kick moves.
List<Move> getAllKicks() {
  return getMovesByCategory(MoveCategory.kick);
}

/// Get all moves in a specific ID range.
///
/// Useful for creating combinations with limited move sets.
///
/// Example:
/// ```dart
/// final basicMoves = getMovesInRange(1, 6);  // Jab, cross, hooks, uppercuts
/// ```
List<Move> getMovesInRange(int startId, int endId) {
  return allMoves
      .where((move) => move.id >= startId && move.id <= endId)
      .toList();
}

/// Total number of predefined moves.
int get totalMoves => allMoves.length;
