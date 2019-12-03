import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'cycler.dart';
import 'controls.dart';

const UART_SERVICE = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
const TX_CHARACTERISTIC = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
const RX_CHARACTERISTIC = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
const CLIENT_UUID = '5A54CAB6-29BD-AA5A-30B1-8C5C164527AF';

FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycler 2.0',
      theme: ThemeData(
        primarySwatch: Cycler.WM_GREEN,
      ),
      home: MyHomePage(title: 'Cycler 2.0'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _connected = false;
  bool _scanning = false;
  bool _bluetoothIsOn = false;
  String _statusMessage = 'Disconnected';
  StreamSubscription<List<ScanResult>> _scanSubscription;
  BluetoothDevice _device;
  StreamSubscription<BluetoothDeviceState> _deviceConnection;
  List<BluetoothService> _deviceServices;
  // BluetoothService _uartService;
  BluetoothCharacteristic _tx;
  BluetoothCharacteristic _rx;

  Map<DeviceIdentifier, ScanResult> scanResults = new Map();

  BluetoothState _state = BluetoothState.unknown;
  StreamSubscription _stateSubscription;

  BluetoothDeviceState _deviceState;
  StreamSubscription deviceStateSubscription;

  double _angle = 90;
  // double _leftSpeed = 0;
  // double _rightSpeed = 0;

  @override
  void initState() {
    super.initState();

    // flutterBlue.setLogLevel(LogLevel.critical);

    _stateSubscription = flutterBlue.state.listen((s) {
      setState(() {
        _state = s;
      });
      _updateBluetoothState();
    });
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  void _updateBluetoothState() {
    flutterBlue.isOn.then((isOn) {
      setState(() {
        _bluetoothIsOn = isOn;
      });
    });
  }

  void _scanForCycler() async {
    if (_bluetoothIsOn) {
      setState(() {
        _scanning = true;
      });

      if (_scanSubscription != null) await flutterBlue.stopScan();

      flutterBlue.startScan(
          timeout: Duration(seconds: 30),
          withServices: [Guid(UART_SERVICE)]).whenComplete(() {
        _cancelScanning();
      });

      _scanSubscription = flutterBlue.scanResults.listen((scanResult) {
        scanResult.forEach((result) {
          if (result.advertisementData.connectable &&
              result.device.name != null) {
            setState(() {
              scanResults[result.device.id] = result;
            });
          }
        });
      });
    } else {
      _updateBluetoothState();
    }
  }

  _cancelScanning() {
    flutterBlue.stopScan().then((stoppedScan) {
      setState(() {
        _scanSubscription = null;
        _scanning = false;
        _statusMessage = 'No Cyclers found';
      });
    });
  }

  _connect(BluetoothDevice device) async {
    setState(() {
      _statusMessage = '1/3 Connecting...';
    });
    await device.connect();

    deviceStateSubscription = device.state.listen((s) {
      setState(() {
        _deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        setState(() {
          _device = device;
          _statusMessage = '1/3 Connected';
        });
        _cancelScanning();
        _discoverServices();
      } else if (s == BluetoothDeviceState.disconnected) {
        _disconnect();
      } else {
        print('Not Connected');
        print(s.toString());
        setState(() {
          _statusMessage = 'Not Connected';
        });
      }
    });
  }

  _disconnect() async {
    if (_stateSubscription != null) await _stateSubscription.cancel();
    if (_scanSubscription != null) await _scanSubscription.cancel();
    if (_deviceConnection != null) await _deviceConnection.cancel();
    if (deviceStateSubscription != null) await deviceStateSubscription.cancel();

    setState(() {
      _stateSubscription = null;
      _scanSubscription = null;
      _deviceConnection = null;
      _connected = false;
      _device = null;
      _deviceServices = null;
    });
  }

  _discoverServices() async {
    setState(() {
      _statusMessage = '2/3 Discovering Services...';
    });
    List<BluetoothService> s = await _device.discoverServices();
    setState(() {
      _statusMessage = '2/3 Services retrieved';
      _deviceServices = s;
    });
    _findUART();
  }

  _findUART() {
    setState(() {
      _statusMessage = '3/3 Parsing Services...';
    });
    if (_deviceServices != null && _deviceServices.isNotEmpty) {
      _deviceServices.forEach((service) {
        //servicesList.add(Text(service.uuid.toString()));
        if (service.uuid.toString().toLowerCase() ==
            UART_SERVICE.toLowerCase()) {
          setState(() {
            _statusMessage = '3/3 UART Service Found';
          });
          service.characteristics.forEach((c) {
            if (c.uuid.toString().toLowerCase() ==
                TX_CHARACTERISTIC.toLowerCase()) {
              _tx = c;
              setState(() {
                _statusMessage = '3/3 TX Service Found';
              });
            } else if (c.uuid.toString().toLowerCase() ==
                RX_CHARACTERISTIC.toLowerCase()) {
              _rx = c;
              _rx.setNotifyValue(true);
              _rx.value.listen(_rxChanged);
              setState(() {
                _statusMessage = '3/3 RX Service Found';
              });
            }

            if (_tx != null && _rx != null) {
              setState(() {
                _connected = true;
                _statusMessage = 'Ready';
              });
            }
          });
        }
      });
    }
  }

  _rxChanged(List<int> values) {
    print('Incoming Data: ' + new String.fromCharCodes(values));
  }

  _buildDeviceListTiles() {
    return scanResults.values
        .map((r) => ListTile(
              title: Column(
                children: <Widget>[
                  Text(
                    (r.device.name.length > 0)
                        ? r.device.name
                        : r.device.id.toString(),
                    textAlign: TextAlign.center,
                    style: Cycler.TEXT_RESULTS,
                  ),
                ],
              ),
              onTap: () => _connect(r.device),
            ))
        .toList();
  }

  _buildScanningButton() {
    if (_scanning) {
      return new FloatingActionButton(
        child: new Icon(Icons.stop),
        onPressed: _cancelScanning,
        backgroundColor: Colors.red,
      );
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.search), onPressed: _scanForCycler);
    }
  }

  void _pressButton(PointerDownEvent details, String code) async {
    try {
      await _tx.write(code.codeUnits, withoutResponse: true);
    } catch (e) {
      print(e.toString());
      setState(() {
        _statusMessage = 'Data Error (' + code + ')';
      });
    }
  }

  void _letgoButton(PointerUpEvent details, String code) async {
    try {
      await _tx.write(code.codeUnits, withoutResponse: true);
    } catch (e) {
      print(e.toString());
      setState(() {
        _statusMessage = 'Data Error (' + code + ')';
      });
    }
  }

  _headAngle(double headAngle) async {
    _angle = headAngle;
    try {
      await _tx.write('H_${headAngle.toInt().toString().padLeft(3)}'.codeUnits,
          withoutResponse: true);
    } catch (e) {
      print(e.toString());
      setState(() {
        _statusMessage = 'Data Error (Head Angle)';
      });
    }
  }

  // _driveLeg(String side, double speed) async {
  //   try {
  //     await _tx.write((side + speed.toInt().toString().padLeft(4)).codeUnits,
  //         withoutResponse: true);
  //   } catch (e) {
  //     print(e.toString());
  //     setState(() {
  //       _statusMessage = 'Drive Error';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var deviceList = new List<Widget>();
    var deviceView = new ListView(
      children: deviceList,
    );
    if (scanResults.isNotEmpty) {
      deviceList.add(ListTile(
          title: Text('Tap on a Cycler device below to connect',
              textAlign: TextAlign.center, style: Cycler.TEXT_NORMAL)));
      deviceList.addAll(_buildDeviceListTiles());
    } else {
      if (_bluetoothIsOn) {
        deviceList.add(ListTile(
            title: Text(
                _scanning
                    ? 'Scanning for Cycler...'
                    : 'Tap the search button to begin scanning for Cycler',
                textAlign: TextAlign.center,
                style: Cycler.TEXT_NORMAL)));
        if (_scanning) {
          deviceList.add(ListTile(
            title: SpinKitWave(
                color: Cycler.WM_GREEN, type: SpinKitWaveType.start),
          ));
        }
      } else {
        deviceList.add(ListTile(
            title: Text(
          'Please turn on bluetooth to allow your device to connect to Cycler',
          textAlign: TextAlign.center,
          style: Cycler.TEXT_ERROR,
        )));
      }
    }

    var controls = Controls(
      onHeadChange: (headAngle) {
        setState(() => _angle = headAngle);
      },
      onHeadChangeEnd: (headAngle) {
        setState(() => _headAngle(headAngle));
      },
      onPressed: _pressButton,
      onReleased: _letgoButton,
      headAngle: _angle,
    );

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title + " - " + _statusMessage),
          centerTitle: true,
          leading: _connected
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _disconnect(),
                )
              : null,
        ),
        floatingActionButton:
            _bluetoothIsOn && !_connected ? _buildScanningButton() : null,
        body: _connected ? controls : deviceView);
    // body: controls);
  }
}
