import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DefaultCustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const DefaultCustomButton({
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: context.locale == Locale('ar', 'AL') ? 10 : 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          primary: Theme.of(context).primaryColor,
        ),
        child: FittedBox(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
