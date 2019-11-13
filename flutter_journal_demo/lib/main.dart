import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'LoginPage.dart';
import 'RegisterPage.dart';
import 'HomePage.dart';

void main() => runApp(FlutterJournalDemo());

class FlutterJournalDemo extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Journal Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(),
          '/login': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
        });
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  TextStyle loadTextStyle = TextStyle(fontSize: 24);

  @override
  void initState() {
    super.initState();

    //Check our FirebaseAuth for a user
    //For web, we have to use a different package
    if (kIsWeb) {
      if (mounted) {
        var _ = Timer(Duration(seconds: 2), () {
          print('Web build detected, going to login page');
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } else {
      FirebaseAuth.instance.currentUser().then((user) {
        if (user == null) {
          //If there's no authorized user yet, direct to LoginPage
          var _ = Timer(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
        } else {
          //TODO for now
          var _ = Timer(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
          print('Found user');

//          //If there is a current user, get their info and forward it to 'HomePage'
//          Firestore.instance
//              .collection('users')
//              .document(user.uid)
//              .get()
//              .then((userInfo) {
//            //Because we're using a different 'HomePage' constructor w/ userId...
//            //We have to construct a different MaterialPageRoute for the Navigator
//            var _ = Timer(Duration(seconds: 2), () {
//              Navigator.pushReplacement(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) => HomePage(userId: user.uid)));
//            });
//          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: Text(
              'Welcome!',
              style: loadTextStyle,
            )));
  }
}
