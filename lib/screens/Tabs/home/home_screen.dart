import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes/config/app_config.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/providers/recipe_provider.dart';
import 'package:food_recipes/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/screens/Tabs/home/recipes_list/recipes_list_screen.dart';
import 'package:food_recipes/screens/Tabs/home/search/search_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/services/notification_bloc.dart';
import 'package:food_recipes/widgets/home_recipe_item.dart';
import 'package:food_recipes/widgets/search_text_field.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<Map> _notificationSubscription;
  GlobalKey _contentKey = GlobalKey();
  TextEditingController _searchKeywordController = TextEditingController();
  GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
    _fetchMostCollectedRecipes();
    _fetchRecentRecipes();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    if (message['data']['message'] != null) {
      print('message map $message');
      Map decodedMessage = json.decode(message['data']['message']);

      if (decodedMessage['follow'] != null) {
        AppUser user = AppUser.fromJson(decodedMessage['follow']);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      } else if (decodedMessage['recipe'] != null) {
        Recipe recipe = Recipe.fromJson(decodedMessage['recipe']);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailsScreen(recipe: recipe),
          ),
        );
      }
    }
  }

  _fetchRecentRecipes() async {
    await Provider.of<RecipeProvider>(context, listen: false)
        .fetchOrDisplayRecentRecipes();
  }

  _fetchMostCollectedRecipes() async {
    await Provider.of<RecipeProvider>(context, listen: false)
        .fetchOrDisplayMostCollectedRecipes();
  }
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  _onRefresh() async {
    await _fetchMostCollectedRecipes();
    await _fetchMostCollectedRecipes();
    setState(() {
      _refreshController.refreshCompleted();
    });

  }

  _onLoading()  async{
    await _fetchMostCollectedRecipes();
    await _fetchMostCollectedRecipes();
    setState(() {
      _refreshController.loadComplete();
    });

  }
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: RefreshConfiguration.copyAncestor(
        context: context,
        enableLoadingWhenFailed: true,
        headerBuilder: () => WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: SafeArea(
          child: Scaffold(body: _body()),
        ),
      ),
    );
  }

  _body() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: SmartRefresher(
        key: _refreshKey,
        controller: _refreshController,
        enablePullUp: true,
        physics: BouncingScrollPhysics(),
        footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildUserNameAndImage(),
              _buildSearchField(),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: _buildTitle(
                  text: 'most_collected'.tr(),
                  hasViewAll: false,
                ),
              ),
              _buildCarousel(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _buildTitle(
                  text: 'recent_recipes'.tr(),
                  hasViewAll: true,
                ),
              ),
              _buildRecentRecipesList(),
            ],
          ),
        ),
      ),
    );
  }

  _buildUserNameAndImage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'good_morning'.tr(),
                    style: GoogleFonts.ubuntu(
                        color: Colors.black54, fontSize: 14.5),
                  ),
                  SizedBox(height: 5),
                  Text(
                    auth.user != null ? auth.user.name : 'Guest',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (auth.user != null && auth.user.image != null)
                    ? Image.network(
                        auth.user.image.contains('https')
                            ? auth.user.image
                            : '${ApiRepository.USER_IMAGES_PATH}${auth.user.image}',
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/logo_user.png'),
              )
            ],
          ),
        );
      },
    );
  }

  Widget popupListItemWidget(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        recipe.name,
        style: TextStyle(fontSize: 18, fontFamily: 'RobotoCondensed'),
      ),
    );
  }

  _buildTitle({String text, bool hasViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontFamily: 'Brandon',
            fontSize: 18,
          ),
        ),
        hasViewAll
            ? Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipesListScreen(
                          listType: ListType.Newest,
                        ),
                      ),
                    ),
                    child: AutoSizeText(
                      'view_all'.tr(),
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  _buildSearchField() {
    return SearchTextfield(
      hintText: 'search_recipe_here'.tr(),
      controller: _searchKeywordController,
      suffixIconOnTap: () {
        if (_searchKeywordController.text.isNotEmpty) {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SearchScreen(
                keyword: _searchKeywordController.text,
              ),
            ),
          );
        }
      },
      onChanged: () => null,
    );
  }

  _buildCarousel() {
    return Consumer<RecipeProvider>(
      builder: (context, recipe, child) {
        if (recipe.mostCollectedStatus == MostCollectedRecipeStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Carousel);
        } else {
          List<Recipe> _recipes = recipe.mostCollectedRecipes;
          return _recipes.isNotEmpty
              ? SizedBox(
                  height: 180.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Carousel(

                      images: List.generate(
                        _recipes.length,
                        (index) => Stack(
                          children: [
                            Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.network(
                                ApiRepository.RECIPE_IMAGES_PATH +
                                    _recipes[index].image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            Align(
                              alignment: context.locale.languageCode == 'ar'
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 22,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  _recipes[index].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Brandon',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      dotSize: 5.0,
                      dotSpacing: 15.0,
                      radius: Radius.circular(15),
                      dotColor: Theme.of(context).primaryColor,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.transparent,
                      borderRadius: true,
                      onImageTap: (index) =>
                          _navigateToRecipeDetailsScreen(_recipes[index]),
                    ),
                  ),
                )
              : Container(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No Recipes To Display',
                      style: GoogleFonts.pacifico(fontSize: 14),
                    ),
                  ),
                );
        }
      },
    );
  }

  _buildRecentRecipesList() {
    return Consumer<RecipeProvider>(
      builder: (context, recipe, child) {
        if (recipe.recentStatus == RecentRecipeStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Recipes);
        } else {
          List<Recipe> _recipes = recipe.recentRecipes;
          return _recipes.isNotEmpty
              ? ListView.builder(
                  key: _contentKey,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) => HomeRecipeItem(
                    recipe: _recipes[index],
                  ),
                  itemCount: _recipes.length > AppConfig.PerPage
                      ? AppConfig.PerPage
                      : _recipes.length,
                )
              : Container(
                  height: 200,
                  child: Center(
                    child: Text(
                      'no_recent_recipes'.tr(),
                      style: GoogleFonts.pacifico(fontSize: 15),
                    ),
                  ),
                );
        }
      },
    );
  }

  void onItemSelected(Recipe recipe) {
    _navigateToRecipeDetailsScreen(recipe);
  }

  _navigateToRecipeDetailsScreen(Recipe recipe) async {
    await Provider.of<AppProvider>(context, listen: false)
        .incrementAdClickCount();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  Widget noItemsFound() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.folder_open,
          size: 24,
          color: Colors.grey[900].withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "no_recipes_to_display".tr(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900].withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget selectedItemWidget(
      Recipe selectedItem, VoidCallback deleteSelectedItem) {
    return Container();
  }
}
