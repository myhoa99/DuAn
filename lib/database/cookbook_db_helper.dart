import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class CookBookDatabaseHelper {
  final String tableFavorites = "cookbookTable";

  final String columnId = "id";
  final String columnRecipeId = "recipeId";
  final String columnUserId = "userId";

  // creating an instance
  static final CookBookDatabaseHelper _instance =
      new CookBookDatabaseHelper.internal();

  // constructor private
  CookBookDatabaseHelper.internal();

  // cashes the states of the database, if it is already initialized first no need to initialized it again
  factory CookBookDatabaseHelper() => _instance;

  // create db instance
  static Database _db;

  Future<Database> get db async {
    // if instance is created already return it
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var documentDirectory = await getDatabasesPath();
    String path = join(documentDirectory, "Cookbook.db");
    var ourDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDB;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableFavorites($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnRecipeId INTEGER, $columnUserId INTEGER)");
  }

  //CRUD Operations - Create, Read, Update, Delete

  // Save a recipe in database
  Future<int> saveRecipe(int userId, int recipeId) async {
    var dbClient = await db;
    int insertedId = await dbClient.rawInsert(
        "INSERT INTO $tableFavorites($columnUserId, $columnRecipeId) VALUES ($userId, $recipeId)");
    return insertedId;
  }

  // Get all saved recipes from database
  Future<List<int>> getAllRecipes() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableFavorites");
    List<int> recipeIds = [];
    result.forEach((r) {
      recipeIds.add(r['recipeId']);
    });
    return recipeIds;
  }

  // Get a Recipe by its id from database
  Future<bool> checkIfRecipeExists(int recipeId) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $tableFavorites WHERE $columnRecipeId = $recipeId");
    if (result.length == 0)
      return false;
    else
      return true;
  }

  // Delete a recipe from database
  Future<int> deleteRecipe(int recipeId) async {
    var dbClient = await db;
    return await dbClient.delete(tableFavorites,
        where: "$columnRecipeId = ?", whereArgs: [recipeId]);
  }

  // Closes the database when done, because it uses resources in background.
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
