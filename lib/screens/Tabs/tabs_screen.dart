import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_recipes/screens/tabs/categories/categories_screen.dart';
import 'package:food_recipes/screens/tabs/cuisine/cuisine_screen.dart';
import 'package:food_recipes/screens/tabs/home/home_screen.dart';
import 'package:food_recipes/screens/tabs/recipe-add/recipe_add_screen.dart';

import '../tabs/settings/settings_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  _body(BuildContext context) {
    return _pages[_selectedPageIndex]['page'];
  }

  _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      onTap: _selectPage,
      elevation: 0,
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.black26,
      selectedItemColor: Theme.of(context).primaryColor,
      currentIndex: _selectedPageIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/ic_home.png', scale: 2.2),
          activeIcon: Image.asset(
            'assets/images/ic_home.png',
            scale: 2.2,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/ic_category.png', scale: 2.2),
          activeIcon: Image.asset(
            'assets/images/ic_category.png',
            scale: 2.2,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/ic_add.png', scale: 2.2),
          activeIcon: Image.asset(
            'assets/images/ic_add.png',
            scale: 2.2,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Recipe',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/ic_country.png', scale: 2.2),
          activeIcon: Image.asset(
            'assets/images/ic_country.png',
            scale: 2.2,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Cuisine',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/ic_profile.png', scale: 1.9),
          activeIcon: Image.asset(
            'assets/images/ic_profile.png',
            scale: 1.9,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Account',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      {'page': HomeScreen()},
      {'page': CategoriesScreen()},
      {'page': AddRecipeScreen()},
      {'page': CuisineScreen()},
      {'page': SettingsScreen()},
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }
}
