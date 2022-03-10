import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/screens/Tabs/recipe-add/recipe_add_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/utils/utils.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class MyRecipesRecipeItem extends StatefulWidget {
  final Recipe recipe;
  final String path;
  final Function getRecipes;

  MyRecipesRecipeItem({this.recipe, this.path, this.getRecipes});

  @override
  _MyRecipesRecipeItemState createState() => _MyRecipesRecipeItemState();
}

class _MyRecipesRecipeItemState extends State<MyRecipesRecipeItem> {
  AppProvider application;

  @override
  void initState() {
    super.initState();
    application = Provider.of<AppProvider>(context, listen: false);
  }

  Future<void> selectRecipe(BuildContext context) async {
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: widget.recipe,
        ),
      ),
    )
        .then((value) {
      widget.getRecipes();
    });
  }

  void editRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          hasBackButton: true,
          recipeId: widget.recipe.id,
        ),
      ),
    );
  }

  Future<void> deleteRecipe(BuildContext context, int id) async {
    await ApiRepository.deleteRecipe(id);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectRecipe(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRecipeImage(),
                _buildDetailsRow(),
                _buildEditButton(),
                SizedBox(width: 8),
                _buildDeleteButton(),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildRecipeImage() {
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.only(top: 5),
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl:
                  '${ApiRepository.RECIPE_IMAGES_PATH}${widget.recipe.image}',
              placeholder: (context, url) => ShimmerWidget(
                width: 80,
                height: 80,
                circular: false,
              ),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.history, color: Colors.white, size: 15),
              Text(
                getDuration(widget.recipe.duration.toString()),
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white,
                  fontFamily: 'Brandon',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildDetailsRow() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildDifficulty(),
            _buildRecipeName(),
            _buildRecipeStatus(),
          ],
        ),
      ),
    );
  }

  _buildRecipeName() {
    return Text(
      widget.recipe.name,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Brandon',
        fontSize: 17,
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  _buildDifficulty() {
    return Text(
      widget.recipe.difficulty.name.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 12,
        fontFamily: 'Brandon',
        fontWeight: FontWeight.normal,
      ),
    );
  }

  _buildRecipeStatus() {
    return widget.recipe.status == 1
        ? Container(
            width: 80,
            margin: EdgeInsets.only(top: 3),
            child: Text(
              'pending'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(15),
            ),
          )
        : Text(
            widget.recipe.createdAt.toString().substring(0, 10),
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Brandon',
              color: Colors.black54,
            ),
          );
  }

  _buildEditButton() {
    return SizedBox(
      height: 32,
      width: 32,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => editRecipe(context),
        child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
      ),
    );
  }

  _buildDeleteButton() {
    return SizedBox(
      height: 32,
      width: 32,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async => _recipeDeletionConfDialog(context),
        child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
      ),
    );
  }

  _recipeDeletionConfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.only(bottom: 15),
        title: Text(
          'are_you_sure_you_want_to_delete'.tr(),
          style: TextStyle(fontSize: 16),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  await deleteRecipe(context, widget.recipe.id);
                  await widget.getRecipes();
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(
                  'yes'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'no'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
