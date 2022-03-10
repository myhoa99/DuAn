import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  SearchTextField({this.controller, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          suffixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          hintText: tr('search_here'),
          hintStyle: GoogleFonts.pacifico(
              color: Colors.black54, fontWeight: FontWeight.w100),
          contentPadding: EdgeInsets.only(
            left: 16,
            right: 20,
            top: 10,
            bottom: 10,
          ),
        ),
      ),
    );
  }
}
