import 'package:shared_preferences/shared_preferences.dart';
import 'package:petalert/shared/models/pet.dart';

class PetStorage {
  static const _key = 'pets_list';

  /// Save a list of Pet objects
  static Future<void> savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pets.map((pet) => pet.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Load the saved pets list
  static Future<List<Pet>> loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList.map((j) => Pet.fromJson(j)).toList();
  }

  /// Clear all saved pets (for testing or reset)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
