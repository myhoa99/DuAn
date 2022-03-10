import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDeletedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function function;
  final Function onDelete;

  const CustomDeletedTextField({
    Key key,
    this.controller,
    this.label,
    this.function,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            showCursor: false,
            controller: controller,
            style: TextStyle(
                color: Colors.black, fontFamily: 'Raleway', fontSize: 17),
            onTap: function,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontSize: 13, fontFamily: 'Raleway'),
            ),
          ),
        ),
        controller.text.isNotEmpty
            ? InkWell(
                onTap: onDelete,
                child: Icon(Icons.close, color: Theme.of(context).primaryColor),
              )
            : Container(),
      ],
    );
  }
}
