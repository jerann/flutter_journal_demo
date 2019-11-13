import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_journal_demo/FirebaseWrapper.dart';

class HomePage extends StatefulWidget {
  HomePage({this.userId});

  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _disconnect();
              Navigator.pushReplacementNamed(context, "/login");
            }),
        title: Text('Your Flutter Jounal'),
        centerTitle: true,
      ),
      body: _bodyWidget(),
    );
  }

  Future<bool> _disconnect() async {
    await FirebaseWrapper().signOut();
    return true;
  }

  Widget _bodyWidget() {
    return Container(alignment: Alignment.center, child: Text(widget.userId));
  }
}
