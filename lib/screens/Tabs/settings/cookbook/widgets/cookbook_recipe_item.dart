import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CookbookRecipeItem extends StatefulWidget {
  final queryData;
  final Recipe recipe;
  final Function getRecipes;

  CookbookRecipeItem({
    this.queryData,
    this.recipe,
    this.getRecipes,
  });

  @override
  _CookbookRecipeItemState createState() => _CookbookRecipeItemState();
}

class _CookbookRecipeItemState extends State<CookbookRecipeItem> {
  final path = ApiRepository.RECIPE_IMAGES_PATH;

  Future<void> selectRecipe(BuildContext context) async {
    print(widget.recipe);
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: widget.recipe),
      ),
    )
        .then((value) {
      setState(() {
        widget.getRecipes();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectRecipe(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: '$path${widget.recipe.image}',
              placeholder: (context, url) => ShimmerWidget(
                width: double.infinity,
                height: widget.queryData.size.width / 3,
                circular: false,
              ),
              width: double.infinity,
              height: widget.queryData.size.width / 3,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(
            widget.recipe.name,
            style: GoogleFonts.ubuntu(
              fontSize: widget.queryData.size.width / 22,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
