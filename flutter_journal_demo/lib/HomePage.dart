import 'package:flutter/material.dart';
import 'package:flutter_journal_demo/CoolRoundedButton.dart';
import 'package:flutter_journal_demo/FirebaseWrapper.dart';
import 'package:flutter_journal_demo/LoginPage.dart';

class HomePage extends StatefulWidget {
  HomePage({this.userId});

  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StatusState editingState = StatusState.idle;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  void _fetchUserPosts() async {
    //Retrieve all posts for this user from Firebase
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
