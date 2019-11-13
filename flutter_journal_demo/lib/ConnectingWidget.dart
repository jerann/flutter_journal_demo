import 'package:flutter/material.dart';
import 'dart:math';

class ConnectingWidget extends StatefulWidget {

  Color color = Colors.white;

  ConnectingWidget({this.color});

  @override
  State<StatefulWidget> createState() {
    return _ConnectingWidgetState();
  }
}

class _ConnectingWidgetState extends State<ConnectingWidget> with TickerProviderStateMixin {

  Animation<double> _rotateAnimation;
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        duration: new Duration(milliseconds: 3000),
        vsync: this
    );

    _rotateAnimation = new Tween(begin: 0.0, end: -(pi * 2)).animate(_controller)
      ..addListener(() {
        setState(() {
//        print("STATE: ${_rotateAnimation.value}");
        });
      });

    _rotateAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(angle: _rotateAnimation.value,
      child: Icon(
          Icons.cached,
          color: widget.color,
          size: 34
      ),
    );
  }
}