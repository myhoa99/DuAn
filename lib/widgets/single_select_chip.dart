import 'package:flutter/material.dart';

class SingleSelectChip extends StatefulWidget {
  final List data;
  final Function(int) onSelectionChanged;

  SingleSelectChip({this.data, this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<SingleSelectChip> {
  int selectedChoice = 0;

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.data.forEach((c) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(c.name),
          selected: selectedChoice == c.id,
          onSelected: (selected) {
            setState(() {
              selectedChoice = c.id;
              widget.onSelectionChanged(selectedChoice);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
