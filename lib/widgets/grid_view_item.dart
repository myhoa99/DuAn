import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/models/category.dart';
import 'package:food_recipes/models/cuisine.dart';
import 'package:food_recipes/screens/Tabs/home/recipes_list/recipes_list_screen.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';

class GridViewItem extends StatelessWidget {
  final Category category;
  final Cuisine cuisine;
  final String path;

  GridViewItem({this.category, this.cuisine, this.path});

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return category != null
              ? RecipesListScreen(
                  category: category,
                  listType: ListType.Category,
                )
              : RecipesListScreen(
                  cuisine: cuisine,
                  listType: ListType.Cuisine,
                );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(0),
        child: Stack(
          children: <Widget>[
            _buildCategoryImage(),
            _buildCategoryName(context),
          ],
        ),
      ),
    );
  }

  _buildCategoryImage() {
    return CachedNetworkImage(
      imageUrl:
          category != null ? '$path${category.image}' : '$path${cuisine.image}',
      placeholder: (context, url) => ShimmerWidget(
        width: 200,
        height: double.infinity,
        circular: false,
      ),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  _buildCategoryName(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black12),
      alignment: AlignmentDirectional.bottomStart,
      padding: EdgeInsets.all(8),
      child: Text(
        category != null ? '${category.name}' : '${cuisine.name}',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
