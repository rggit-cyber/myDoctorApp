import 'package:flutter/material.dart';

class HelpDeskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HelpDesk")),
      body: Center(
        child: Text(
          "How can we assist you?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
