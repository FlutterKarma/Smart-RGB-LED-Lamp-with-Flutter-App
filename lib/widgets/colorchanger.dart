import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lampcontroler/utility/utilitys.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_circle_color_picker.dart';

class ColorChanger extends StatefulWidget {
  final String selectedDevice;
  final Color color;
  bool ispoweron = false;
  ColorChanger({this.color, this.selectedDevice});

  @override
  _ColorChangerState createState() => _ColorChangerState();
}

class _ColorChangerState extends State<ColorChanger> {
  Color currentColor = Colors.red;
  Color priviouscolore;
  bool firstUserInteraction;

  @override
  void initState() {
    firstUserInteraction = false;
    super.initState();
  }

  Future<void> getLastColor() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("lastColor${widget.selectedDevice}")) {
      int lastColor = prefs.getInt("lastColor${widget.selectedDevice}");
      setState(() {
        currentColor = Color(lastColor);
      });
    }
  }

  Icon getColorIcon() {
    if (!firstUserInteraction || firstUserInteraction == null) {
      getLastColor();
    }
    return Icon(Icons.bubble_chart, color: currentColor);
  }

  void setLastColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("lastColor${widget.selectedDevice}", color.value);
  }

  void changecolor(Color color) {
    setState(() => currentColor = color);
    // performance-issues
    //  setColor(color);
  }

  void turnDeviceOn() async {
    await getLastColor();
    setColor(currentColor, context, widget.selectedDevice);
    snackBarMessage(context, "Turned on ${widget.selectedDevice}");
  }

  void turnDeviceOff() async {
    try {
      var res = await http.post(
        Uri.http('${widget.selectedDevice}', '/colour'),
        body: {"r": "0", "g": "0", "b": "0"},
        //    headers: {"Content-type": "text/html"}
      );

      if (res.statusCode == 200) {
        snackBarMessage(context, "Turned off ${widget.selectedDevice}");
      } else {
        snackBarMessage(context, "Device Error");
      }
    } on SocketException {
      snackBarMessage(context, "Connection Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shuold use a FutureBuilder
    return CircleColorPicker(
      strokeWidth: 16,
      initialColor: currentColor,
      onChanged: _onColorChanged,
      widget: powerbutton(),
      colorCodeBuilder: (context, color) {
        return Text(
          'rgb(${color.red}, ${color.green}, ${color.blue})',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }

  void _onColorChanged(Color color) {
    setState(() => currentColor = color);
    if (priviouscolore == null) {
      setColor(currentColor, context, widget.selectedDevice);
      priviouscolore = currentColor;
    } else if (priviouscolore != currentColor) {
      print(currentColor);
      setColor(currentColor, context, widget.selectedDevice);
      priviouscolore = currentColor;
    }

    //  print(color);
  }

  Widget powerbutton() {
    return GestureDetector(
      onTap: () {
        if (widget.ispoweron) {
          turnDeviceOff();
          setState(() {
            widget.ispoweron = false;
          });
        } else {
          turnDeviceOn();
          setState(() {
            widget.ispoweron = true;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            child: SvgPicture.asset(
              "assets/powerbutton.svg",
              color: widget.ispoweron ? currentColor : Colors.black12,
              matchTextDirection: true,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            widget.ispoweron ? "TURN OFF" : "TURN ON",
            style: TextStyle(fontSize: 15, color: Colors.black38),
          )
        ],
      ),
    );
  }
}
