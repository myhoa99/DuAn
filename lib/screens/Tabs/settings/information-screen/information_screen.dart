import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:food_recipes/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatefulWidget {
  final String information;

  const InformationScreen({Key key, this.information}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  String _information;
  AppProvider _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _application = Provider.of<AppProvider>(context, listen: false);

    if (widget.information == tr('privacy_policy')) {
      _information = _application.settings.privacyPolicy;
    } else if (widget.information == tr('terms_and_conditions')) {
      _information = _application.settings.termsAndConditions;
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        widget.information,
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: !_isLoading
          ? Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: _information != null
                  ? Container(
                      child: Html(
                        data: _information,
                        shrinkWrap: true,
                        onLinkTap: (url) async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        style: {
                          "body": Style(
                            textAlign: TextAlign.justify,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.normal,
                          ),
                        },
                        onImageTap: (src) async {
                          if (await canLaunch(src)) {
                            await launch(src);
                          } else {
                            throw 'Could not launch $src';
                          }
                        },
                      ),
                    )
                  : Container(
                      height: 450,
                      child: Center(
                        child: Text(
                          'No Privacy Policy Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
