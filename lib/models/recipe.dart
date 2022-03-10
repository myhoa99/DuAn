import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/models/difficulty.dart';

import 'category.dart';

import 'dart:convert';

import 'cuisine.dart';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  int id;
  int userId;
  String name;
  String image;
  int duration;
  int noOfServing;
  int cuisineId;
  int difficultyId;
  String languageCode;
  Difficulty difficulty;
  Cuisine cuisine;
  List<Category> categories;
  String ingredients;
  String steps;
  String websiteUrl;
  String youtubeUrl;
  int noOfViews;
  int noOfLikes;
  int status;
  String createdAt;
  String updatedAt;
  String categoryName;
  String userFirstName;
  String userLastName;
  String userImage;
  AppUser user;

  Recipe({
    this.id,
    this.userId,
    this.name,
    this.image,
    this.duration,
    this.noOfServing,
    this.difficultyId,
    this.difficulty,
    this.languageCode,
    this.cuisineId,
    this.cuisine,
    this.categories,
    this.ingredients,
    this.steps,
    this.websiteUrl,
    this.youtubeUrl,
    this.noOfViews,
    this.noOfLikes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.user,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      languageCode: json['language_code'],
      userId: json['userId'],
      name: json['name'],
      image: json['image'],
      duration: json['duration'],
      noOfServing: json['noOfServing'],
      difficultyId: json["difficulty_id"],
      difficulty: Difficulty.fromJson(json['difficulty']),
      cuisineId: json['cuisine_id'],
      cuisine:
          json['cuisine'] != null ? Cuisine.fromJson(json['cuisine']) : null,
      categories: json["categories"] != null
          ? (json["categories"] as List)
              .map<Category>((json) => new Category.fromJson(json))
              .toList()
          : null,
      ingredients: json['ingredients'],
      steps: json['steps'],
      websiteUrl: json['websiteUrl'],
      youtubeUrl: json['youtubeUrl'],
      noOfViews: json['noOfViews'],
      noOfLikes: json['noOfLikes'],
      status: json['status'],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      categoryName: json["categoryName"] != null ? json['categoryName'] : null,
      user: json['user'] != null ? AppUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "language_code": languageCode,
        "userId": userId,
        "name": name,
        "image": image,
        "duration": duration,
        "noOfServing": noOfServing,
        "difficulty_id": difficultyId,
        "difficulty": difficulty.toJson(),
        "cuisine": cuisine.toJson(),
        "cuisine_id": cuisineId == null ? null : cuisineId,
        "ingredients": ingredients,
        "steps": steps,
        "websiteUrl": websiteUrl,
        "youtubeUrl": youtubeUrl,
        "noOfViews": noOfViews,
        "noOfLikes": noOfLikes,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user": user.toJson(),
      };

  Recipe.map(dynamic obj) {
    this.id = obj['id'];
    this.userId = obj['userId'];
    this.name = obj['name'];
    this.image = obj['image'];
    this.duration = obj['duration'];
    this.noOfServing = obj['noOfServing'];
    this.difficulty = obj['difficulty'];
    this.cuisineId = obj['cuisine_id'];
    this.ingredients = obj['ingredients'];
    this.steps = obj['steps'];
    this.websiteUrl = obj['websiteUrl'];
    this.youtubeUrl = obj['youtubeUrl'];
    this.noOfViews = obj['noOfViews'];
    this.noOfLikes = obj['noOfLikes'];
    this.status = obj['status'];
    this.createdAt = obj['created_at'];
    this.updatedAt = obj['updated_at'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["userId"] = userId;
    map["name"] = name;
    map["image"] = image;
    map["duration"] = duration;
    map["noOfServing"] = noOfServing;
    map["difficulty"] = difficulty;
    map["cuisine_id"] = cuisineId;
    map["ingredients"] = ingredients;
    map["steps"] = steps;
    map["websiteUrl"] = websiteUrl;
    map["youtubeUrl"] = youtubeUrl;
    // map["noOfViews"] = noOfViews;
    // map["noOfLikes"] = noOfLikes;
    // map["status"] = status;
    // map["created_at"] = createdAt;
    // map["updated_at"] = updatedAt;
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  Recipe.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.userId = map['userId'];
    this.name = map['name'];
    this.image = map['image'];
    this.duration = map['duration'];
    this.noOfServing = map['noOfServing'];
    this.difficulty = Difficulty.fromJson(map['difficulty']);
    this.cuisineId = map['cuisine_id'];
    this.ingredients = map['ingredients'];
    this.steps = map['steps'];
    this.websiteUrl = map['websiteUrl'];
    this.youtubeUrl = map['youtubeUrl'];
    this.noOfViews = map['noOfViews'];
    this.noOfLikes = map['noOfLikes'];
    this.status = map['status'];
    this.createdAt = map['created_at'];
    this.updatedAt = map['updated_at'];
  }
}
