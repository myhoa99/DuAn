import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomTextField extends StatelessWidget {
  final String text;
  final Icon icon;
  final bool obscure;
  final TextEditingController controller;

  const CustomTextField({
    this.text,
    this.icon,
    this.obscure,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure != null ? obscure : false,
        cursorColor: Colors.black,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Raleway',
          fontSize: 17,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 25, right: 25, top: 0, bottom: 0),
          errorStyle: TextStyle(fontSize: 10, height: 0.4),
          // contentPadding: EdgeInsets.symmetric(vertical: 1),
          prefixIcon: icon,
          focusedErrorBorder: InputBorder.none,
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          errorBorder: InputBorder.none,
          labelText: text,
          labelStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'Raleway',
            fontSize: 15,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$text ' + 'cannot_be_empty'.tr();
          }
          return null;
        },
      ),
    );
  }
}
