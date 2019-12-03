import 'package:flutter/material.dart';

class Cycler {
  static const TEXT_NORMAL =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: WM_GREEN);
  static const TEXT_ERROR =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
  static const TEXT_RESULTS =
      TextStyle(fontSize: 20, fontWeight: FontWeight.normal);

  static const UP_PRESS = 'FORWA';
  static const DOWN_PRESS = 'BACKW';
  static const LEFT_PRESS = 'DRIVL';
  static const RIGHT_PRESS = 'DRIVR';
  static const DRIVE_LETGO = 'DSTOP';

  static const LEFT_ARM_UP = 'AL_UP';
  static const LEFT_ARM_DOWN = 'ALDWN';
  static const LEFT_ARM_STP = 'ALSTP';

  static const RIGHT_ARM_UP = 'AR_UP';
  static const RIGHT_ARM_DOWN = 'ARDWN';
  static const RIGHT_ARM_STP = 'ARSTP';

  static const MAX_SPEED = 2.0;

  static const Map<int, Color> WM_GREEN_SWATCH = {
    50: Color.fromRGBO(2, 105, 55, .1),
    100: Color.fromRGBO(2, 105, 55, .2),
    200: Color.fromRGBO(2, 105, 55, .3),
    300: Color.fromRGBO(2, 105, 55, .4),
    400: Color.fromRGBO(2, 105, 55, .5),
    500: Color.fromRGBO(2, 105, 55, .6),
    600: Color.fromRGBO(2, 105, 55, .7),
    700: Color.fromRGBO(2, 105, 55, .8),
    800: Color.fromRGBO(2, 105, 55, .9),
    900: Color.fromRGBO(2, 105, 55, 1),
  };

  static const MaterialColor WM_GREEN =
      MaterialColor(0xFF026937, WM_GREEN_SWATCH);

  static const Map<int, Color> WM_YELLOW_SWATCH = {
    50: Color.fromRGBO(237, 170, 0, .1),
    100: Color.fromRGBO(237, 170, 0, .2),
    200: Color.fromRGBO(237, 170, 0, .3),
    300: Color.fromRGBO(237, 170, 0, .4),
    400: Color.fromRGBO(237, 170, 0, .5),
    500: Color.fromRGBO(237, 170, 0, .6),
    600: Color.fromRGBO(237, 170, 0, .7),
    700: Color.fromRGBO(237, 170, 0, .8),
    800: Color.fromRGBO(237, 170, 0, .9),
    900: Color.fromRGBO(237, 170, 0, 1),
  };

  static const MaterialColor WM_YELLOW =
      MaterialColor(0xFFEDAA00, WM_YELLOW_SWATCH);
}
