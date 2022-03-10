import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/models/recipe_page.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';

enum RecentRecipeStatus { Fetching, Done }
enum MostCollectedRecipeStatus { Fetching, Done }

class RecipeProvider extends ChangeNotifier {
  int _page = 1;
  List<Recipe> _recentRecipes = [];
  List<Recipe> _mostCollectedRecipes = [];
  RecentRecipeStatus _recentStatus = RecentRecipeStatus.Fetching;
  MostCollectedRecipeStatus _mostCollectedStatus =
      MostCollectedRecipeStatus.Fetching;

  RecentRecipeStatus get recentStatus => _recentStatus;
  MostCollectedRecipeStatus get mostCollectedStatus => _mostCollectedStatus;

  List<Recipe> get recentRecipes => _recentRecipes;
  List<Recipe> get mostCollectedRecipes => _mostCollectedRecipes;

  Future fetchOrDisplayRecentRecipes() async {
    if (_recentRecipes.isNotEmpty) {
      return;
    } else {
      fetchRecentRecipes();
    }
  }

  Future fetchOrDisplayMostCollectedRecipes() async {
    if (_mostCollectedRecipes.isNotEmpty) {
      return;
    } else {
      fetchMostCollectedRecipes();
    }
  }

  Future fetchRecentRecipes(
      {bool refresh = false, bool loading = false}) async {
    try {
      _recentStatus = RecentRecipeStatus.Fetching;
      if (loading) _page++;
      if (refresh) _page = 1;
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      print(lang);
      var response = await http.get(AppConfig.URL +
          '/api/fetchRecentRecipes/$lang/${AppConfig.PerPage}?page=$_page');
      RecipePage categoryPage = recipePageFromJson(response.body);
      if (refresh) _recentRecipes.clear();
      _recentRecipes.addAll(categoryPage.data);
      _recentStatus = RecentRecipeStatus.Done;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future fetchMostCollectedRecipes() async {
    try {
      _mostCollectedStatus = MostCollectedRecipeStatus.Fetching;
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      var response = await http
          .get(AppConfig.URL + '/api/fetchMostCollectedRecipes/$lang');
      List<Recipe> _recipes = recipeFromJson(response.body);
      _mostCollectedRecipes = _recipes;
      _mostCollectedStatus = MostCollectedRecipeStatus.Done;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  emptyRecipeLists() {
    _recentRecipes.clear();
    _mostCollectedRecipes.clear();
    notifyListeners();
  }
}
