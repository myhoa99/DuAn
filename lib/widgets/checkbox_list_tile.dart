import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckBoxListTile extends StatelessWidget {
  final BuildContext context;
  final int index;
  final List items;

  const CheckBoxListTile({Key key, this.context, this.index, this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: false,
      dense: true,
      onChanged: null,
      controlAffinity: ListTileControlAffinity.leading,
      title: AutoSizeText(
        items[index],
        style: GoogleFonts.lato(
          fontSize: 14.5,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        maxLines: 2,
      ),
    );
  }
}
