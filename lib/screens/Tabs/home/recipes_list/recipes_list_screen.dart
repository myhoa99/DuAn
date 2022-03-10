import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes/config/app_config.dart';
import 'package:food_recipes/models/category.dart';
import 'package:food_recipes/models/cuisine.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/models/recipe_page.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/home_recipe_item.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';

enum ListType { Newest, Category, Cuisine }

class RecipesListScreen extends StatefulWidget {
  final Category category;
  final Cuisine cuisine;
  final ListType listType;

  const RecipesListScreen({Key key, this.category, this.cuisine, this.listType})
      : super(key: key);

  @override
  _RecipesListScreenState createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refreshKey = GlobalKey();

  List<Recipe> _recipes = [];
  bool _isFetching = true;
  int _recipesPage = 1;

  final _bannerController = BannerAdController();
  var _paddingBottom = 0.0;

  @override
  void initState() {
    super.initState();

    _fetchRecipes();
    _loadAndShowAd();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  _loadAndShowAd() async {
    if (AppConfig.AdmobEnabled) {
      _bannerController.onEvent.listen((e) {
        final event = e.keys.first;
        final info = e.values.first;
        switch (event) {
          case BannerAdEvent.loaded:
            setState(() => _paddingBottom = (info as int)?.toDouble());
            break;
          default:
            break;
        }
      });
      await _bannerController?.load();
      if (_bannerController.isLoaded) _bannerController.show();
    }
  }

  _fetchRecipes() async {
    RecipePage recipePage;
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = await ApiRepository.fetchNewestRecipes(_recipesPage);
        break;
      case ListType.Category:
        recipePage = await ApiRepository.fetchRecipeByCategory(
            widget.category.id, _recipesPage);
        break;
      case ListType.Cuisine:
        recipePage = await ApiRepository.fetchRecipeByCuisine(
            widget.cuisine.id, _recipesPage);
        break;
      default:
        recipePage = await ApiRepository.fetchNewestRecipes(_recipesPage);
    }

    if (mounted)
      setState(() {
        _recipes = recipePage.data;
        _isFetching = false;
      });
  }

  _onRefresh() async {
    RecipePage recipePage;

    setState(() {
      _isFetching = true;
    });
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = await ApiRepository.fetchNewestRecipes(1);
        break;
      case ListType.Category:
        recipePage =
            await ApiRepository.fetchRecipeByCategory(widget.category.id, 1);
        break;
      case ListType.Cuisine:
        recipePage =
            await ApiRepository.fetchRecipeByCuisine(widget.cuisine.id, 1);
        break;
      default:
        recipePage = await ApiRepository.fetchNewestRecipes(1);
    }

    _recipes.clear();
    _recipesPage = 1;
    _recipes.addAll(recipePage.data);

    if (mounted)
      setState(() {
        _refreshController.refreshCompleted();
        _isFetching = false;
      });
  }

  _onLoading() async {
    RecipePage recipePage;
    _recipesPage++;
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = await ApiRepository.fetchNewestRecipes(_recipesPage);
        break;
      case ListType.Category:
        recipePage = await ApiRepository.fetchRecipeByCategory(
            widget.category.id, _recipesPage);
        break;
      case ListType.Cuisine:
        recipePage = await ApiRepository.fetchRecipeByCuisine(
            widget.cuisine.id, _recipesPage);
        break;
      default:
        recipePage = await ApiRepository.fetchNewestRecipes(_recipesPage);
    }
    _recipes.addAll(recipePage.data);
    if (mounted)
      setState(() {
        _refreshController.loadComplete();
      });
  }

  String _displayName() {
    switch (widget.listType) {
      case ListType.Newest:
        return 'recent_recipes'.tr();
        break;
      case ListType.Category:
        return widget.category.name;
        break;
      case ListType.Cuisine:
        return widget.cuisine.name;
        break;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      enableLoadingWhenFailed: true,
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footerTriggerDistance: 30,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  _appBar() {
    return AppBar(
      brightness: Brightness.light,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        _displayName(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  _body() {
    return _isFetching
        ? ShimmerLoading(type: ShimmerType.Recipes)
        : Stack(
            children: [
              SmartRefresher(
                key: _refreshKey,
                controller: _refreshController,
                enablePullUp: true,
                physics: BouncingScrollPhysics(),
                footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: _recipes.isNotEmpty
                    ? ListView.builder(
                        key: _contentKey,
                        padding:
                            EdgeInsets.only(top: 10, bottom: _paddingBottom),
                        itemBuilder: (ctx, index) => HomeRecipeItem(
                          recipe: _recipes[index],
                        ),
                        itemCount: _recipes.length,
                      )
                    : Center(
                        child: Text(
                          "no_recipes_to_display".tr(),
                          style: GoogleFonts.pacifico(fontSize: 17),
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBannerAd(),
              ),
            ],
          );
  }

  _buildBannerAd() {
    return BannerAd(
      controller: _bannerController,
      size: BannerSize.BANNER,
    );
  }
}
