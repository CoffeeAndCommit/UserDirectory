import 'package:flutter/material.dart';
class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}
class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test')));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Test')));
}
