import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void snackBarMessage(BuildContext context, String message) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

void setColor(Color color, BuildContext context, String selectedDevice) async {
  try {
    var res = await http.post(
      Uri.http('$selectedDevice', '/colour'),
      body: {
        "r": color.red.toString(),
        "g": color.green.toString(),
        "b": color.blue.toString()
      },

      //  headers: {  "Content-type": "text/html"}
    );
    if (res.statusCode != 200) {
      snackBarMessage(context, "Device Error setting color");
    }
  } catch (e) {
    print(e);
    snackBarMessage(context, "Connection Error");
  }
}
