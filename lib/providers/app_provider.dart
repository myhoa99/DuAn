import 'package:flutter/material.dart';
import 'package:food_recipes/models/difficulty.dart';
import 'package:food_recipes/models/language.dart';
import 'package:food_recipes/models/settings.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:http/http.dart' as http;

class AppProvider extends ChangeNotifier {
  Settings _settings;
  List<Difficulty> _difficulties = [];
  List<Language> _languages = [];
  int _recipeClickCount = 0;

  Settings get settings => _settings;
  List<Difficulty> get difficulties => _difficulties;
  List<Language> get languages => _languages;
  int get recipeClickCount => _recipeClickCount;

  Future fetchSettings() async {
    http.Response response = await ApiRepository.fetchSettings();
    print(response.body);
    _settings = settingsFromJson(response.body);
    notifyListeners();
  }

  Future fetchDifficulties() async {
    if (_difficulties.isNotEmpty) {
      return;
    }
    http.Response response = await ApiRepository.fetchDifficulties();
    _difficulties = difficultyFromJson(response.body);
    print(response.body);
    notifyListeners();
  }

  Future fetchLanguages() async {
    if (_languages.isNotEmpty) {
      return;
    }
    http.Response response = await ApiRepository.fetchLanguages();
    _languages = languageFromJson(response.body);
    print(response.body);
    notifyListeners();
  }

  Future incrementAdClickCount() async {
    _recipeClickCount++;
    print(_recipeClickCount);
    notifyListeners();
  }

  resetAdClickCount() {
    _recipeClickCount = 0;
  }

  emptyDifficultiesLists() {
    _difficulties.clear();
    notifyListeners();

  }

  notifyListeners();
}
