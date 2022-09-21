import 'package:flutter/material.dart';
import 'package:ambient_sensors/ambient_sensors.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _gyroscopeFrequency = 0;
  int _accelerometerFrequency = 0;
  int _userAccelerometerFrequency = 0;
  int _magnetometerFrequency = 0;
  int? _groupValue = 1;

  @override
  void initState() {
    super.initState();

    setUpdateInterval(1, Duration.microsecondsPerSecond ~/ 1);
    ambientSensors.gyroscope
        .bufferTime(const Duration(seconds: 1))
        .listen((List<GyroscopeEvent> events) {
      setState(() {
        _gyroscopeFrequency = events.length;
      });
    });
    ambientSensors.accelerometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<AccelerometerEvent> events) {
      _accelerometerFrequency = events.length;
    });
    ambientSensors.userAccelerometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<UserAccelerometerEvent> events) {
      _userAccelerometerFrequency = events.length;
    });
    ambientSensors.magnetometer
        .bufferTime(const Duration(seconds: 1))
        .listen((List<MagnetometerEvent> events) {
      _magnetometerFrequency = events.length;
    });
  }

  void setUpdateInterval(int? groupValue, int interval) {
    ambientSensors.accelerometerUpdateInterval = interval;
    ambientSensors.userAccelerometerUpdateInterval = interval;
    ambientSensors.gyroscopeUpdateInterval = interval;
    ambientSensors.magnetometerUpdateInterval = interval;
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
              const Text('Update Interval'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 1,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 1),
                  ),
                  const Text("1 FPS"),
                  Radio(
                    value: 2,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 30),
                  ),
                  const Text("30 FPS"),
                  Radio(
                    value: 3,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 60),
                  ),
                  const Text("60 FPS"),
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
