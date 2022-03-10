import 'package:flutter/material.dart';
import 'package:food_recipes/models/recipe_data.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/screens/Tabs/recipe-add/recipe_add_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/my_recipes_recipe_item.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class MyRecipesScreen extends StatefulWidget {
  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  RecipeData _recipes;
  bool _isLoading = true;
  AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _getRecipeById();
  }

  _getRecipeById() async {
    await ApiRepository.getRecipesByUser(_authProvider.user.id).then((value) {
      setState(() {
        _recipes = value;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _body(),
    );
  }

  appBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'my_recipes'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, size: 30),
          onPressed: () async => await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => AddRecipeScreen(hasBackButton: true),
                ),
              )
              .then((value) => _getRecipeById()),
        ),
      ],
    );
  }

  _body() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: (!_isLoading)
          ? (_recipes.data.isNotEmpty)
              ? ListView.builder(
                  itemBuilder: (ctx, index) {
                    return MyRecipesRecipeItem(
                      recipe: _recipes.data[index],
                      path: ApiRepository.RECIPE_IMAGES_PATH,
                      getRecipes: _getRecipeById,
                    );
                  },
                  itemCount: _recipes.data.length,
                )
              : Center(
                  child: Text(
                    'no_recipes_to_display'.tr(),
                    style: GoogleFonts.pacifico(fontSize: 17),
                  ),
                )
          : ShimmerLoading(type: ShimmerType.Recipes),
    );
  }
}
