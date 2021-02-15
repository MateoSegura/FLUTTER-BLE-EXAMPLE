import 'dart:async';
import 'dart:convert' show utf8;
import 'package:ethanol_content_final_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'home.dart';

void main() {
  runApp(MainScreen());
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billet Motorsport Ethanol Content App',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          print(state);
          if (state == BluetoothState.on) {
            return MainPage();
          }
          return MainPage();
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ignore: non_constant_identifier_names
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String TARGET_DEVICE_NAME = "ESP32 BLE Example";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  StreamSubscription<ScanResult> scanSubScription;
  Stream<List<int>> stream;
  bool isConnected = false;

  @override
  void initState() {
    print("initialized");
    super.initState();
    startScan();
  }

  startScan() {
    print("Started Bluetooth Scan");
    scanSubScription =
        flutterBlue.scan().asBroadcastStream().listen((scanResult) {
      print(scanResult.device);
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;
    await targetDevice.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      isConnected = false;
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          print(characteristic.uuid.toString());
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value.asBroadcastStream();
            targetCharacteristic = characteristic;
            setState(() {
              isConnected = true;
            });
          }
        });
      }
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;
    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {
                if (isConnected == true) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StreamBuilder<List<int>>(
                        stream: stream,
                        builder: (context, snapshot) {
                          var currentValue;

                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');

                          if (snapshot.connectionState ==
                                  ConnectionState.active &&
                              snapshot.data.length > 0) {
                            currentValue = _dataParser(snapshot.data);
                            print(currentValue);
                          } else {
                            currentValue = null;
                          }
                          return SettingPopUp(
                            data: currentValue,
                          );
                        },
                      );
                    },
                  );
                }
              },
              elevation: 2.0,
              fillColor: Colors.grey[500],
              child: Icon(
                Icons.settings_outlined,
                color: Colors.black87,
                size: 35.0,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
            isConnected == true
                ? StreamBuilder<BluetoothDeviceState>(
                    stream: targetDevice.state,
                    initialData: BluetoothDeviceState.disconnected,
                    builder: (c, snapshot) {
                      return RawMaterialButton(
                        onPressed: () {
                          isConnected
                              ? disconnectFromDevice()
                              : connectToDevice();
                        },
                        elevation: 2.0,
                        fillColor: isConnected ? Colors.green : Colors.blue,
                        child: Icon(
                          Icons.bluetooth,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      );
                    })
                : RawMaterialButton(
                    onPressed: () {
                      isConnected ? disconnectFromDevice() : connectToDevice();
                    },
                    elevation: 2.0,
                    fillColor: isConnected ? Colors.green : Colors.blue,
                    child: Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
          ],
        ),
      ),
      body: Center(
        child: isConnected == true
            ? StreamBuilder<BluetoothDeviceState>(
                stream: targetDevice.state,
                initialData: BluetoothDeviceState.disconnected,
                builder: (c, snapshot) {
                  if (snapshot.data == BluetoothDeviceState.connected) {
                    isConnected = true;
                  } else if (snapshot.data ==
                      BluetoothDeviceState.disconnected) {
                    isConnected = false;
                  }
                  return Container(
                    child: isConnected == true
                        ? StreamBuilder<List<int>>(
                            stream: stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<int>> snapshot) {
                              var currentValue;
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');

                              if (snapshot.connectionState ==
                                      ConnectionState.active &&
                                  snapshot.data.length > 0) {
                                currentValue = _dataParser(snapshot.data);
                                print(currentValue);
                              } else {
                                currentValue = null;
                              }
                              return Home(
                                data: currentValue,
                              );
                            })
                        : Home(
                            data: null,
                          ),
                  );
                },
              )
            : Home(
                data: null,
              ),
      ),
    );
  }
}
