import 'package:flutter/material.dart';

import 'cycler.dart';

class PeripheralControl extends StatelessWidget {
  final Function onPressed;
  final Function onReleased;
  final Function onHeadChange;
  final Function onHeadChangeEnd;
  final double headAngle;

  const PeripheralControl(
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
    return Expanded(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.LEFT_ARM_UP),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.LEFT_ARM_STP),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_upward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.RIGHT_ARM_UP),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.RIGHT_ARM_STP),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_upward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                ),
                Slider(
                  activeColor: Cycler.WM_YELLOW,
                  min: 0,
                  max: 180,
                  onChangeEnd: onHeadChangeEnd,
                  value: headAngle,
                  divisions: 6,
                  onChanged: onHeadChange,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.LEFT_ARM_DOWN),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.LEFT_ARM_STP),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_downward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.RIGHT_ARM_DOWN),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.RIGHT_ARM_STP),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_downward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
