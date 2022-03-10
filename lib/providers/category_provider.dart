import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/category.dart';
import 'package:food_recipes/models/category_page.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';

enum CategoryStatus { Fetching, Done }
enum CategoryRecipesStatus { Fetching, Done }

class CategoryProvider extends ChangeNotifier {
  int _categoriesPage = 1;
  List<Category> _allCategories = [];
  List<Category> _paginatedCategories = [];
  CategoryStatus _categoryStatus = CategoryStatus.Fetching;

  CategoryStatus get categoryStatus => _categoryStatus;

  List<Category> get paginatedCategories => _paginatedCategories;
  List<Category> get allCategories => _allCategories;

  Future fetchOrDisplayPaginatedCategories() async {
    if (_paginatedCategories.isNotEmpty) {
      return;
    } else {
      fetchPaginatedCategories();
    }
  }

  Future fetchOrDisplayAllCategories() async {
    if (_allCategories.isNotEmpty) {
      return;
    } else {
      fetchAllCategories();
    }
  }

  Future fetchAllCategories(
      {bool refresh = false, bool loading = false}) async {
    try {
      var response = await ApiRepository.fetchCategories();
      print(response.body);
      List<Category> _categories = categoryFromJson(response.body);
      _allCategories = _categories;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future fetchPaginatedCategories(
      {bool refresh = false, bool loading = false}) async {
    try {
      _categoryStatus = CategoryStatus.Fetching;
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      if (refresh) {
        _categoryStatus = CategoryStatus.Fetching;
        _categoriesPage = 1;
        notifyListeners();
      }
      if (loading) _categoriesPage++;
      var response = await http.get(AppConfig.URL +
          '/api/fetchCategories/$lang/${AppConfig.PerPage}?page=$_categoriesPage');
      CategoryPage categoryPage = categoryPageFromJson(response.body);
      if (refresh) _paginatedCategories.clear();
      _paginatedCategories.addAll(categoryPage.data);
      _categoryStatus = CategoryStatus.Done;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  emptyCategoryLists() {
    _allCategories.clear();
    _paginatedCategories.clear();
    _categoriesPage = 1;
    notifyListeners();
  }
}
