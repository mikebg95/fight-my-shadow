import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fight_my_shadow/domain/training/training_preferences.dart';

/// Repository for persisting Training Preferences using SharedPreferences.
class TrainingPreferencesRepository {
  static const String _key = 'training_preferences';

  /// Saves the training preferences to persistent storage.
  Future<void> save(TrainingPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(preferences.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Loads the training preferences from persistent storage.
  ///
  /// If no saved preferences exist, returns null (caller should generate defaults).
  Future<TrainingPreferences?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return null; // No saved preferences
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TrainingPreferences.fromJson(json);
    } catch (e) {
      // Corrupted data - return null to trigger default generation
      return null;
    }
  }

  /// Clears saved training preferences.
  /// Used for testing or reset functionality.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
