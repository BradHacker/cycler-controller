import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

const UART_SERVICE = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
const TX_CHARACTERISTIC = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
const RX_CHARACTERISTIC = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
const CLIENT_UUID = '5A54CAB6-29BD-AA5A-30B1-8C5C164527AF';

FlutterBlue flutterBlue = FlutterBlue.instance;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycler Controller',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Cycler Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _connected = false;
  bool _scanning = false;
  String _statusMessage = 'Not Connected. Press search to find a Cycler.';
  StreamSubscription<ScanResult> _scanSubscription;
  BluetoothDevice _device;
  StreamSubscription<BluetoothDeviceState> _deviceConnection;
  List<BluetoothService> _deviceServices;
  BluetoothService _uartService;
  BluetoothCharacteristic _tx;
  BluetoothCharacteristic _rx;

  Map<DeviceIdentifier, ScanResult> scanResults = new Map();

  BluetoothState _state = BluetoothState.unknown;
  StreamSubscription _stateSubscription;

  BluetoothDeviceState _deviceState;
  StreamSubscription deviceStateSubscription;

  @override
  void initState() {
    super.initState();

    flutterBlue.setLogLevel(LogLevel.critical);
    flutterBlue.state.then((s) {
      setState(() {
        _state = s;
      });
    });

    _stateSubscription = flutterBlue.onStateChanged().listen((s) {
      setState(() {
        _state = s;
      });
    });
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  void _scanForCycler() {
    setState(() {
      _scanning = true;
    });

    _scanSubscription = flutterBlue.scan(
        timeout: Duration(seconds: 5),
        withServices: [Guid(UART_SERVICE)]).listen((scanResult) {
      if (scanResult.advertisementData.connectable &&
          scanResult.device.name != null) {
        setState(() {
          scanResults[scanResult.device.id] = scanResult;
        });
      }
    }, onDone: _cancelScanning);
  }

  void _cancelScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      _scanning = false;
    });
  }

  _connect(BluetoothDevice device) {
    setState(() {
      _deviceConnection =
          flutterBlue.connect(device).listen(null, onDone: _disconnect);
    });

    device.state.then((s) {
      setState(() {
        _deviceState = s;
      });
    });

    deviceStateSubscription = device.onStateChanged().listen((s) {
      setState(() {
        _deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        setState(() {
          _device = device;
          _connected = true;
          _statusMessage = 'Connected to Cycler';
        });
        _cancelScanning();
        _discoverServices();
      } else {
        print('Not Connected');
        print(s.toString());
      }
    });
  }

  _disconnect() {
    setState(() {
      _stateSubscription?.cancel();
      _stateSubscription = null;
      _scanSubscription?.cancel();
      _scanSubscription = null;
      _deviceConnection?.cancel();
      _deviceConnection = null;
      _connected = false;
      _device = null;
      _deviceServices = null;
    });
  }

  _discoverServices() async {
    setState(() {
      _statusMessage = 'Discovering device services';
    });
    List<BluetoothService> s = await _device.discoverServices();
    setState(() {
      _statusMessage = 'Services discovered';
      _deviceServices = s;
    });
    _findUART();
    // Future.delayed(Duration(milliseconds: 100), () {
    //   if (_deviceServices == null && _device != null) _discoverServices();
    // });
  }

  _findUART() {
    if (_deviceServices != null && _deviceServices.isNotEmpty) {
      _deviceServices.forEach((service) {
        //servicesList.add(Text(service.uuid.toString()));
        if (service.uuid.toString().toLowerCase() ==
            UART_SERVICE.toLowerCase()) {
          print('UART found');
          _uartService = service;
          service.characteristics.forEach((c) {
            if (c.uuid.toString().toLowerCase() ==
                TX_CHARACTERISTIC.toLowerCase()) {
              _tx = c;
              //_device.setNotifyValue(_tx, true);
              //_device.onValueChanged(_tx).listen(_txChanged);
              print('TX found');
            } else if (c.uuid.toString().toLowerCase() ==
                RX_CHARACTERISTIC.toLowerCase()) {
              _rx = c;
              _device.setNotifyValue(_rx, true);
              _device.onValueChanged(_rx).listen(_rxChanged);
              print('RX found');
            }
          });
        }
      });
    }
  }

  _rxChanged(List<int> values) {
    print('Incoming Data: ' + new String.fromCharCodes(values));
  }

  _txChanged(List<int> values) {
    print('Outgoing Data: ' + new String.fromCharCodes(values));
  }

  _buildDeviceListTiles() {
    return scanResults.values
        .map((r) => ListTile(
              title: Column(
                children: <Widget>[
                  Text((r.device.name.length > 0)
                      ? r.device.name
                      : r.device.id.toString()),
                ],
              ),
              onTap: () => _connect(r.device),
              // title: Text((r.device.name.length > 0)
              //     ? r.device.name.length
              //     : r.device.id.toString()),
            ))
        .toList();
  }

  _buildScanningButton() {
    if (_connected) {
      return new FloatingActionButton(
        child: new Icon(Icons.bluetooth_disabled),
        onPressed: _disconnect,
        backgroundColor: Colors.red,
      );
    }
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

  _sendTest() async {
    //print(_device.name);
    try {
      await _device.writeCharacteristic(_tx, 't'.codeUnits,
          type: CharacteristicWriteType.withResponse);
      //List<int> value = await _device.readCharacteristic(_rx);
      setState(() {});
    } catch (e) {
      print(e.toString());
      _statusMessage = 'Error Sending Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceList = new List<Widget>();
    var deviceView = new Stack(children: <Widget>[
      new Text(_statusMessage),
      new ListView(
        children: deviceList,
      )
    ]);
    if (scanResults.isNotEmpty) {
      deviceList.addAll(_buildDeviceListTiles());
    }

    var controls = new Column(
      children: <Widget>[
        Text(
          'Status: $_statusMessage',
          style: TextStyle(color: Colors.red, fontSize: 20),
        ),
        Text((_uartService != null)
            ? 'UART: ' + _uartService.uuid.toString()
            : 'UART: None'),
        Text((_tx != null) ? 'TX: ' + _tx.uuid.toString() : 'UART: None'),
        Text((_rx != null) ? 'RX: ' + _rx.uuid.toString() : 'UART: None'),
        MaterialButton(
          child: Text('Send Test'),
          color: Colors.amber,
          onPressed: _sendTest,
        )
      ],
    );

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        floatingActionButton: _buildScanningButton(),
        body: _connected ? controls : deviceView);
  }
}
