import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/category_provider.dart';
import 'package:food_recipes/providers/cuisine_provider.dart';
import 'package:food_recipes/providers/recipe_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'languages'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  _body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle(),
        _buildLanguagesList(context),
      ],
    );
  }

  _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Text(
        tr('select_language'),
        style: GoogleFonts.ubuntu(),
      ),
    );
  }

  _buildLanguagesList(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            _buildLanguageListItem(
              name: tr('english'),
              image: 'assets/images/flag_us.png',
              onTap: () {
                context.locale = Locale('en', 'US');
                _emptyLists();

              },
            ),
            _buildLanguageListItem(
              name: tr('french'),
              image: 'assets/images/flag_fr.png',
              onTap: () {
                context.locale = Locale('fr', 'FR');
                _emptyLists();
                setState(() {

                });
              },
            ),
            _buildLanguageListItem(
              name: tr('arabic'),
              image: 'assets/images/flag_ar.png',
              onTap: () {
                setState(() {
                  context.locale = Locale('ar', 'AL');

                });
                _emptyLists();

              },
            ),
            // _buildLanguageListItem(
            //   name: tr('languagename'),  //language name tanslated in the json files
            //   image: 'assets/images/icon.png',
            //   onTap: () {
            //     context.locale = Locale('code', 'country');
            //     _emptyLists();
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  _emptyLists() {
    Provider.of<RecipeProvider>(context, listen: false).emptyRecipeLists();
    Provider.of<CategoryProvider>(context, listen: false).emptyCategoryLists();
    Provider.of<CuisineProvider>(context, listen: false).emptyCuisineLists();
    Provider.of<AppProvider>(context, listen: false).emptyDifficultiesLists();
  }

  _buildLanguageListItem({Function onTap, String name, String image}) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          name,
          style: GoogleFonts.ubuntu(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: Image.asset(image, width: 35),
      ),
    );
  }
}
