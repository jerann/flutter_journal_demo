import 'package:flutter/material.dart';

class CoolRoundedButton extends StatefulWidget {
  Widget child = Container();
  Color color = Colors.white;
  Function onPressed = () {
    print('No action set for CoolRoundedButton');
  };
  double height = 36;

  CoolRoundedButton({this.child, this.height, this.color, this.onPressed});
  
  _CoolRoundedButtonState createState() => _CoolRoundedButtonState();
}

class _CoolRoundedButtonState extends State<CoolRoundedButton> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 6),
      child: new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        elevation: 6.0,
        height: widget.height,
        color: widget.color,
        child: widget.child,
        onPressed: () {
            widget.onPressed();
        },
      ),
    );
  }
}