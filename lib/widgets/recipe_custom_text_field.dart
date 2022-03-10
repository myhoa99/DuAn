import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecipeCustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType textInputType;
  final TextInputFormatter textInputFormatter;

  const RecipeCustomTextField(
      {Key key,
      this.label,
      this.controller,
      this.textInputType,
      this.textInputFormatter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Raleway',
        fontSize: 17,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, fontFamily: 'Raleway'),
      ),
      inputFormatters: textInputFormatter != null
          ? <TextInputFormatter>[textInputFormatter]
          : null,
    );
  }
}
