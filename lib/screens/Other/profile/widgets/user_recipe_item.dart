import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserRecipeItem extends StatelessWidget {
  final List<Recipe> list;
  final int index;
  final String path;

  UserRecipeItem({
    this.list,
    this.index,
    this.path,
  });

  void selectRecipe(BuildContext context, int index, List<Recipe> recipes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: recipes[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectRecipe(context, index, list),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              imageUrl: '$path${list[index].image}',
              placeholder: (context, url) => ShimmerWidget(
                width: double.infinity,
                height: 100,
                circular: false,
              ),
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              list[index].name,
              style: GoogleFonts.lato(fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
