import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:motion_sensors/motion_sensors.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _gyroscopeFrequency = 0;
  int _accelerometerFrequency = 0;
  int _userAccelerometerFrequency = 0;
  int _magnetometerFrequency = 0;
  int? _groupValue = 0;

  @override
  void initState() {
    print("INIT");
    super.initState();
    setUpdateInterval(0, Duration.microsecondsPerSecond ~/ 1);
    try {
      motionSensors.gyroscope
          .bufferTime(const Duration(seconds: 1))
          .listen((List<GyroscopeEvent> events) {
        setState(() {
          _gyroscopeFrequency = events.length;
        });
      });
      motionSensors.gyroscope.listen((event) {
        print("gyroscope timestamp: ${event.timestamp}");
      });
      print("NO");
    } catch (err) {
      print("ERR: $err");
    }
    motionSensors.accelerometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<AccelerometerEvent> events) {
      _accelerometerFrequency = events.length;
    });
    motionSensors.userAccelerometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<UserAccelerometerEvent> events) {
      _userAccelerometerFrequency = events.length;
    });
    motionSensors.magnetometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<MagnetometerEvent> events) {
      _magnetometerFrequency = events.length;
    });
    // motionSensors.isGyroscopeAvailable().then((value) {
    //   print("PRINT: $value");
    // });
  }

  void setUpdateInterval(int? groupValue, int interval) {
    print("interval: $interval");
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.magnetometerUpdateInterval = interval;
    setState(() {
      _groupValue = groupValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Motion Sensors'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Update Interval'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 1,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 1),
                  ),
                  Text("1 FPS"),
                  Radio(
                    value: 2,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 30),
                  ),
                  Text("30 FPS"),
                  Radio(
                    value: 3,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 60),
                  ),
                  Text("60 FPS"),
                ],
              ),
              ListTile(
                title: Text('Gyroscope: ${_gyroscopeFrequency}Hz'),
              ),
              ListTile(
                title: Text(
                    'User accelerometer: ${_userAccelerometerFrequency}Hz'),
              ),
              ListTile(
                title: Text('Magnetometer: ${_magnetometerFrequency}Hz'),
              ),
              ListTile(
                title: Text('Accelerometer: ${_accelerometerFrequency}Hz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
