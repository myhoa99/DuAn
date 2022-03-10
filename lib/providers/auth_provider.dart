import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/app_user.dart';
import '../services/api_repository.dart';
import '../utils/utils.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  AppUser _user;
  String _token;
  List<AppUser> _followingUsers = [];
  List<AppUser> _followerUsers = [];
  TextEditingController _registerEmailController = TextEditingController();
  final storage = new FlutterSecureStorage();

  Future autoLogin() async {
    String token = await storage.read(key: 'token');
    await tryToken(token: token);
    print('Stored token: $token');
  }

  bool get authenticated => _isLoggedIn;
  AppUser get user => _user;

  List<AppUser> get followingUsers => _followingUsers;
  List<AppUser> get followerUsers => _followerUsers;

  Future<bool> login({Map creds}) async {
    print(creds);

    try {
      http.Response response = await http.post(
        AppConfig.URL + '/api/sanctum/token',
        body: creds,
        headers: {"Accept": "application/json"},
      );
      print(response.body);
      print(response.statusCode);
      print(response.reasonPhrase);
      if (response.body.contains('errors')) {
        Fluttertoast.showToast(
            msg: 'the_provided_credentials_are_incorrect'.tr());
        _isLoggedIn = false;
      } else {
        String token = response.body.toString();
        await this.tryToken(token: token);
      }
      return this._isLoggedIn;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> loginUsingSocial(
      BuildContext context, AppUser user, String deviceName) async {
    http.Response response =
        await ApiRepository.loginUsingSocial(user, deviceName);
    print(response.body);
    String token = response.body.toString();
    await this.tryToken(context: context, token: token);
    return this._isLoggedIn;
  }

  Future<void> tryToken({BuildContext context, String token}) async {
    if (token == null) {
      return;
    } else {
      print(token);
      http.Response response = await ApiRepository.tryToken(token: token);
      Map data = json.decode(response.body);
      this._isLoggedIn = true;
      this._token = token;
      this._user = AppUser.fromJson(data);
      if (_user.email == null) await _askForEmail(context);
      this.storeToken(token: token);
      this.storeUser(user: this._user);
      notifyListeners();
    }
  }

  Future<String> updateProfile(AppUser user, File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppConfig.URL + '/api/users/${user.id}?_method=PUT'),
    );

    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    if (image != null) {
      request.files.add(
        http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: image.path.split('/').last,
        ),
      );
    }
    request.headers.addAll(headers);
    request.fields.addAll({'name': user.name, 'email': user.email});
    var res = await request.send();
    String resBody = await res.stream.bytesToString();
    Map response = json.decode(resBody);
    this._user = AppUser.fromJson(response['user']);
    this.storeUser(user: this._user);
    notifyListeners();
    if (resBody.contains('message')) {
      Fluttertoast.showToast(msg: response['message']);
    }
    return null;
  }

  Future _askForEmail(context) async {
    await showCustomDialogWithTitle(context,
        title: 'additional_info'.tr(),
        body: TextField(
          controller: _registerEmailController,
          style: TextStyle(
              color: Colors.black, fontFamily: 'Raleway', fontSize: 17),
          decoration: InputDecoration(
            labelText: 'email'.tr(),
            labelStyle: TextStyle(fontSize: 13, fontFamily: 'Raleway'),
          ),
        ), onTapSubmit: () async {
      if (_registerEmailController.text.isNotEmpty) {
        Navigator.pop(context);
        http.Response response = await ApiRepository.updateEmail(
            user.id, _registerEmailController.text);
        Map data = json.decode(response.body);
        print(response.body);
        this._user = AppUser.fromJson(data);
        this.storeUser(user: this._user);
        notifyListeners();
      }
    });
  }

  Future deleteUserImage(int id) async {
    http.Response response = await ApiRepository.deleteUserImage(id);
    Map data = json.decode(response.body);
    this._user = AppUser.fromJson(data);
    notifyListeners();
  }

  Future<void> getFollowingFollowers() async {
    try {
      http.Response response =
          await ApiRepository.fetchUserFollowingFollowers(_user.id);
      Map decodedResponse = json.decode(response.body);
      _followerUsers = List<AppUser>.from(
        decodedResponse['followers'].map((x) => AppUser.fromJson(x)),
      );
      _followingUsers = List<AppUser>.from(
        decodedResponse['following'].map((x) => AppUser.fromJson(x)),
      );
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void logout() async {
    try {
      print(_token);
      http.Response response = await http.get(
        AppConfig.URL + '/api/user/revoke',
        headers: {'Authorization': 'Bearer $_token'},
      );
      print(response.body);
      cleanUp();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void storeToken({String token}) async {
    this.storage.write(key: 'token', value: token);
  }

  void storeUser({AppUser user}) async {
    this.storage.write(key: 'user', value: json.encode(user.toJson()));
  }

  void cleanUp() async {
    this._user = null;
    this._isLoggedIn = false;
    this._token = null;
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');
  }
}
