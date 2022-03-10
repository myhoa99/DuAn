import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class RequestHelper {
  var token;

  static const API = AppConfig.URL + '/api/';

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token') != null
        ? jsonDecode(localStorage.getString('token'))['token']
        : '';
  }

  postData(data, endpoint) async {
    return await http.post(API + endpoint,
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(endpoint) async {
    await _getToken();
    return await http.get(API + endpoint, headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

}
