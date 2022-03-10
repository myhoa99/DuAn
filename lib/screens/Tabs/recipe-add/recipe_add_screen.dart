import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/models/category.dart';
import 'package:food_recipes/models/cuisine.dart';
import 'package:food_recipes/models/difficulty.dart';
import 'package:food_recipes/models/recipe.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/providers/category_provider.dart';
import 'package:food_recipes/providers/cuisine_provider.dart';
import 'package:food_recipes/providers/recipe_provider.dart';
import 'package:food_recipes/screens/Auth/login/login_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/utils/utils.dart';
import 'package:food_recipes/widgets/custom_deletable_text_field.dart';
import 'package:food_recipes/widgets/custom_multiline_text_field.dart';
import 'package:food_recipes/widgets/custom_text_field_dialog.dart';
import 'package:food_recipes/widgets/default_custom_button.dart';
import 'package:food_recipes/widgets/flutter_multiselect.dart';
import 'package:food_recipes/widgets/progress_dialog.dart';
import 'package:food_recipes/widgets/recipe_custom_text_field.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:food_recipes/widgets/single_select_chip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatefulWidget {
  final bool hasBackButton;
  final int recipeId;

  AddRecipeScreen({this.hasBackButton = false, this.recipeId});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  ApiRepository httpService;

  // Initializing input controllers
  TextEditingController _recipeLanguageController = TextEditingController();
  TextEditingController _recipeNameController = TextEditingController();
  TextEditingController _recipeServingController = TextEditingController();
  TextEditingController _recipeDurationController = TextEditingController();
  TextEditingController _recipeDifficultyController = TextEditingController();
  TextEditingController _recipeCategoryController = TextEditingController();
  TextEditingController _recipeCuisineController = TextEditingController();
  TextEditingController _recipeIngredientsController = TextEditingController();
  TextEditingController _recipeStepsController = TextEditingController();
  TextEditingController _recipeWebsiteUrlController = TextEditingController();
  TextEditingController _recipeYoutubeUrlController = TextEditingController();

  // Initializing data lists
  List<String> _selectedCategoriesList = [];
  List<String> _previewIngredientsList = [];
  List<String> _previewStepsList = [];
  List<int> selectedCategoriesIds = [];

  // Initializing the image picker
  final picker = ImagePicker();

  // Initializing variables and files
  bool _isRetrieving = false;
  int _selectedCuisine;
  int _selectedDifficulty;
  int _selectedLanguage;
  File _selectedImage;
  Recipe _recipe;

  AppProvider _application;
  AuthProvider _authProvider;
  CuisineProvider _cuisineProvider;

  void initState() {
    super.initState();
    _application = Provider.of<AppProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _cuisineProvider = Provider.of<CuisineProvider>(context, listen: false);

    // Retrieve the list of available categories and cuisine.
    retrieveData();
  }

  void dispose() {
    super.dispose();
    _clearAllFields();
    _recipeNameController.dispose();
    _recipeServingController.dispose();
    _recipeDurationController.dispose();
    _recipeDifficultyController.dispose();
    _recipeCategoryController.dispose();
    _recipeCuisineController.dispose();
    _recipeIngredientsController.dispose();
    _recipeStepsController.dispose();
    _recipeWebsiteUrlController.dispose();
    _recipeYoutubeUrlController.dispose();
  }

  Future _retrieveRecipeData() async {
    setState(() {
      _isRetrieving = true;
    });

    _recipe = await ApiRepository.getUserRecipe(widget.recipeId);

    // Assigning values from the server
    _recipeNameController.text = _recipe.name;
    _recipeServingController.text = _recipe.noOfServing.toString();
    _recipeDurationController.text = _recipe.duration.toString();
    _recipeDifficultyController.text = _recipe.difficulty.name;
    _recipeCuisineController.text = _recipe.cuisine?.name;
    _recipeIngredientsController.text =
        _splitStringIntoLines(_recipe.ingredients);
    _recipeStepsController.text = _splitStringIntoLines(_recipe.steps);
    _recipeWebsiteUrlController.text = _recipe.websiteUrl;
    _recipeYoutubeUrlController.text = _recipe.youtubeUrl;
    _recipeLanguageController.text = _application.languages
        .firstWhere((l) => l.code == _recipe.languageCode)
        .name;
    _selectedLanguage = _application.languages
        .firstWhere((l) => l.code == _recipe.languageCode)
        .id;
    _selectedCuisine = _recipe.cuisine?.id;
    _selectedDifficulty = _recipe.difficulty.id;
    _recipe.categories.forEach((c) => setState(() {
          _selectedCategoriesList.add(c.name);
        }));
    _recipeCategoryController.text = _selectedCategoriesList.join(",");

    Provider.of<CategoryProvider>(context, listen: false)
        .allCategories
        .forEach((c) {
      _selectedCategoriesList.forEach((s) {
        if (s == c.name) {
          if (!selectedCategoriesIds.contains(c.id))
            selectedCategoriesIds.add(c.id);
        }
      });
    });

    setState(() {
      _isRetrieving = false;
    });
  }

  String _splitStringIntoLines(String data) {
    String result = '';
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(data);
    for (var i = 0; i < lines.length; i++) {
      result = '$result\n${lines[i]}';
    }
    return result.trim();
  }

  _clearAllFields() {
    _selectedImage = null;
    _recipeNameController.clear();
    _recipeServingController.clear();
    _recipeDurationController.clear();
    _recipeDifficultyController.clear();
    _recipeCategoryController.clear();
    _recipeCuisineController.clear();
    _recipeIngredientsController.clear();
    _recipeStepsController.clear();
    _recipeWebsiteUrlController.clear();
    _recipeYoutubeUrlController.clear();
  }

  Future chooseImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future retrieveData() async {
    // Add options to the difficulty list
    await _application.fetchDifficulties();

    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchOrDisplayAllCategories();

    await Provider.of<CuisineProvider>(context, listen: false)
        .fetchOrDisplayAllCuisines();

    if (widget.recipeId != null) _retrieveRecipeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _authProvider.user != null ? _body() : _loginBody(),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: widget.hasBackButton,
      title: Text(
        widget.recipeId == null ? 'add_recipe'.tr() : 'update_recipe'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        widget.recipeId != null
            ? IconButton(icon: Icon(Icons.save), onPressed: _submitRecipe)
            : Container(),
      ],
    );
  }

  _body() {
    return _isRetrieving
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Column(
                children: [
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: InkWell(
                      onTap: chooseImage,
                      child: Container(
                        width: 125,
                        height: 125,
                        child: (_selectedImage == null)
                            ? _recipe != null && _recipe.image != null
                                ? Container(
                                    width: 85,
                                    height: 75,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          '${ApiRepository.RECIPE_IMAGES_PATH}${_recipe.image}',
                                      placeholder: (context, url) =>
                                          ShimmerWidget(
                                              width: 125,
                                              height: 125,
                                              circular: false),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 35))
                            : Image.file(_selectedImage, fit: BoxFit.cover),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.all(10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        _buildAddFields(),
                        SizedBox(height: 30),
                        _buildAddRecipeButton(),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  _loginBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            'assets/images/ic_chef.png',
            width: 125,
            height: 125,
          ),
          SizedBox(height: 30),
          Text(
            'login_or_create_account_to_add_recipes'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              wordSpacing: 0,
              fontFamily: 'Brandon',
              fontSize: 20,
            ),
          ),
          SizedBox(height: 30),
          DefaultCustomButton(
            text: 'login_or_create_account'.tr(),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }

  _buildAddFields() {
    return Column(
      children: [
        CustomTextFieldDialog(
          label: 'language'.tr() + " *",
          controller: _recipeLanguageController,
          function: () => showOptionPicker(
            text: "select_language".tr(),
            data: _application.languages,
            controller: _recipeLanguageController,
            onSelectedChanged: (selected) {
              _selectedLanguage = selected;
            },
            onDonePressed: () {
              Navigator.of(context).pop();
              if (_selectedLanguage != null)
                _recipeLanguageController.text = _application.languages
                    .firstWhere((l) => l.id == _selectedLanguage)
                    .name;
            },
          ),
        ),
        RecipeCustomTextField(
          label: 'recipe_name'.tr() + " *",
          controller: _recipeNameController,
          textInputType: TextInputType.text,
          textInputFormatter: null,
        ),
        RecipeCustomTextField(
          label: 'serves'.tr() + " *",
          controller: _recipeServingController,
          textInputType: TextInputType.number,
          textInputFormatter: FilteringTextInputFormatter.digitsOnly,
        ),
        RecipeCustomTextField(
          label: 'duration'.tr() + " *",
          controller: _recipeDurationController,
          textInputType: TextInputType.number,
          textInputFormatter: FilteringTextInputFormatter.digitsOnly,
        ),
        CustomTextFieldDialog(
          label: 'difficulty'.tr() + " *",
          controller: _recipeDifficultyController,
          function: () => showOptionPicker(
            text: "select_difficulty".tr(),
            data: _application.difficulties,
            controller: _recipeDifficultyController,
            onSelectedChanged: (selected) {
              _selectedDifficulty = selected;
            },
            onDonePressed: () {
              Navigator.of(context).pop();
              if (_selectedDifficulty != null)
                _recipeDifficultyController.text = _application.difficulties
                    .firstWhere((c) => c.id == _selectedDifficulty)
                    .name;
            },
          ),
        ),
        CustomTextFieldDialog(
          label: 'category'.tr() + " *",
          controller: _recipeCategoryController,
          function: () => _showCategoryDialog(
            _selectedCategoriesList,
            _recipeCategoryController,
          ),
        ),
        CustomDeletedTextField(
          label: 'cuisine'.tr(),
          controller: _recipeCuisineController,
          function: () => showOptionPicker(
            text: "select_a_cuisine".tr(),
            data: _cuisineProvider.allCuisines,
            controller: _recipeCuisineController,
            onSelectedChanged: (selected) {
              _selectedCuisine = selected;
            },
            onDonePressed: () {
              Navigator.of(context).pop();
              if (_selectedCuisine != null)
                setState(() {
                  _recipeCuisineController.text = _cuisineProvider.allCuisines
                      .firstWhere((c) => c.id == _selectedCuisine)
                      .name;
                });
            },
          ),
          onDelete: () {
            setState(() {
              _recipeCuisineController.clear();
              _selectedCuisine = null;
            });
          },
        ),
        CustomMultiLineTextField(
          controller: _recipeIngredientsController,
          label: 'ingredient'.tr() + " *",
          function: () async {
            await _previewIngredients(_recipeIngredientsController);
            showPreviewDialog(
              context,
              'ingredients'.tr(),
              _previewIngredientsList,
            );
          },
        ),
        CustomMultiLineTextField(
          controller: _recipeStepsController,
          label: 'steps'.tr() + " *",
          function: () async {
            await _previewSteps(_recipeStepsController);
            showPreviewDialog(context, 'steps'.tr(), _previewStepsList);
          },
        ),
        RecipeCustomTextField(
          label: 'website_url'.tr(),
          controller: _recipeWebsiteUrlController,
          textInputType: TextInputType.text,
          textInputFormatter: null,
        ),
        RecipeCustomTextField(
          label: 'youtube_url'.tr(),
          controller: _recipeYoutubeUrlController,
          textInputType: TextInputType.text,
          textInputFormatter: null,
        )
      ],
    );
  }

  _buildAddRecipeButton() {
    return widget.recipeId == null
        ? SizedBox(
            width: 300,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: _submitRecipe,
              child: Text(
                'add_recipe'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container();
  }

  _submitRecipe() async {
    if (_recipeLanguageController.value.text.isNotEmpty &&
        _recipeNameController.value.text.isNotEmpty &&
        _recipeServingController.value.text.isNotEmpty &&
        _recipeDurationController.value.text.isNotEmpty &&
        _recipeDifficultyController.value.text.isNotEmpty &&
        _recipeCategoryController.value.text.isNotEmpty &&
        _recipeIngredientsController.value.text.isNotEmpty &&
        _recipeStepsController.value.text.isNotEmpty) {
      if (_recipeWebsiteUrlController.value.text.isNotEmpty) {
        if (!valdiateURL(_recipeWebsiteUrlController.value.text)) {
          Fluttertoast.showToast(msg: tr('please_enter_a_valid_wesbite_url'));
          return;
        }
      } else if (_recipeYoutubeUrlController.value.text.isNotEmpty) {
        if (!valdiateURL(_recipeYoutubeUrlController.value.text)) {
          Fluttertoast.showToast(msg: tr('please_enter_a_valid_youtube_url'));
          return;
        }
      }

      if (widget.recipeId == null && _selectedImage == null) {
        await loadingDialog(context).hide();
        Fluttertoast.showToast(msg: 'please_provide_an_image'.tr());
        return;
      }

      await loadingDialog(context).show();

      String _fileName = '';
      if (_selectedImage != null) {
        _fileName = _selectedImage.path.split('/').last;
      }

      Recipe recipe = new Recipe();
      if (widget.recipeId != null) recipe.id = widget.recipeId;
      recipe.name = _recipeNameController.value.text.trim();
      recipe.duration = int.parse(_recipeDurationController.value.text.trim());
      recipe.noOfServing =
          int.parse(_recipeServingController.value.text.trim());
      recipe.difficulty = Difficulty(id: _selectedDifficulty);
      recipe.cuisine = Cuisine(id: _selectedCuisine);
      recipe.ingredients = _recipeIngredientsController.value.text.trim();
      recipe.steps = _recipeStepsController.value.text.trim();
      recipe.websiteUrl = _recipeWebsiteUrlController.value.text.trim();
      recipe.youtubeUrl = _recipeYoutubeUrlController.value.text.trim();
      recipe.languageCode = _application.languages
          .firstWhere((l) => l.id == _selectedLanguage)
          .code;

      if (widget.recipeId == null) {
        await ApiRepository.addRecipe(_authProvider.user.id, recipe,
            selectedCategoriesIds, _selectedImage, _fileName);
      } else {
        await ApiRepository.updateRecipe(_authProvider.user.id, recipe,
            selectedCategoriesIds, _selectedImage, _fileName);
      }
      await loadingDialog(context).hide();
      Provider.of<RecipeProvider>(context, listen: false).emptyRecipeLists();
      _clearAllFields();

      loadingDialog(context).hide();

      if (widget.hasBackButton) Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'all_fields_required'.tr());
    }
  }

  showOptionPicker({
    String text,
    List data,
    TextEditingController controller,
    Function onSelectedChanged,
    Function onDonePressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<AppProvider>(builder: (context, app, child) {
          return AlertDialog(
            title: Text(text),
            content: SingleSelectChip(
              data: data,
              onSelectionChanged: (selected) => onSelectedChanged(selected),
            ),
            actions: <Widget>[
              TextButton(child: Text("done".tr()), onPressed: onDonePressed),
            ],
          );
        });
      },
    );
  }

  _showCategoryDialog(
      List<String> selectedItems, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<CategoryProvider>(
            builder: (context, category, child) {
              List<Category> _categories = category.allCategories;
              return AlertDialog(
                title: Text("select_categories".tr()),
                content: MultiSelectChip(
                  _categories.map((c) => c.name).toList(),
                  onSelectionChanged: (selectedList) {
                    selectedCategoriesIds.clear();
                    setState(() {
                      selectedItems = selectedList;
                    });
                    _categories.forEach((c) {
                      selectedList.forEach((s) {
                        if (s == c.name) {
                          if (!selectedCategoriesIds.contains(c.id))
                            selectedCategoriesIds.add(c.id);
                        }
                      });
                    });
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("done".tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.text = selectedItems.join(",");
                    },
                  )
                ],
              );
            },
          );
        });
  }

  _previewIngredients(TextEditingController controller) {
    _previewIngredientsList.clear();
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(controller.value.text);
    for (var i = 0; i < lines.length; i++) {
      _previewIngredientsList.add(lines[i]);
    }
  }

  _previewSteps(TextEditingController controller) {
    _previewStepsList.clear();
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(controller.value.text);
    for (var i = 0; i < lines.length; i++) {
      _previewStepsList.add(lines[i]);
    }
  }
}
