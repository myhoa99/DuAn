import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_recipes/config/app_config.dart';
import 'package:food_recipes/preferences/session_manager.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:food_recipes/providers/auth_provider.dart';
import 'package:food_recipes/screens/Tabs/tabs_screen.dart';
import 'package:food_recipes/services/api_repository.dart';
import 'package:food_recipes/size_config.dart';
import 'package:food_recipes/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SessionManager prefs = SessionManager();
  AppProvider application;
  bool _isRetrieving = true;
  bool _tryAgain = false;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    application = Provider.of<AppProvider>(context, listen: false);

    Future.delayed(Duration(seconds: 1), () {
      _checkWifi();
    });
  }

  _checkWifi() async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    bool connectedToWifi = (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile);
    if (!connectedToWifi) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showAlertDialog(
          context,
          title: 'No Internet Connection',
          description: 'Please Check Internet Connection',
          onPressed: () {
            Navigator.pop(context);
            _checkWifi();
          },
        ),
      );
    } else {
      _retrieveData();
    }
    if (_tryAgain != !connectedToWifi) {
      setState(() => _tryAgain = !connectedToWifi);
    }
  }

  Future _retrieveData() async {
    firebaseCloudMessagingListeners();

    await Provider.of<AppProvider>(context, listen: false).fetchSettings();
    await Provider.of<AppProvider>(context, listen: false).fetchLanguages();
    await Provider.of<AuthProvider>(context, listen: false).autoLogin();

    setState(() {
      _isRetrieving = false;
    });

    // showAlertDialog(
    //   context,
    //   title: 'Server Error',
    //   description: 'The server couldn\'t be reached',
    //   onPressed: () {
    //     Navigator.pop(context);
    //     _checkWifi();
    //   },
    // );
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print('Token: $token');
      ApiRepository.addDevice(token);
    });

    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage: $message');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('onMessageOpenedApp: $message');
    });
  }

  void iOSPermission() {
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Widget _loadingLayout(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              child: Image.asset(
                'assets/images/logo.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              width: double.infinity,
              height: double.infinity,
            ),
            // Center(
            //   child: Text(
            //     AppConfig.AppName,
            //     style: GoogleFonts.pacifico(fontSize: 26),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  _body() {
    return _isRetrieving ? _loadingLayout(context) : TabsScreen();
  }
}
