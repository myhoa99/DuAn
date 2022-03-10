import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/models/comment.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/models/recipe_data.dart';
import 'package:food_recipes/models/recipe_page.dart';
import 'package:food_recipes/services/request_helper.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';

class ApiRepository {
  static RequestHelper requestHelper = RequestHelper();
  static const URL = AppConfig.URL;

  // API URL (The file performing CRUD operations)
  static const API = URL + '/api';

  // Images paths in the server
  static const RECIPE_IMAGES_PATH = URL + '/uploads/recipes/';
  static const CATEGORY_IMAGES_PATH = URL + '/uploads/categories/';
  static const CUISINE_IMAGES_PATH = URL + '/uploads/cuisines/';
  static const USER_IMAGES_PATH = URL + '/uploads/users/';

  // Settings map action
  static const headers = {'Accept': "application/json"};

  // Register a new user in the database
  static Future<AppUser> registerUser(BuildContext context, String name,
      String email, String password, File image, String imagename) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(API + '/users'));
      Map<String, String> headers = {"Content-type": "multipart/form-data"};
      if (image != null) {
        request.files.add(
          http.MultipartFile(
            'image',
            image.readAsBytes().asStream(),
            image.lengthSync(),
            filename: imagename,
            // contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      request.headers.addAll(headers);
      if (imagename != null)
        request.fields.addAll(
          {
            "name": name,
            "email": email,
            "password": password,
            "image": imagename,
          },
        );
      else
        request.fields.addAll(
          {
            "name": name,
            "email": email,
            "password": password,
          },
        );
      print("request: " + request.toString());
      var res = await request.send();
      print("This is response:" + res.reasonPhrase);
      String resBody = await res.stream.bytesToString();
      Map<String, dynamic> responseJson = json.decode(resBody);
      print(resBody);
      if (resBody.contains('The email has already been taken.'))
        Fluttertoast.showToast(msg: 'the_email_has_already_been_taken'.tr());
      else if (resBody
          .contains('The password can\'t be less than 8 characters')) {
        Fluttertoast.showToast(msg: 'the_password_cannot_be_less'.tr());
      } else if (resBody.contains('Account created successfully')) {
        Fluttertoast.showToast(msg: 'created_account'.tr());
      }

      AppUser user = AppUser.fromJson(responseJson['user']);
      if (user != null) Navigator.pop(context);
      return user;
    } catch (e) {
      print(e);
      return AppUser();
    }
  }

  static Future<http.Response> loginUsingSocial(
      AppUser user, String deviceName) async {
    try {
      final response = await http.post(
        API + '/loginUsingSocial',
        body: {
          "authKey": user.authKey,
          "name": user.name,
          "email": user.email != null ? user.email : '',
          "device_name": deviceName ?? 'Unknown',
          "image": user.image,
        },
      );
      print(response.body);
      return response;
    } catch (e) {
      print('loginUsingSocial $e');
      return null;
    }
  }

  static Future<http.Response> tryToken({String token}) async {
    try {
      http.Response response = await http
          .get(API + '/user', headers: {'Authorization': 'Bearer $token'});
      print(response.body);
      return response;
    } catch (e) {
      print('trytoken error: $e');
      return null;
    }
  }

  static Future<http.Response> updateEmail(int id, String email) async {
    try {
      var body = {
        'id': id.toString(),
        'email': email.trim().toString(),
      };
      final response =
          await http.post(API + '/updateEmail', headers: headers, body: body);
      if (200 == response.statusCode) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('Update Email $e');
      return null;
    }
  }

  // Get the privacy policy from the backend
  static Future<http.Response> fetchSettings() async {
    try {
      return await RequestHelper().getData('settings');
    } catch (e) {
      print('settings $e');
      return null;
    }
  }

  // Get the privacy policy from the backend
  static Future<http.Response> fetchCategories() async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      return await requestHelper.getData('categories/$lang');
    } catch (e) {
      print('categories fetch error: $e');
      return null;
    }
  }

  static Future<http.Response> fetchDifficulties() async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      return await requestHelper.getData('difficulties/$lang');
    } catch (e) {
      print('difficulties fetch error: $e');
      return null;
    }
  }

  static Future<http.Response> fetchLanguages() async {
    try {
      return await requestHelper.getData('fetchLanguages');
    } catch (e) {
      print('languages fetch error: $e');
      return null;
    }
  }

  // Get the rate average of a recipe from the database
  static Future<String> getRecipeRate(int recipeid) async {
    try {
      final response =
          await http.get(API + '/getRecipeRate/$recipeid', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body).cast<String, dynamic>();
        return parsed['rate'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get the rate a of user for a specific recipe
  static Future<String> getUserRateOfRecipe(int recipeid, int userid) async {
    try {
      final response = await http.get(API + '/getUserRate/$recipeid/$userid',
          headers: headers);
      if (200 == response.statusCode) {
        // print(response.body);
        final parsed = json.decode(response.body).cast<String, dynamic>();
        return parsed['rate'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get the number of likes of a recipe from the database
  static Future<int> getRecipeLikes(int recipeid) async {
    try {
      final response =
          await http.get(API + '/getRecipeLikes/$recipeid', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body).cast<String, dynamic>();
        return parsed['likes'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Update user recipe in the database
  static Future<void> updateRecipe(int userId, Recipe recipe,
      List<int> selectedCategories, File image, String imagename) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(API + '/recipes/${recipe.id}?_method=PUT'),
    );
    Map<String, String> headers = {
      "Content-type": "multipart/form-data",
    };
    if (image != null) {
      request.files.add(
        http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: imagename,
          // contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    request.headers.addAll(headers);

    print(json.encode(selectedCategories));
    print(userId);
    request.fields.addAll(
      {
        'userId': userId.toString(),
        'name': recipe.name,
        'language_code': recipe.languageCode,
        'noOfServing': recipe.noOfServing.toString(),
        'duration': recipe.duration.toString(),
        'difficulty_id': recipe.difficulty.id.toString(),
        'cuisine_id': recipe.cuisine.id.toString(),
        'categories': json.encode(selectedCategories),
        'ingredients': recipe.ingredients,
        'steps': recipe.steps,
        'websiteUrl': recipe.websiteUrl != null ? recipe.websiteUrl : null,
        'youtubeUrl': recipe.youtubeUrl != null ? recipe.youtubeUrl : null,
      },
    );
    print("request: " + request.toString());
    var res = await request.send();
    print("This is response:" + res.reasonPhrase);
    String resBody = await res.stream.bytesToString();
    print(resBody);
    if (resBody.contains('message')) {
      Fluttertoast.showToast(msg: 'updated_recipe'.tr());
    }
    return null;
  }

  // Add user recipe to the database
  static Future addRecipe(int userId, Recipe recipe,
      List<int> selectedCategories, File image, String imagename) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(API + '/recipes'),
    );
    Map<String, String> headers = {
      "Content-type": "multipart/form-data",
    };
    if (image != null) {
      request.files.add(
        http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: imagename,
          // contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    request.headers.addAll(headers);

    print(json.encode(selectedCategories));

    request.fields.addAll(
      {
        'userId': userId.toString(),
        'name': recipe.name,
        'noOfServing': recipe.noOfServing.toString(),
        'duration': recipe.duration.toString(),
        'difficulty_id': recipe.difficulty.id.toString(),
        'cuisine_id': recipe.cuisine.id.toString() != null
            ? recipe.cuisine.id.toString()
            : 0,
        'language_code': recipe.languageCode,
        'categories': json.encode(selectedCategories),
        'ingredients': recipe.ingredients,
        'steps': recipe.steps,
        'websiteUrl': recipe.websiteUrl != null ? recipe.websiteUrl : null,
        'youtubeUrl': recipe.youtubeUrl != null ? recipe.youtubeUrl : null,
      },
    );
    print("request: " + request.toString());
    var res = await request.send();
    print("This is response:" + res.reasonPhrase);
    String resBody = await res.stream.bytesToString();
    print(resBody);
    // final responseJson = json.decode(resBody);
    if (resBody.contains('message')) {
      Fluttertoast.showToast(msg: 'added_recipe'.tr());
    }
    // Recipe r = Recipe.fromJson(responseJson['recipe']);
  }

  static Future<String> updateUserPassword(
      int id, String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
          API + '/changePassword/$id/$oldPassword/$newPassword',
          headers: headers);
      final responseJson = json.decode(response.body);
      if (200 == response.statusCode) {
        Fluttertoast.showToast(
            msg: responseJson['message'], toastLength: Toast.LENGTH_SHORT);
        return response.body;
      } else
        Fluttertoast.showToast(
            msg: responseJson['message'], toastLength: Toast.LENGTH_SHORT);
    } catch (e) {
      print('changePassword error: $e');
      return null;
    }
    return null;
  }

  // Get all recipes from the database
  static Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await http.get(API + '/recipes', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
        List<Recipe> list =
            parsed.map<Recipe>((json) => Recipe.fromJson(json)).toList();
        return list;
      } else {
        return [];
      }
    } catch (e) {
      print('recipes fetching error: $e');
      return [];
    }
  }

  // Get most collected recipes from the database
  static Future<List<Recipe>> getMostCollectedRecipes() async {
    try {
      final response =
          await http.get(API + '/showMostCollectedRecipes', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
        List<Recipe> list =
            parsed.map<Recipe>((json) => Recipe.fromJson(json)).toList();
        return list;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get recent recipes from the database
  static Future<RecipePage> fetchNewestRecipes(int page) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      final response = await http.get(
          API + '/fetchRecentRecipes/$lang/${AppConfig.PerPage}?page=$page',
          headers: headers);
      print(response.body);
      if (200 == response.statusCode) {
        return recipePageFromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('fetchRecentRecipes error: $e');
      return null;
    }
  }

  // Get all recipes of a category from the database
  static Future<RecipePage> fetchRecipeByCategory(int id, int page) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      final response = await http.get(
          API +
              '/fetchRecipesByCategory/$lang/$id/${AppConfig.PerPage}?page=$page',
          headers: headers);
      if (200 == response.statusCode) {
        return recipePageFromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('fetchRecipesByCategory error: $e');
      return null;
    }
  }

  // Get all recipes of a cuisine from the database
  static Future<RecipePage> fetchRecipeByCuisine(int id, int page) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      final response = await http.get(
          API +
              '/fetchRecipesByCuisine/$lang/$id/${AppConfig.PerPage}?page=$page',
          headers: headers);
      if (200 == response.statusCode) {
        return recipePageFromJson(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('fetchRecipesByCuisine error: $e');
      return null;
    }
  }

  static Future<Recipe> getUserRecipe(int id) async {
    try {
      final response = await http.get(API + '/recipes/$id', headers: headers);
      if (200 == response.statusCode) {
        final parsed = jsonDecode(response.body);
        Recipe r = Recipe.fromJson(parsed);
        return r;
      } else {
        return Recipe();
      }
    } catch (e) {
      print('recipes $e');
      return Recipe();
    }
  }

  // Get all recipes of a user from the database
  static Future<RecipeData> getRecipesByUser(int id) async {
    try {
      final storage = new FlutterSecureStorage();
      String token = await storage.read(key: 'token');
      var headers = {
        'Accept': "application/json",
        'Authorization': 'Bearer $token',
      };
      final response =
          await http.get(API + '/showRecipesByUser' + '/$id', headers: headers);
      if (200 == response.statusCode) {
        RecipeData recipeData = recipeDataFromJson(response.body);
        return recipeData;
      } else {
        return RecipeData();
      }
    } catch (e) {
      print('showRecipesByUser error: $e');
      return RecipeData();
    }
  }

  static Future<List<Recipe>> getUserFavorites(
      int userId, List<int> recipeIds, String lang) async {
    try {
      var headers = {'Accept': "application/json"};
      var data = {
        'recipeIds': json.encode(recipeIds),
        'userId': userId.toString(),
        'lang': lang.toString(),
      };
      final response = await http.post(API + '/getUserFavorites',
          body: data, headers: headers);
      print(response.body);
      return recipeFromJson(response.body);
    } catch (e) {
      print('getUserFavorites error: $e');
      return null;
    }
  }

  static Future<RecipeData> getProfileUserRecipes(int id) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      var headers = {'Accept': "application/json"};
      final response = await http
          .get(API + '/fetchProfileUserRecipes/$lang/$id', headers: headers);
      RecipeData recipeData = recipeDataFromJson(response.body);
      return recipeData;
    } catch (e) {
      print('fetchProfileUserRecipes error: $e');
      return RecipeData();
    }
  }

  // Add user follow to a recipe in the database
  static Future<bool> addUserFollow(int userId, int followerId) async {
    try {
      final response = await http.post(
          API + '/addUserFollow' + '/$userId/$followerId',
          headers: headers);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        return data['following'];
      } else {
        return null;
      }
    } catch (e) {
      print('addUserFollow error: $e');
      return null;
    }
  }

  // Get user rate to a recipe in the database
  static Future<bool> addUserRate(int userId, double rate, int recipeId) async {
    try {
      final response = await http.post(
          API + '/addRecipeRate' + '/$recipeId/$userId/$rate',
          headers: headers);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        print(data);
        return data['rated'];
      } else {
        return null;
      }
    } catch (e) {
      print('addRecipeRate error: $e');
      return null;
    }
  }

  static Future<Map> getProfileInfo(int userId) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      final response = await http
          .get(API + '/getProfileInfo/$lang' + '/$userId', headers: headers);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        return data;
      } else {
        return Map();
      }
    } catch (e) {
      print('getProfileInfo error: $e');
      return null;
    }
  }

  // Check if using is following another user
  static Future<bool> checkIfUserIsFollowing(int userId, int followerId) async {
    try {
      final response = await http.get(
          API + '/checkIfUserIsFollowing/$userId/$followerId',
          headers: headers);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        print(data['following']);
        return data['following'];
      } else {
        return null;
      }
    } catch (e) {
      print('checkIfUserIsFollowing error: $e');
      return null;
    }
  }

  // Add device token to the database
  static Future<String> addDevice(String token) async {
    try {
      final response =
          await http.post(API + '/setDeviceToken/$token', headers: headers);
      if (201 == response.statusCode) {
        print(response.body);
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('setDeviceToken error: $e');
      return null;
    }
  }

  // Get comments of a specific recipe from the database
  static Future<List<Comment>> getRecipeComments(int recipeid) async {
    try {
      final response = await http.get(API + '/getRecipeComments/$recipeid',
          headers: headers);
      print(response.body);
      print(response.statusCode);
      if (200 == response.statusCode) {
        List<Comment> comments = commentFromJson(response.body);
        return comments;
      } else {
        return [];
      }
    } catch (e) {
      print('getRecipeComments error: $e');
      return [];
    }
  }

  // Get user following from the database
  static Future<http.Response> fetchUserFollowingFollowers(int userid) async {
    try {
      final response = await http.get(API + '/fetchFollowingFollowers/$userid',
          headers: headers);
      if (200 == response.statusCode) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('fetchFollowingFollowers error: $e');
      return null;
    }
  }

  // Add recipe comment of a user in the database
  static Future<String> addRecipeComment(
      int userid, int recipeid, String comment) async {
    try {
      final response = await http.post(
          API + '/addRecipeComment/$recipeid/$userid/$comment',
          headers: headers);
      if (201 == response.statusCode) {
        Fluttertoast.showToast(msg: 'comment_added_successfully'.tr());
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('addRecipeComment error: $e');
      return null;
    }
  }

  // Update recipe number of views in the database
  static Future<String> updateRecipeViews(int id) async {
    try {
      final response =
          await http.put(API + '/updateRecipeView/$id', headers: headers);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        print(data['message']);
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('updateRecipeView error: $e');
      return null;
    }
  }

  // Update recipe number of likes in the database
  static Future<String> updateRecipeLikes(int id, String operation) async {
    try {
      var map = Map<String, dynamic>();
      final response = await http.put(API + '/updateRecipeLikes/$id/$operation',
          body: map, headers: headers);
      if (200 == response.statusCode) {
        print(response.body);
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('updateRecipeLikes error: $e');
      return null;
    }
  }

  // Delete user image from the database
  static Future<http.Response> deleteUserImage(int id) async {
    try {
      final response =
          await http.delete(API + '/deleteImage/$id', headers: headers);
      if (200 == response.statusCode) {
        return response;
      } else {
        return null;
      }
    } catch (e) {
      print('deleteImage error: $e');
      return null;
    }
  }

  // Delete recipe comment of a specific user from the database
  static Future<String> deleteUserComment(int id) async {
    try {
      final response =
          await http.delete(API + '/deleteUserComment/$id', headers: headers);
      if (200 == response.statusCode) {
        Fluttertoast.showToast(msg: 'comment_deleted_successfully'.tr());
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('deleteUserComment error: $e');
      return null;
    }
  }

  // Delete user recipe from the database
  static Future<String> deleteRecipe(int id) async {
    try {
      final response =
          await http.delete(API + '/recipes/$id', headers: headers);
      if (204 == response.statusCode) {
        Fluttertoast.showToast(msg: 'deleted_recipe'.tr());
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      print('recipes error: $e');
      return null;
    }
  }

// Reset user password in the database
  static Future<String> resetPassword(String email) async {
    try {
      var map = Map<String, dynamic>();
      map['email'] = email;
      final response =
          await http.post(API + '/forgotPassword', body: map, headers: headers);
      print(response.body);
      if (200 == response.statusCode) {
        var data = json.decode(response.body);
        return data['message'];
      } else {
        return null;
      }
    } catch (e) {
      print('forgotPassword error: $e');
      return null;
    }
  }

  static Future<List<AppUser>> queryUserSearch(String name, int id) async {
    try {
      final response =
          await http.get(API + '/users/search/$name/$id', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
        List<AppUser> list =
            parsed.map<AppUser>((json) => AppUser.fromJson(json)).toList();
        print(list);
        return list;
      } else {
        return [];
      }
    } catch (e) {
      print('users search error: $e');
      return [];
    }
  }

  static Future<List<Recipe>> fetchSearchedRecipes(String name) async {
    try {
      String lang =
          EasyLocalization.of(navigatorKey.currentContext).locale.languageCode;
      final response =
          await http.get(API + '/recipes/search/$lang/$name', headers: headers);
      if (200 == response.statusCode) {
        print(response.body);
        List<Recipe> _recipes = recipeFromJson(response.body);
        return _recipes;
      } else {
        return [];
      }
    } catch (e) {
      print('recipes search error: $e');
      return [];
    }
  }

  static Future<bool> checkAccountstatus(int userId) async {
    try {
      final response =
          await http.get(API + '/checkAccountStatus/$userId', headers: headers);
      if (200 == response.statusCode) {
        final parsed = json.decode(response.body);
        return parsed['status'];
      } else {
        return false;
      }
    } catch (e) {
      print('checkAccountStatus error: $e');
      return false;
    }
  }
}
