import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a New Account'),
        centerTitle: true,
      ),
      body: Container(alignment: Alignment.center,
      child: AnimatedContainer(
        height: 400,
        width: 340,
      )),
    );
  }
}