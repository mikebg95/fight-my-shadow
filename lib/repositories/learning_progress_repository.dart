import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';

/// Repository for persisting and loading Story Mode learning progress.
///
/// Uses SharedPreferences to save LearningState to local storage,
/// ensuring progress survives app restarts, force closes, and reboots.
class LearningProgressRepository {
  static const String _storageKey = 'learning_state_v1';

  /// Loads the persisted LearningState from local storage.
  ///
  /// Returns null if no state has been saved yet (first launch)
  /// or if the stored data is corrupted.
  Future<LearningState?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) {
        return null; // No saved state (first launch)
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LearningState.fromJson(json);
    } catch (e) {
      // If JSON is corrupted or parsing fails, return null
      // The controller will initialize with fresh state
      print('Error loading learning state: $e');
      return null;
    }
  }

  /// Saves the current LearningState to local storage.
  ///
  /// Serializes the state to JSON and persists it using SharedPreferences.
  /// This is called automatically whenever the state changes.
  Future<void> save(LearningState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = state.toJson();
      final jsonString = jsonEncode(json);

      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // Log error but don't crash the app
      print('Error saving learning state: $e');
    }
  }

  /// Clears all persisted learning progress.
  ///
  /// Used for testing or if the user wants to reset Story Mode.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing learning state: $e');
    }
  }
}
