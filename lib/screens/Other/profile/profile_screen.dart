import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/models/recipe_data.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:food_recipes/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';

  final AppUser user;

  const ProfileScreen({Key key, this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String path = ApiRepository.USER_IMAGES_PATH;
  RecipeData recipes;
  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  int recipeCount = 0;
  bool isRetrieving = true;

  var application;
  AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _retrieveData();
    _checkIfUserIsFollowing();
    _getRecipesById();
  }

  _getRecipesById() async {
    await ApiRepository.getProfileUserRecipes(widget.user.id).then((value) {
      setState(() {
        recipes = value;
      });
    });

    setState(() {
      isRetrieving = false;
    });
  }

  Future<void> _retrieveData() async {
    await ApiRepository.getProfileInfo(widget.user.id).then((value) {
      setState(() {
        recipeCount = value['recipeCount'];
        followingCount = value['followingCount'];
        followerCount = value['followerCount'];
      });
    });
  }

  Future<void> _addUserFollower() async {
    if (_authProvider.user.id != null) {
      await ApiRepository.addUserFollow(_authProvider.user.id, widget.user.id)
          .then((value) {
        if (value == true) {
          setState(() {
            isFollowing = true;
          });
        } else {
          _checkIfUserIsFollowing();
          setState(() {
            isFollowing = false;
          });
        }
      });
      _authProvider.getFollowingFollowers();
    } else {
      Fluttertoast.showToast(
        msg: 'Please login to be able to follow users!',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    _retrieveData();
  }

  Future<void> _checkIfUserIsFollowing() async {
    if (_authProvider.user != null)
      await ApiRepository.checkIfUserIsFollowing(
              _authProvider.user.id, widget.user.id)
          .then((value) {
        if (value == true) {
          setState(() {
            isFollowing = true;
          });
        } else {
          setState(() {
            isFollowing = false;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _body(queryData),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        widget.user.name,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  _body(MediaQueryData queryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        _buildInformationRow(),
        SizedBox(height: 5),
        _buildFollowButton(),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Text(
            'recipes'.tr(),
            style: GoogleFonts.pacifico(fontSize: 21),
          ),
        ),
        _buildUserRecipesList(queryData),
      ],
    );
  }

  _buildInformationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildUserImage(),
          _buildCount(text: 'recipes'.tr(), count: recipeCount),
          _buildCount(text: 'following'.tr(), count: followingCount),
          _buildCount(text: 'followers'.tr(), count: followerCount),
        ],
      ),
    );
  }

  void selectRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: recipe,
        ),
      ),
    );
  }

  _buildCount({String text, int count}) {
    return Column(
      children: [
        Text(
          text,
          style: GoogleFonts.ubuntu(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        !isRetrieving
            ? Text(
                count != 0 ? '$count' : '0',
                style: GoogleFonts.ubuntu(
                    fontSize: 16, fontWeight: FontWeight.normal),
              )
            : Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Container(
                  width: 16,
                  height: 16,
                  color: Colors.grey.shade200,
                ),
              )
      ],
    );
  }

  _buildUserImage() {
    return (widget.user.image != null)
        ? (widget.user.image.contains('https'))
            ? CachedNetworkImage(
                imageUrl: '${widget.user.image}',
                imageBuilder: (context, imageProvider) => Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => ShimmerWidget(
                  width: 80,
                  height: 80,
                  circular: true,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : CachedNetworkImage(
                imageUrl: '$path${widget.user.image}',
                imageBuilder: (context, imageProvider) => Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => ShimmerWidget(
                  width: 80,
                  height: 80,
                  circular: true,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
        : CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo_user.png'),
            radius: 40,
          );
  }

  _buildUserRecipesList(MediaQueryData queryData) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: !isRetrieving
            ? (recipes.data.isNotEmpty)
                ? GridView.builder(
                    itemCount: recipes.data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio:
                          queryData.size.width / queryData.size.height / 0.7,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (context, index) => _userRecipeItem(context,
                        recipes.data, index, ApiRepository.RECIPE_IMAGES_PATH),
                  )
                : Center(
                    child: Text(
                      '${widget.user.name} ' + 'doesnt_have_recipes'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pacifico(fontSize: 18),
                    ),
                  )
            : ShimmerLoading(
                type: ShimmerType.ProfileRecipes,
                crossAxisCount: 3,
              ),
      ),
    );
  }

  _buildFollowButton() {
    return _authProvider.user != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 28,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.5,
                        color: (isFollowing == false)
                            ? Colors.black
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    backgroundColor:
                        (isFollowing == false) ? Colors.white : Colors.green,
                  ),
                  onPressed: () => _addUserFollower(),
                  child: (isFollowing == false)
                      ? Text('follow'.tr(), style: TextStyle(fontSize: 14))
                      : Text(
                          'following'.tr(),
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              ),
            ],
          )
        : Container();
  }

  _userRecipeItem(
      BuildContext context, List<Recipe> list, int index, String path) {
    return InkWell(
      onTap: () => selectRecipe(context, list[index]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
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
          ),
          SizedBox(height: 5),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              list[index].name,
              style: GoogleFonts.ubuntu(fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
