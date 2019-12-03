import 'package:cycler_controller/armcontrol.dart';
import 'package:cycler_controller/dpad.dart';
import 'package:flutter/material.dart';

class Controls extends StatelessWidget {
  final Function onPressed;
  final Function onReleased;
  final Function onHeadChange;
  final Function onHeadChangeEnd;
  final double headAngle;

  const Controls(
      {this.onPressed,
      this.onReleased,
      this.onHeadChange,
      this.onHeadChangeEnd,
      this.headAngle})
      : assert(onPressed != null),
        assert(onReleased != null),
        assert(onHeadChange != null),
        assert(onHeadChangeEnd != null),
        assert(headAngle >= 0 && headAngle <= 180);

  @override
  Widget build(BuildContext build) {
    return Container(
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          PeripheralControl(
            onPressed: onPressed,
            onReleased: onReleased,
            onHeadChange: onHeadChange,
            onHeadChangeEnd: onHeadChangeEnd,
            headAngle: headAngle,
          ),
          DPad(
            onPressed: onPressed,
            onReleased: onReleased,
          ),
        ]));
  }
}
