import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:path_provider/path_provider.dart';

import 'notification_bloc.dart';

class NotificationService {
  /// We want singelton object of ``NotificationService`` so create private constructor
  /// Use NotificationService as ``NotificationService.instance``
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  /// For local_notification id
  int _count = 0;

  /// ``NotificationService`` started or not.
  /// to start ``NotificationService`` call start method
  bool _started = false;

  /// Call this method on startup
  /// This method will initialise notification settings
  void start(BuildContext context) {
    if (!_started) {
      _integrateNotification(context);
      _refreshToken();
      _started = true;
    }
  }

  // Call this method to initialize notification

  void _integrateNotification(BuildContext context) {
    _registerNotification(context);
    _initializeLocalNotification();
  }

  /// initialize firebase_messaging plugin
  void _registerNotification(BuildContext context) {
    _firebaseMessaging.requestPermission();

    /// App in foreground -> [onMessage] callback will be called
    /// App terminated -> Notification is delivered to system tray. When the user clicks on it to open app [onLaunch] fires
    /// App in background -> Notification is delivered to system tray. When the user clicks on it to open app [onResume] fires

    FirebaseMessaging.onMessage.listen((message) {
      _onMessage(message);
      _handleNotification(context, message.data, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {

      _onLaunch(message);
    });

    _firebaseMessaging.onTokenRefresh
        .listen(_tokenRefresh, onError: _tokenRefreshFailure);
  }

  /// Token is unique identity of the device.
  /// Token is required when you want to send notification to particular user.
  Future<void> _refreshToken() async {

    _firebaseMessaging.getToken().then((token) async {
      print('Firebase Token: $token');
      //   ApiRepository.setDeviceToken(user.id, token);
    }, onError: _tokenRefreshFailure);
    // }
  }

  /// This method will be called when device token get refreshed
  void _tokenRefresh(String newToken) async {}

  void _tokenRefreshFailure(error) {
    print("FCM token refresh failed with error $error");
  }

  /// This method will be called on tap of the notification which came when app was in foreground
  ///
  /// Firebase messaging does not push notification in notification panel when app is in foreground.
  /// To send the notification when app is in foreground we will use flutter_local_notification
  /// to send notification which will behave similar to firebase notification
  Future<void> _onMessage(RemoteMessage message) async {

    try {
      if (UniversalPlatform.isIOS) {
        message = _modifyNotificationJson(message.data);
      }
    } catch (e) {
      print(e);
    }

    _showNotification(
      {
        "title": message.notification.title,
        "body": message.notification.body,
        "data": message.data,
        "image":message.notification.android.imageUrl,
      },
    );
  }

  /// This method will be called on tap of the notification which came when app was closed
  Future<void> _onLaunch(RemoteMessage message) {
    print('onLaunch: $message');
    try {
      if (UniversalPlatform.isIOS) {
        message = _modifyNotificationJson(message.data);
      }
    } catch (e) {
      print(e);
    }
    _performActionOnNotification(message);
    return null;
  }

  _handleNotification(BuildContext context, data, bool push) {
    var messageJson = json.decode(data['message']);
    print('decoded message: $messageJson');
    // var message = m.Message.fromJson(messageJson);
    // Provider.of<ConversationProvider>(context, listen: false)
    //     .addMessageToConversation(message.conversationId, message);
  }

  /// This method will modify the message format of iOS Notification Data
  RemoteMessage _modifyNotificationJson(message) {
    message['data'] = Map.from(message ?? {});
    message['notification'] = message['aps']['alert'];
    print("aBBBB ${message}");
    return message;
  }

  /// We want to perform same action of the click of the notification. So this common method will be called on
  /// tap of any notification (onLaunch / onMessage / onResume)
  void _performActionOnNotification(message) {
    NotificationsBloc.instance.newNotification(message);
    print("VBBBB ${message}");

  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  /// used for sending push notification when app is in foreground
  void _showNotification(message) async {

    final imageLarge = await _downloadAndSaveFile(message['image'], "largeIcon");
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageLarge),
     );

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Notification Test',
      'Notification Test',
      '',
      styleInformation: bigPictureStyleInformation
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      ++_count,
      message['title'],
      message['body'],
      platformChannelSpecifics,
      payload: json.encode(
        message['data'],
      ),
    );
  }

  /// initialize flutter_local_notification plugin
  void _initializeLocalNotification() {
    // Settings for Android
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Settings for iOS
    var iosInitializationSettings = new IOSInitializationSettings();
    _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onSelectNotification: _onSelectLocalNotification,
    );
  }

  /// This method will be called on tap of notification pushed by flutter_local_notification plugin when app is in foreground
  Future _onSelectLocalNotification(String payLoad) {
    Map data = json.decode(payLoad);
    Map<String, dynamic> message = {
      "data": data,
    };
    print('we pressed on the notification');

    _performActionOnNotification(message);
    return null;
  }
}
