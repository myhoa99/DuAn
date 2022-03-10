import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/config/app_config.dart';
import 'package:food_recipes/database/cookbook_db_helper.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/models/comment.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/utils/utils.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

final BaseCacheManager baseCacheManager = DefaultCacheManager();

class RecipeDetailsScreen extends StatefulWidget {
  static const routeName = '/recipe-details';

  final Recipe recipe;
  final String route;

  RecipeDetailsScreen({this.recipe, this.route});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  List<String> _ingredients = [];
  List<String> _steps = [];
  List _selectedIngredients = [];
  List<Comment> _comments = [];

  var db = new CookBookDatabaseHelper();

  TextEditingController _commentTextController;
  int savedRecipeId;
  String _recipeImagesPath = ApiRepository.RECIPE_IMAGES_PATH;
  String _uerImagesPath = ApiRepository.USER_IMAGES_PATH;

  double _iconRating = 0.0;
  String _globalRating = '';
  int _likes = 0;
  bool _favorated = false;
  bool _isFollowing = false;
  bool _isAdding = false;
  AppUser _author;

  AuthProvider _authProvider;
  AppProvider _appProvider;

  InterstitialAd interstitialAd = InterstitialAd(
    unitId: AppConfig.interstitialAdUnitId,
  );

  final bannerController = BannerAdController();

  @override
  void initState() {
    super.initState();

    _commentTextController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _getIngredients();
    _getSteps();
    _getRecipeIfExist();
    _checkIfUserIsFollowing();
    _getUserRate();
    _getRecipeRate();
    _getRecipeLikes();
    _getRecipeComments();

    ApiRepository.updateRecipeViews(widget.recipe.id);

    _loadAndShowAds();
  }

  void dispose() {
    _commentTextController.dispose();
    interstitialAd?.dispose();
    bannerController.dispose();
    super.dispose();
  }

  _loadAndShowAds() async {
    if (AppConfig.AdmobEnabled) {
      if (_appProvider.recipeClickCount == 3) {
        _appProvider.resetAdClickCount();
        await interstitialAd?.load();
        interstitialAd.show();
      }

      bannerController.load();
    }
  }

  _getIngredients() {
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(widget.recipe.ingredients);
    for (var i = 0; i < lines.length; i++) {
      _ingredients.add(lines[i]);
    }
  }

  _getSteps() {
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(widget.recipe.steps);
    for (var i = 0; i < lines.length; i++) {
      _steps.add(lines[i]);
    }
  }

  Future<void> _getRecipeComments() async {
    await ApiRepository.getRecipeComments(widget.recipe.id).then((value) {
      setState(() {
        _comments = value;
        _isAdding = false;
      });
    });
  }

