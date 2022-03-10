import 'package:flutter/material.dart';
import 'package:food_recipes/config/app_config.dart';

ThemeData theme() {
  return ThemeData(
    primarySwatch: AppConfig.primaryColor,
    primaryColor: AppConfig.primaryColor,
    // accentColor: Colors.lightGreen,
    canvasColor: Colors.white,
    fontFamily: 'Raleway',
    textTheme: textTheme(),
    bottomSheetTheme: bottomSheetTheme(),
  );
}

TextTheme textTheme() {
  return ThemeData.light().primaryTextTheme.copyWith(
        bodyText1: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyText2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        subtitle2: TextStyle(
          color: Colors.black45,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        subtitle1: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      );
}

BottomSheetThemeData bottomSheetTheme() {
  return BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black, fontSize: 18),
    ),
  );
}
