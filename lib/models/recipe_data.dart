// To parse this JSON data, do
//
//     final pagesData = pagesDataFromJson(jsonString);

import 'dart:convert';

import 'recipe.dart';

RecipeData recipeDataFromJson(String str) =>
    RecipeData.fromJson(json.decode(str));

String recipeDataToJson(RecipeData data) => json.encode(data.toJson());

class RecipeData {
  int currentPage;
  List<Recipe> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  String nextPageUrl;

  RecipeData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) => RecipeData(
        currentPage: json["current_page"],
        data: List<Recipe>.from(json["data"].map((x) => Recipe.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "next_page_url": nextPageUrl,
      };
}
