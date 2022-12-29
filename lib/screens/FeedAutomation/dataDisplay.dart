import 'package:flutter/material.dart';

class DataDisplayPage extends StatelessWidget {
  final String info;
  const DataDisplayPage({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body : Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(child: Text(info, style: TextStyle(fontSize: 34, color: Colors.white),)),
      ),

    );
  }
}