  Future<void> _addUserFollower() async {
    if (_authProvider.user != null) {
      await ApiRepository.addUserFollow(
              _authProvider.user.id, widget.recipe.userId)
          .then((value) {
        if (value == true) {
          setState(() {
            _isFollowing = true;
          });
        } else {
          _checkIfUserIsFollowing();
          setState(() {
            _isFollowing = false;
          });
        }
      });
      _authProvider.getFollowingFollowers();
    } else {
      Fluttertoast.showToast(
        msg: 'please_login_to_be_able_to_follow'.tr(),
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _addUserRate(double rate) async {
    await ApiRepository.addUserRate(
        _authProvider.user.id, rate, widget.recipe.id);
  }

  Future<void> _getRecipeRate() async {
    await ApiRepository.getRecipeRate(widget.recipe.id).then((value) {
      if (value != null) {
        setState(() {
          _globalRating = value;
        });
      }
    });
  }

  Future<void> _getUserRate() async {
    if (_authProvider.user != null)
      await ApiRepository.getUserRateOfRecipe(
              widget.recipe.id, _authProvider.user.id)
          .then((value) {
        if (value != null) {
          setState(() {
            _iconRating = double.parse(value);
          });
        }
      });
  }

  Future<void> _getRecipeLikes() async {
    await ApiRepository.getRecipeLikes(widget.recipe.id).then((value) {
      setState(() {
        _likes = value;
      });
    });
  }

  Future<void> _checkIfUserIsFollowing() async {
    if (_authProvider.user != null)
      await ApiRepository.checkIfUserIsFollowing(
              _authProvider.user.id, widget.recipe.userId)
          .then((value) {
        if (value == true)
          setState(() {
            _isFollowing = true;
          });
        else
          setState(() {
            _isFollowing = false;
          });
      });
  }

  Future<void> _addRecipeComment(String comment) async {
    AppUser user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null)
      await ApiRepository.addRecipeComment(
          _authProvider.user.id, widget.recipe.id, comment);
    else {
      setState(() {
        _isAdding = true;
      });
      Fluttertoast.showToast(
          msg: 'please_login_to_be_able_to_add_comments'.tr());
    }
  }

  void _onIngredientSelected(bool selected, id) {
    if (selected == true) {
      setState(() {
        _selectedIngredients.add(id);
      });
    } else {
      setState(() {
        _selectedIngredients.remove(id);
      });
    }
  }

  Future<void> _addToFavorite() async {
    if (!_favorated) {
      savedRecipeId =
          await db.saveRecipe(_authProvider.user.id, widget.recipe.id);
      await ApiRepository.updateRecipeLikes(widget.recipe.id, 'plus');
      _getRecipeLikes();
      setState(() {
        _favorated = true;
      });
    } else {
      savedRecipeId = await db.deleteRecipe(widget.recipe.id);
      await ApiRepository.updateRecipeLikes(widget.recipe.id, 'minus');
      _getRecipeLikes();
      setState(() {
        _favorated = false;
      });
    }
  }

  // From local database
  Future _getRecipeIfExist() async {
    await db.checkIfRecipeExists(widget.recipe.id).then((state) {
      setState(() {
        _favorated = state;
      });
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 55),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                _buildRecipeImage(),
                _buildBackButton(),
                _buildSocialButtons(),
                _buildRecipeDetailsContainer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildRecipeImage() {
    return Container(
      height: 280,
      width: double.infinity,
      child: CachedNetworkImage(
        cacheManager: baseCacheManager,
        imageUrl: _recipeImagesPath + widget.recipe.image,
        placeholder: (context, url) => ShimmerWidget(
          width: double.infinity,
          height: double.infinity,
          circular: false,
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  _buildBackButton() {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 25),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: new CircleBorder(),
            ),
            child: Icon(Icons.arrow_back, size: 25, color: Colors.black),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ],
    );
  }

  _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 175, 20, 0),
      child: Column(
        children: [
          widget.recipe.websiteUrl.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _launchURL(widget.recipe.websiteUrl),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: _buildWebsiteButton(),
                    ),
                  ),
                )
              : Container(),
          widget.recipe.youtubeUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () => _launchURL(widget.recipe.youtubeUrl),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/images/watch_on_youtube.png',
                      width: 100,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  _buildWebsiteButton() {
    return Container(
      width: 85,
      height: 28,
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.web, color: Colors.white),
            ),
            Expanded(
              child: Text(
                'VISIT WEBSITE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
    );
  }

  _buildRecipeDetailsContainer() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 250, 0, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildRecipeNameRow(),
          SizedBox(height: 10),
          _buildAuthorInformation(),
          SizedBox(height: 10),
          _buildRecipeDetailsRow(),
          _buildSectionTitle(context, 'rate_recipe'.tr()),
          _buildRatingBar(),
          _buildSectionTitle(context, 'ingredient'.tr()),
          _buildIngredientsList(),
          SizedBox(height: 10),
          _buildBannerAd(),
          SizedBox(height: 10),
          _buildSectionTitle(context, 'steps'.tr()),
          _buildStepsList(),
          _buildSectionTitle(context, 'comments'.tr()),
          _buildCommentForm(context),
          _buildCommentsList(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  _buildRecipeNameRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildRecipeName(),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildShareButton(),
                SizedBox(width: 7),
                _buildAddToFavoriteButton(),
                _buildRecipeLikesCount(),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildRecipeName() {
    return Expanded(
      flex: 3,
      child: AutoSizeText(
        widget.recipe.name,
        minFontSize: 18,
        overflow: TextOverflow.visible,
        style: GoogleFonts.ubuntu(
          fontSize: 20,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  _buildShareButton() {
    return InkWell(
      child: Icon(Icons.share, size: 27),
      onTap: () => baseCacheManager
          .getSingleFile(_recipeImagesPath + widget.recipe.image)
          .then((info) {
        info.readAsBytes().then((bytes) async {
          await Share.file('${AppConfig.sharingRecipeTitle}', 'esys.png',
              bytes.buffer.asUint8List(), 'image/png',
              text: Platform.isAndroid
                  ? '${AppConfig.sharingRecipeText} \n https://play.google.com/store/apps/details?id=${AppConfig.GooglePlayIdentifier}'
                  : '${AppConfig.sharingRecipeText} \n https://apps.apple.com/de/app/bbqianer/id${AppConfig.AppStoreIdentifier}');
        });
      }),
    );
  }

  _buildAddToFavoriteButton() {
    return InkWell(
      child: _favorated
          ? Icon(Icons.favorite, color: Colors.red, size: 27)
          : Icon(Icons.favorite_border, color: Colors.red, size: 27),
      onTap: _addToFavorite,
    );
  }

  _buildRecipeLikesCount() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          child: AutoSizeText(
            '$_likes',
            style: TextStyle(fontSize: 19, color: Colors.black),
          ),
        ),
      ),
    );
  }

  _buildAuthorInformation() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: widget.recipe.user),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: widget.recipe.user != null
            ? _authorRecipeItem(
                widget.recipe.user.id,
                widget.recipe.user.image,
                widget.recipe.user.name,
                widget.recipe.user.createdAt,
              )
            : _authorRecipeItem(
                _author.id,
                _author.image,
                _author.name,
                _author.createdAt,
              ),
      ),
    );
  }

  _buildRecipeDetailsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: <Widget>[
          _detailsContainer(
            context,
            'serves'.tr(),
            '${widget.recipe.noOfServing.toString()}',
          ),
          _detailsContainer(
            context,
            tr('difficulty'),
            widget.recipe.difficulty.name,
          ),
          _detailsContainer(
            context,
            tr('duration'),
            getDuration(widget.recipe.duration.toString()),
          ),
        ],
      ),
    );
  }

  _authorRecipeItem(int userId, String image, String name, String date) {
    String path = ApiRepository.USER_IMAGES_PATH;
    return Row(
      children: [
        (image != null)
            ? (image.contains('https'))
                ? CircleAvatar(
                    backgroundImage: NetworkImage('$image'),
                    backgroundColor: Colors.white,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage('$path$image'),
                    backgroundColor: Colors.white,
                  )
            : CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/logo_user.png'),
              ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style:
                  GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Spacer(),
        _authProvider.user != null
            ? Container(
                width: 80,
                height: 28,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.5,
                        color: (_isFollowing == false)
                            ? Colors.black
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    backgroundColor: (_isFollowing == false)
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _addUserFollower(),
                  child: (_isFollowing == false)
                      ? Text('follow'.tr(), style: TextStyle(fontSize: 14))
                      : Text(
                          'following'.tr(),
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              )
            : Container(),
      ],
    );
  }

  _buildSectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 25, right: 25, bottom: 3),
      child: Container(
        child: AutoSizeText(
          text,
          style: GoogleFonts.pacifico(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }

  _buildRatingBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: GFRating(
              color: GFColors.SUCCESS,
              borderColor: GFColors.SUCCESS,
              allowHalfRating: true,
              halfFilledIcon: Icon(Icons.star_half_rounded,
                  size: 30, color: GFColors.SUCCESS),
              filledIcon: Icon(Icons.star_rate_rounded,
                  size: 30, color: GFColors.SUCCESS),
              defaultIcon: Icon(Icons.star_outline_rounded,
                  size: 30, color: GFColors.SUCCESS),
              size: GFSize.SMALL,
              value: _iconRating != null ? _iconRating : 0,
              onChanged: (value) {
                if (_iconRating != null) {
                  setState(() {
                    _iconRating = value;
                  });
                  _addUserRate(_iconRating);
                  _getRecipeRate();
                } else {
                  setState(() {
                    _iconRating = value;
                  });
                  _addUserRate(_iconRating);
                }
              },
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: (_globalRating != '') ? Text('$_globalRating') : Container(),
        ),
      ],
    );
  }

  _buildIngredientsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: (_ingredients != null && _ingredients.length > 0)
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // itemExtent: 40,
                  itemBuilder: (ctx, index) => checkBoxListTile(
                      context, _selectedIngredients, index, _ingredients),
                  itemCount: _ingredients.length,
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  _buildBannerAd() {
    return BannerAd(
      controller: bannerController,
      size: BannerSize.BANNER,
    );
  }

  _buildStepsList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _steps.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) => Card(
                elevation: 0,
                child: stepsListTile(context, index, _steps),
              ),
              itemCount: _steps.length,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  _detailsContainer(BuildContext context, String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 0.4),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: <Widget>[
            AutoSizeText(title,
                style: GoogleFonts.roboto(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                )),
            AutoSizeText(
              value,
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkBoxListTile(
      BuildContext context, List selecteditems, int index, List items) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      controlAffinity: ListTileControlAffinity.leading,
      value: selecteditems.contains(index),
      onChanged: (bool selected) {
        setState(() {
          _onIngredientSelected(selected, index);
        });
      },
      title: Text(
        items[index],
        style: GoogleFonts.lato(fontSize: 14.5, fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget stepsListTile(BuildContext context, int index, List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: <Widget>[
          AutoSizeText(
            '${index + 1}.',
            style: GoogleFonts.pacifico(),
          ),
          SizedBox(width: 15),
          Expanded(
            child: AutoSizeText(
              items[index],
              style: GoogleFonts.lato(fontSize: 14.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              'add_a_comment'.tr(),
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLength: 120,
                controller: _commentTextController,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.normal),
                maxLines: 3,
                cursorColor: Colors.black,
                decoration: InputDecoration.collapsed(
                  hintText: "enter_your_comment_here".tr(),
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                if (_commentTextController.value.text.isNotEmpty) {
                  setState(() {
                    _isAdding = true;
                  });
                  await _addRecipeComment(_commentTextController.value.text);
                  _commentTextController.clear();
                  await _getRecipeComments();
                } else {
                  Fluttertoast.showToast(msg: 'please_write_a_comment'.tr());
                }
              },
              child: _isAdding
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'add'.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCommentsList() {
    return _comments.isNotEmpty
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) =>
                  _commentListItem(context, _comments, index),
              itemCount: _comments.length,
            ),
          )
        : Center(
            child: Padding(
              padding: EdgeInsets.only(top: 55, bottom: 48),
              child: Text(
                'no_comments_yet'.tr(),
                style: TextStyle(fontSize: 15),
              ),
            ),
          );
  }

  _commentListItem(BuildContext context, List<Comment> comments, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        child: Card(
          elevation: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (comments[index].user.image != null)
                    ? (comments[index].user.image.contains('https'))
                        ? CachedNetworkImage(
                            imageUrl: '${comments[index].user.image}',
                            imageBuilder: (context, imageProvider) => Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => ShimmerWidget(
                              width: 50,
                              height: 50,
                              circular: true,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                '$_uerImagesPath${comments[index].user.image}',
                            imageBuilder: (context, imageProvider) => Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => ShimmerWidget(
                              width: 50,
                              height: 50,
                              circular: true,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                    : CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage:
                            AssetImage('assets/images/logo_user.png'),
                        radius: 25,
                      ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Text(
                            '${comments[index].user.name}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Spacer(),
                          Text(
                            '${timeago.format(comments[index].createdAt, locale: context.locale.languageCode)}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'RobotoCondensed',
                                fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${comments[index].comment}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              softWrap: true,
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: (comments[index].userId ==
                                    _authProvider.user.id)
                                ? InkWell(
                                    onTap: () async {
                                      await ApiRepository.deleteUserComment(
                                          comments[index].id);
                                      await _getRecipeComments();
                                    },
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
