import 'package:food_recipes/screens/Auth/login/login_screen.dart';
import 'package:food_recipes/screens/Tabs/settings/profile-edit/profile_edit_screen.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/screens/Auth/register/register_screen.dart';
import 'package:food_recipes/screens/Auth/splash/splash_screen.dart';
import 'package:food_recipes/screens/tabs/tabs_screen.dart';
import 'package:flutter/widgets.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  TabsScreen.routeName: (context) => TabsScreen(),
  RecipeDetailsScreen.routeName: (context) => RecipeDetailsScreen(),
};
