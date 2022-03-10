import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/cuisine.dart';
import 'package:food_recipes/models/cuisine_page.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';

enum CuisineStatus { Fetching, Done }

class CuisineProvider extends ChangeNotifier {
  int _page = 1;
  List<Cuisine> _allCuisines = [];
  List<Cuisine> _paginatedCuisines = [];
  CuisineStatus _cuisineStatus = CuisineStatus.Fetching;

  CuisineStatus get status => _cuisineStatus;
  List<Cuisine> get allCuisines => _allCuisines;
  List<Cuisine> get paginatedCuisines => _paginatedCuisines;

  Future fetchOrDisplayAllCuisines() async {
    if (_allCuisines.isNotEmpty) {
      return;
    } else {
      fetchAllCuisines();
    }
  }

  Future fetchOrDisplayPaginatedCuisines() async {
    if (_paginatedCuisines.isNotEmpty) {
      return;
    } else {
      fetchCuisines();
    }
  }

  Future fetchAllCuisines({bool refresh = false, bool loading = false}) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      var response = await http.get(AppConfig.URL + '/api/cuisines/$lang');
      List<Cuisine> _cuisines = cuisineFromJson(response.body);
      _allCuisines = _cuisines;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future fetchCuisines({bool refresh = false, bool loading = false}) async {
    try {
      _cuisineStatus = CuisineStatus.Fetching;
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      if (refresh) {
        _cuisineStatus = CuisineStatus.Fetching;
        _page = 1;
        notifyListeners();
      }
      if (loading) _page++;
      var response = await http.get(AppConfig.URL +
          '/api/fetchCuisines/$lang/${AppConfig.PerPage}?page=$_page');
      CuisinePage _cuisinePage = cuisinePageFromJson(response.body);
      if (refresh) _paginatedCuisines.clear();
      _paginatedCuisines.addAll(_cuisinePage.data);
      _cuisineStatus = CuisineStatus.Done;
      notifyListeners();
    } catch (e) {
      print(e);
      return false;
    }
  }

  emptyCuisineLists() {
    _allCuisines.clear();
    _paginatedCuisines.clear();
    _page = 1;
    notifyListeners();
  }
}
