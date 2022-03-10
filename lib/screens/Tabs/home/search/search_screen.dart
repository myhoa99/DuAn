import 'package:flutter/material.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/home_recipe_item.dart';
import 'package:food_recipes/widgets/search_text_field.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchScreen extends StatefulWidget {
  final String keyword;

  SearchScreen({this.keyword});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchKeywordController = TextEditingController();
  bool _isLoading = false;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();

    _searchKeywordController.text = widget.keyword;

    _fetchRecipes();
  }

  _fetchRecipes() async {
    if (widget.keyword != _searchKeywordController.text) {
      FocusScope.of(context).unfocus();
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _isLoading = true;
    });
    if (widget.keyword.isNotEmpty) {
      await ApiRepository.fetchSearchedRecipes(_searchKeywordController.text)
          .then((recipes) {
        if (recipes != null) {
          if (mounted)
            setState(() {
              _recipes = recipes;
              _isLoading = false;
            });
        }
      });
    } else {
      setState(() {
        _recipes.clear();
        _isLoading = false;
      });
    }
  }

  _onChanged() {
    if (_searchKeywordController.text.isEmpty)
      setState(() {
        _recipes.clear();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'search'.tr(),
          style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildSearchResultList(),
        ],
      ),
    );
  }

  _buildSearchField() {
    return SearchTextfield(
      hintText: 'search_recipe_here'.tr(),
      controller: _searchKeywordController,
      suffixIconOnTap: () => _fetchRecipes(),
      onChanged: () => _onChanged(),
    );
  }

  _buildSearchResultList() {
    if (!_isLoading) {
      if (_searchKeywordController.text.isNotEmpty) {
        if (_recipes.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              itemCount: _recipes.length,
              itemBuilder: (context, index) =>
                  HomeRecipeItem(recipe: _recipes[index]),
            ),
          );
        } else {
          return _buildMessageText('no_recipes_to_display'.tr());
        }
      } else
        return _buildMessageText('start_looking_for_recipes'.tr());
    } else {
      return Expanded(child: ShimmerLoading(type: ShimmerType.Recipes));
    }
  }

  _buildMessageText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          'start_looking_for_users'.tr(),
          style: TextStyle(fontFamily: 'Brandon'),
        ),
      ),
    );
  }
}
