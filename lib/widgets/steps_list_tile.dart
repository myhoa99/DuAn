import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepsListTile extends StatelessWidget {
  final BuildContext context;
  final int index;
  final List items;

  const StepsListTile({Key key, this.context, this.index, this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: <Widget>[
          Text(
            '${index + 1}.',
            style: GoogleFonts.pacifico(
              fontSize: 14.5,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              items[index],
              style: GoogleFonts.lato(
                fontSize: 14.5,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
