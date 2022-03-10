import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes/models/app_user.dart';
import 'package:food_recipes/preferences/session_manager.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/widgets/shimmer_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  final Function retrieveData;

  EditProfileScreen({this.retrieveData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = new GlobalKey<FormState>();

  SessionManager prefs = SessionManager();

  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FacebookLogin _facebookLogin = new FacebookLogin();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _resetOldPassController = TextEditingController();
  TextEditingController _resetNewPassController = TextEditingController();
  TextEditingController _resetNewConfPassController = TextEditingController();

  final _picker = ImagePicker();

  String image;

  File _image;
  bool _enabled = true;

  AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future chooseImage() async {
    var imageFile = await _picker.getImage(
        source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  _saveProfile() async {
    if (formKey.currentState.validate()) {
      AppUser _user = AppUser();
      _user.id = _authProvider.user.id;
      _user.name = _nameController.text.trim();
      _user.email = _emailController.text.trim();

      Provider.of<AuthProvider>(context, listen: false)
          .updateProfile(_user, _image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _body(),
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
        'my_profile'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
    );
  }

  _body() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (_nameController.text != auth.user.name) {
          _nameController.text = auth.user.name ?? '';
        }
        if (_emailController.text != auth.user.email) {
          _emailController.text = auth.user.email ?? '';
        }
        _passwordController.text = '***********';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  _buildUserImage(auth),
                  SizedBox(width: 25),
                  _buildUploadAndDeleteButton(),
                ],
              ),
              SizedBox(height: 50),
              _buildInformationFields(auth),
              SizedBox(height: 50),
              _buildSaveButton(),
            ],
          ),
        );
      },
    );
  }

  _buildUserImage(AuthProvider auth) {
    return (_image == null)
        ? (auth.user.image != null)
            ? (auth.user.image.contains('https'))
                ? CachedNetworkImage(
                    imageUrl: auth.user.image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                        ShimmerWidget(width: 100, height: 100, circular: true),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                : CachedNetworkImage(
                    imageUrl:
                        '${ApiRepository.USER_IMAGES_PATH}${auth.user.image}',
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                        ShimmerWidget(width: 100, height: 100, circular: true),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
            : CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset('assets/images/logo_user.png'),
                radius: 50,
              )
        : CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: FileImage(_image),
            radius: 50,
          );
  }

  _buildUploadAndDeleteButton() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                backgroundColor: Colors.grey[100]),
            child: Text('upload_new_image'.tr(),
                style: TextStyle(color: Colors.black)),
            onPressed: () async {
              if (await _googleSignIn.isSignedIn() ||
                  await _facebookLogin.isLoggedIn)
                Fluttertoast.showToast(msg: 'this_option_isnt_available'.tr());
              else
                chooseImage();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              backgroundColor: Colors.grey[100],
            ),
            child: Text('delete_image'.tr(),
                style: TextStyle(color: Colors.black)),
            onPressed: () async {
              if (await _googleSignIn.isSignedIn() ||
                  await _facebookLogin.isLoggedIn)
                Fluttertoast.showToast(msg: 'this_option_isnt_available'.tr());
              else
                Provider.of<AuthProvider>(context, listen: false)
                    .deleteUserImage(_authProvider.user.id);
              setState(() {
                image = null;
              });
            },
          )
        ],
      ),
    );
  }

  _buildInformationFields(AuthProvider auth) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          customTextField(context, _enabled, _nameController, 'name'.tr()),
          SizedBox(height: 10),
          customTextField(context, false, _emailController, 'email'.tr()),
          SizedBox(height: 10),
          customPassTextField(
              context, _enabled, _passwordController, 'password'.tr()),
        ],
      ),
    );
  }

  _buildSaveButton() {
    return SizedBox(
      width: 300,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(
          'save_changes'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        onPressed: _saveProfile,
      ),
    );
  }

  Widget customTextField(BuildContext context, bool enabled,
      TextEditingController controller, String label) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Raleway',
        fontSize: 17,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, fontFamily: 'Raleway'),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label ' + 'cannot_be_empty'.tr();
        }
        return null;
      },
    );
  }

  Widget customPassTextField(BuildContext context, bool enabled,
      TextEditingController controller, String label) {
    return TextField(
      enabled: enabled,
      obscureText: true,
      readOnly: true,
      showCursor: false,
      controller: controller,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Raleway',
        fontSize: 17,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, fontFamily: 'Raleway'),
        suffixIcon: IconButton(
          icon: Icon(Icons.edit, size: 25, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                contentPadding: EdgeInsets.only(bottom: 20),
                title: Text(
                  'change_password'.tr().toUpperCase(),
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
                        'please_enter_your_old_password'.tr(),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: customChangePassTextField(
                        context,
                        'old_password'.tr(),
                        Icon(Icons.lock, color: Theme.of(context).primaryColor),
                        true,
                        _resetOldPassController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: customChangePassTextField(
                        context,
                        'new_password'.tr(),
                        Icon(Icons.lock, color: Theme.of(context).primaryColor),
                        true,
                        _resetNewPassController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: customChangePassTextField(
                        context,
                        'confirm_new_password'.tr(),
                        Icon(Icons.mail, color: Theme.of(context).primaryColor),
                        true,
                        _resetNewConfPassController,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                      ),
                      onPressed: _resetPassword,
                      child: Text(
                        'reset'.tr().toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _resetPassword() async {
    if (_resetNewPassController.value.text ==
        _resetNewConfPassController.value.text) {
      await ApiRepository.updateUserPassword(
        _authProvider.user.id,
        _resetOldPassController.value.text,
        _resetNewPassController.value.text,
      ).then((value) {
        _resetOldPassController.clear();
        _resetNewPassController.clear();
        _resetNewConfPassController.clear();
        Navigator.pop(context);
      });
    } else {
      Fluttertoast.showToast(msg: 'password_doesnt_match'.tr());
    }
  }

  Widget customChangePassTextField(BuildContext context, String text, Icon icon,
      bool obscure, TextEditingController controller) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: Colors.black,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Raleway',
          fontSize: 17,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 1),
          prefixIcon: icon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          labelText: text,
          labelStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'Raleway',
            fontSize: 15,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
