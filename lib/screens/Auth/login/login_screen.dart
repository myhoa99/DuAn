import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/preferences/session_manager.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/providers/category_provider.dart';
import 'package:food_recipes/providers/cuisine_provider.dart';
import 'package:food_recipes/providers/recipe_provider.dart';
import 'package:food_recipes/screens/Auth/login/widgets/custom_divider.dart';
import 'package:food_recipes/screens/Auth/login/widgets/social_media_button.dart';
import 'package:food_recipes/screens/Auth/register/register_screen.dart';
import 'package:food_recipes/screens/Tabs/tabs_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/custom_text_field.dart';
import 'package:food_recipes/widgets/default_custom_button.dart';
import 'package:food_recipes/widgets/progress_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _loginEmailController = TextEditingController();
  TextEditingController _loginPasswordController = TextEditingController();
  TextEditingController _loginResetEmailController = TextEditingController();

  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FacebookLogin facebookLogin = new FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SessionManager prefs = SessionManager();
  AppProvider application;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String _deviceName;

  void initState() {
    super.initState();
    application = Provider.of<AppProvider>(context, listen: false);

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    getDeviceName();
  }

  void getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
      }
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    return Scaffold(
      body: _body(queryData),
    );
  }

  _body(MediaQueryData queryData) {
    return SingleChildScrollView(
      child: Container(
        height: queryData.size.height,
        child: Stack(
          children: <Widget>[
            _buildBackgroundImage(),
            _buildLoginScreen(queryData),
          ],
        ),
      ),
    );
  }

  _buildBackgroundImage() {
    return Container(
      child: Stack(children: [
        Image.asset(
          'assets/images/logo.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ]),
    );
  }

  _buildLoginScreen(MediaQueryData queryData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, TabsScreen.routeName),
              child: Text('skip'.tr().toUpperCase(),
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: queryData.size.width / 7),
            child: Column(
              children: [
                SizedBox(height: 30),
                CustomTextField(
                  text: 'email'.tr(),
                  icon: Icon(Icons.mail, color: Theme.of(context).primaryColor),
                  controller: _loginEmailController,
                ),
                SizedBox(height: 5),
                CustomTextField(
                  text: 'password'.tr(),
                  icon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                  obscure: true,
                  controller: _loginPasswordController,
                ),
                SizedBox(height: 10),
                DefaultCustomButton(
                  text: 'sign_in'.tr(),
                  onPressed: _signInUsingEmail,
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _showForgotPassDialog(),
                    child: AutoSizeText(
                      'forgot_password'.tr(),
                      minFontSize: 13,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _navigateToRegisterScreen(),
                  child: _noAccountText(),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    CustomDivider(),
                    Text('or'.tr(), style: TextStyle(fontFamily: 'Raleway')),
                    CustomDivider(),
                  ],
                ),
                _buildSocialButtons(),
                SizedBox(height: 20),
                _buildLanguagesIcons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _noAccountText() {
    return FittedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            'don\'t_have_an_account'.tr(),
            minFontSize: 13,
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          SizedBox(width: 4),
          AutoSizeText(
            'sign_up_now'.tr(),
            minFontSize: 13,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  _buildSocialButtons() {
    return Column(
      children: [
        SocialMediaButton(
          text: 'sign_in_with_google'.tr(),
          image: Image.asset('assets/images/ic_google.png', width: 25),
          color: Color(0xffdb4a39),
          function: signInUsingGoogle,
        ),
        SizedBox(height: 15),
        SocialMediaButton(
          text: 'sign_in_with_facebook'.tr(),
          image: Image.asset('assets/images/ic_facebook.png', width: 22),
          color: Color(0xff3b5998),
          function: signInUsingFacebook,
        ),
      ],
    );
  }

  _buildLanguagesIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _languageIconButton(
          'assets/images/flag_ar.png',
          () {
            context.locale = Locale('ar', 'AL');
            _emptyLists();
          },
        ),
        _languageIconButton(
          'assets/images/flag_fr.png',
          () {
            context.locale = Locale('fr', 'FR');
            _emptyLists();
          },
        ),
        _languageIconButton(
          'assets/images/flag_us.png',
          () {
            context.locale = Locale('en', 'US');
            _emptyLists();
          },
        ),
      ],
    );
  }

  _emptyLists() {
    Provider.of<RecipeProvider>(context, listen: false).emptyRecipeLists();
    Provider.of<CategoryProvider>(context, listen: false).emptyCategoryLists();
    Provider.of<CuisineProvider>(context, listen: false).emptyCuisineLists();
    Provider.of<AppProvider>(context, listen: false).emptyDifficultiesLists();
  }

  _languageIconButton(String image, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 55,
        child: Card(
          shape: CircleBorder(side: BorderSide(width: 0, color: Colors.white)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Image.asset(image, width: 40),
          ),
        ),
      ),
    );
  }

  _navigateToRegisterScreen() async {
    await Navigator.of(context)
        .pushNamed(RegisterScreen.routeName)
        .then((value) {
      setState(() {
        FocusScope.of(context).unfocus();
      });
    });
  }

  _showForgotPassDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.only(bottom: 20),
        title: Text(
          'reset_password'.tr(),
          style: TextStyle(fontSize: 16),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Text(
                'if_you_have_forgotten'.tr(),
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CustomTextField(
                text: 'email'.tr(),
                icon: Icon(Icons.mail, color: Theme.of(context).primaryColor),
                obscure: false,
                controller: _loginResetEmailController,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                await ApiRepository.resetPassword(
                        _loginResetEmailController.value.text)
                    .then((value) {
                  Fluttertoast.showToast(msg: '$value');
                  if (value == 'please_check_your_email'.tr())
                    Navigator.pop(context);
                });
              },
              child: Text('reset'.tr(), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  _navigateToTabsScreen() {
    Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
  }

  _signInUsingEmail() async {
    var _authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_loginEmailController.value.text.isNotEmpty &&
        _loginPasswordController.value.text.isNotEmpty) {
      await loadingDialog(context).show();

      if (EmailValidator.validate(_loginEmailController.value.text.trim())) {
        // new code
        var creds = {
          'email': _loginEmailController.text.trim(),
          'password': _loginPasswordController.text.trim(),
          'device_name': _deviceName ?? 'unknown',
        };

        bool authenticated = await _authProvider.login(creds: creds);

        await loadingDialog(context).hide();
        print(authenticated);

        if (authenticated) {
          _navigateToTabsScreen();
        }
        // _navigateToTabsScreen();
        // new code end

        // await ApiRepository.loginUser(
        //         context,
        //         _loginEmailController.value.text.trim(),
        //         _loginPasswordController.value.text.trim())
        //     .then((user) async {
        //   if (user.id != null) {
        //     prefs.saveUser(
        //       id: user.id,
        //       image: user.avatar,
        //       name: user.name,
        //       email: user.email,
        //     );
        //     application.addUserInfo(
        //       AppUser(
        //         id: user.id,
        //         avatar: user.avatar,
        //         email: user.email,
        //         name: user.name,
        //       ),
        //     );
        //     await loadingDialog(context).hide();
        //     _navigateToTabsScreen();
        //   } else {
        //     await loadingDialog(context).hide();
        //     Fluttertoast.showToast(
        //       msg: 'Wrong Email or Password!',
        //       toastLength: Toast.LENGTH_SHORT,
        //       timeInSecForIosWeb: 1,
        //     );
        //   }
        // });
      } else {
        await loadingDialog(context).hide();
        Fluttertoast.showToast(
          msg: 'invalid_email'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
        );
      }
    } else {
      await loadingDialog(context).hide();
      Fluttertoast.showToast(
        msg: 'invalid_input'.tr(),
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
      );
    }
  }

  signInUsingGoogle() async {
    try {
      loadingDialog(context).show();
      User firebaseUser;
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      print('access token: ${googleSignInAuthentication.accessToken}');
      firebaseUser = (await _auth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        AppUser _user = AppUser();
        _user.authKey = firebaseUser.uid;
        _user.name = firebaseUser.displayName;
        _user.email = firebaseUser.email;
        _user.image = firebaseUser.photoURL;

        bool authenticated =
            await Provider.of<AuthProvider>(context, listen: false)
                .loginUsingSocial(context, _user, _deviceName);

        await loadingDialog(context).hide();
        print(authenticated);

        if (authenticated) {
          _navigateToTabsScreen();
        }
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
      );
      loadingDialog(context).hide();
    }
  }

  signInUsingFacebook() async {
    loadingDialog(context).show();
    final FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        facebookLogin.currentAccessToken.then((accessToken) async {
          final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${accessToken.token}',
          );
          final user = await json.decode(graphResponse.body);

          AppUser _user = AppUser();
          _user.authKey = user['id'];
          _user.name = user['first_name'] + ' ' + user['last_name'];
          _user.email = user['email'];
          _user.image = user['picture']['data']['url'];

          bool authenticated =
              await Provider.of<AuthProvider>(context, listen: false)
                  .loginUsingSocial(context, _user, _deviceName);

          await loadingDialog(context).hide();
          print(authenticated);

          if (authenticated) {
            _navigateToTabsScreen();
          }
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancelled by user');
        loadingDialog(context).hide();
        break;
      case FacebookLoginStatus.error:
        print('error');
        print(facebookLoginResult.errorMessage);
        Fluttertoast.showToast(
          msg: facebookLoginResult.errorMessage,
          toastLength: Toast.LENGTH_LONG,
        );
        loadingDialog(context).hide();
        break;
    }
  }
}
