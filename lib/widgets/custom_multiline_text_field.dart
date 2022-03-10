import 'package:flutter/material.dart';

class CustomMultiLineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function function;

  const CustomMultiLineTextField({
    Key key,
    this.label,
    this.controller,
    this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style:
          TextStyle(color: Colors.black, fontFamily: 'Raleway', fontSize: 17),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: function,
          icon: Icon(Icons.remove_red_eye),
        ),
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, fontFamily: 'Raleway'),
        alignLabelWithHint: true,
      ),
    );
  }
}
