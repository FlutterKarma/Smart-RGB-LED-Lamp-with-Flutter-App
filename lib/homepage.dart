import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutter_circle_color_picker.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Color _currentColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: _currentColor,
      body: Center(
        child: CircleColorPicker(
          strokeWidth: 16,
          initialColor: _currentColor,
          onChanged: _onColorChanged,
        ),
      ),
    );
  }

  void _onColorChanged(Color color) {
    setState(() => _currentColor = color);
  }
}
