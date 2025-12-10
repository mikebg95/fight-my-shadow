import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/data/boxing_moves_data.dart' as boxing_data;

/// Abstract interface for accessing Move data.
///
/// Provides a clean, stable API for retrieving moves throughout the app.
/// Different implementations can provide data from various sources
/// (in-memory, JSON, database, network) without changing calling code.
abstract class MoveRepository {
  /// Returns all available moves.
  List<Move> getAllMoves();

  /// Gets a move by its unique ID.
  ///
  /// Returns the [Move] if found, or `null` if no move with that ID exists.
  ///
  /// Example:
  /// ```dart
  /// final jab = repository.getMoveById(1);
  /// ```
  Move? getMoveById(int id);

  /// Gets a move by its code string (works for numbers and letters).
  ///
  /// Example:
  /// ```dart
  /// final jab = repository.getMoveByCode('1');
  /// final slipLeft = repository.getMoveByCode('A');
  /// ```
  Move? getMoveByCode(String code);

  /// Gets all moves of a specific category.
  ///
  /// Example:
  /// ```dart
  /// final punches = repository.getMovesByCategory(MoveCategory.punch);
  /// final defense = repository.getMovesByCategory(MoveCategory.defense);
  /// ```
  List<Move> getMovesByCategory(MoveCategory category);

  /// Gets all punch moves (convenience method).
  List<Move> getAllPunches();

  /// Gets all defense moves (convenience method).
  List<Move> getAllDefense();

  /// Gets all footwork moves (convenience method).
  List<Move> getAllFootwork();

  /// Gets the total number of available moves.
  int get totalMoves;
}

/// In-memory implementation of [MoveRepository] for Boxing.
///
/// Uses a predefined list of Boxing moves stored in memory.
/// This is the current default implementation.
///
/// Usage:
/// ```dart
/// final repository = InMemoryMoveRepository();
/// final allMoves = repository.getAllMoves();
/// final jab = repository.getMoveById(1);
/// final slipLeft = repository.getMoveByCode('A');
/// ```
class InMemoryMoveRepository implements MoveRepository {
  @override
  List<Move> getAllMoves() {
    // Return an unmodifiable list to prevent accidental modifications
    return List.unmodifiable(boxing_data.boxingMoves);
  }

  @override
  Move? getMoveById(int id) {
    return boxing_data.getMoveById(id);
  }

  @override
  Move? getMoveByCode(String code) {
    return boxing_data.getMoveByCode(code);
  }

  @override
  List<Move> getMovesByCategory(MoveCategory category) {
    return boxing_data.getMovesByCategory(category);
  }

  @override
  List<Move> getAllPunches() {
    return boxing_data.getAllPunches();
  }

  @override
  List<Move> getAllDefense() {
    return boxing_data.getAllDefense();
  }

  @override
  List<Move> getAllFootwork() {
    return boxing_data.getAllFootwork();
  }

  @override
  int get totalMoves => boxing_data.totalMoves;
}
