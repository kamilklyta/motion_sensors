# ambient_sensors

Flutter plugin for accessing the Android and iOS accelerometer, user accelerometer, gyroscope and magnetometer sensors.

## Getting Started

``` dart
import 'package:ambient_sensors/ambient_sensors.dart';

motionSensors.magnetometer.listen((MagnetometerEvent event) {
    print(event);
});

```