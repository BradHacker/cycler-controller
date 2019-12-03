import 'package:flutter/material.dart';

import 'cycler.dart';

class DPad extends StatelessWidget {
  final Function onPressed;
  final Function onReleased;

  const DPad({this.onPressed, this.onReleased});

  @override
  Widget build(BuildContext build) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.LEFT_PRESS),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.DRIVE_LETGO),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_back),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.UP_PRESS),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.DRIVE_LETGO),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_upward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.DOWN_PRESS),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.DRIVE_LETGO),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_downward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Listener(
                      onPointerDown: (PointerDownEvent details) =>
                          onPressed(details, Cycler.RIGHT_PRESS),
                      onPointerUp: (PointerUpEvent details) =>
                          onReleased(details, Cycler.DRIVE_LETGO),
                      child: MaterialButton(
                        child: Icon(Icons.arrow_forward),
                        color: Cycler.WM_YELLOW,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}
