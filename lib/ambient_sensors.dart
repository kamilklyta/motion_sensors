import 'dart:async';
import 'package:flutter/services.dart';

final AmbientSensors ambientSensors = AmbientSensors();
const MethodChannel _methodChannel = MethodChannel('ambient_sensors/method');
const EventChannel _accelerometerEventChannel =
    EventChannel('ambient_sensors/accelerometer');
const EventChannel _gyroscopeEventChannel =
    EventChannel('ambient_sensors/gyroscope');
const EventChannel _magnetometerEventChannel =
    EventChannel('ambient_sensors/magnetometer');
const EventChannel _userAccelerometerEventChannel =
    EventChannel('ambient_sensors/user_accelerometer');

/// Discrete reading from an accelerometer. Accelerometers measure the velocity
/// of the device. Note that these readings include the effects of gravity. Put
/// simply, you can use accelerometer readings to tell if the device is moving in
/// a particular direction.
class AccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  AccelerometerEvent(this.timestamp, this.x, this.y, this.z);
  AccelerometerEvent.fromMap(Map<dynamic, dynamic> event)
      : timestamp = event['timestamp'] as int,
        x = event['x'] as double,
        y = event['y'] as double,
        z = event['z'] as double;

  /// The time at which the event happened.
  /// Represented in milliseconds since device boot.
  final int timestamp;

  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving to the right and negative mean it is moving to the left.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving towards the sky and negative mean it is moving towards
  /// the ground.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  ///
  /// This uses a right-handed coordinate system. So when the device is held
  /// upright and facing the user, positive values mean the device is moving
  /// towards the user and negative mean it is moving away from them.
  final double z;

  @override
  String toString() => 'AccelerometerEvent ($timestamp, x: $x, y: $y, z: $z)';
}

class MagnetometerEvent {
  MagnetometerEvent(this.timestamp, this.x, this.y, this.z);
  MagnetometerEvent.fromMap(Map<dynamic, dynamic> event)
      : timestamp = event['timestamp'] as int,
        x = event['x'] as double,
        y = event['y'] as double,
        z = event['z'] as double;

  /// The time at which the event happened.
  /// Represented in milliseconds since device boot.
  final int timestamp;

  final double x;
  final double y;
  final double z;
  @override
  String toString() => '[Magnetometer ($timestamp, x: $x, y: $y, z: $z)]';
}

/// Discrete reading from a gyroscope. Gyroscopes measure the rate or rotation of
/// the device in 3D space.
class GyroscopeEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  GyroscopeEvent(this.timestamp, this.x, this.y, this.z);

  GyroscopeEvent.fromMap(Map<dynamic, dynamic> event)
      : timestamp = event['timestamp'] as int,
        x = event['x'] as double,
        y = event['y'] as double,
        z = event['z'] as double;

  /// The time at which the event happened.
  /// Represented in milliseconds since device boot.
  final int timestamp;

  /// Rate of rotation around the x axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "pitch". The top of the device will tilt towards or away from the
  /// user as this value changes.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "yaw". The lengthwise edge of the device will rotate towards or away from
  /// the user as this value changes.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  ///
  /// When the device is held upright, this can also be thought of as describing
  /// "roll". When this changes the face of the device should remain facing
  /// forward, but the orientation will change from portrait to landscape and so
  /// on.
  final double z;

  @override
  String toString() => 'GyroscopeEvent($timestamp, x: $x, y: $y, z: $z)';
}

/// Like [AccelerometerEvent], this is a discrete reading from an accelerometer
/// and measures the velocity of the device. However, unlike
/// [AccelerometerEvent], this event does not include the effects of gravity.
class UserAccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  UserAccelerometerEvent(this.timestamp, this.x, this.y, this.z);
  UserAccelerometerEvent.fromMap(Map<dynamic, dynamic> event)
      : timestamp = event['timestamp'] as int,
        x = event['x'] as double,
        y = event['y'] as double,
        z = event['z'] as double;

  /// The time at which the event happened.
  /// Represented in milliseconds since device boot.
  final int timestamp;

  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving to the right and negative mean it is moving to the left.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving towards the sky and negative mean it is moving towards
  /// the ground.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  ///
  /// This uses a right-handed coordinate system. So when the device is held
  /// upright and facing the user, positive values mean the device is moving
  /// towards the user and negative mean it is moving away from them.
  final double z;

  @override
  String toString() =>
      'UserAccelerometerEvent($timestamp, x: $x, y: $y, z: $z)';
}

class AmbientSensors {
  Stream<AccelerometerEvent>? _accelerometerEvents;
  Stream<GyroscopeEvent>? _gyroscopeEvents;
  Stream<UserAccelerometerEvent>? _userAccelerometerEvents;
  Stream<MagnetometerEvent>? _magnetometerEvents;

  static const int TYPE_ACCELEROMETER = 1;
  static const int TYPE_MAGNETIC_FIELD = 2;
  static const int TYPE_GYROSCOPE = 4;
  static const int TYPE_USER_ACCELEROMETER = 10;

  /// Determines whether sensor is available.
  Future<bool> isSensorAvailable(int sensorType) async {
    final available =
        await _methodChannel.invokeMethod('isSensorAvailable', sensorType);
    return available;
  }

  /// Determines whether accelerometer is available.
  Future<bool> isAccelerometerAvailable() =>
      isSensorAvailable(TYPE_ACCELEROMETER);

  /// Determines whether magnetometer is available.
  Future<bool> isMagnetometerAvailable() =>
      isSensorAvailable(TYPE_MAGNETIC_FIELD);

  /// Determines whether gyroscope is available.
  Future<bool> isGyroscopeAvailable() => isSensorAvailable(TYPE_GYROSCOPE);

  /// Determines whether user accelerometer is available.
  Future<bool> isUserAccelerationAvailable() =>
      isSensorAvailable(TYPE_USER_ACCELEROMETER);

  /// Change the update interval of sensor. The units are in microseconds.
  Future setSensorUpdateInterval(int sensorType, int interval) async {
    await _methodChannel.invokeMethod('setSensorUpdateInterval',
        {"sensorType": sensorType, "interval": interval});
  }

  /// The update interval of accelerometer. The units are in microseconds.
  set accelerometerUpdateInterval(int interval) =>
      setSensorUpdateInterval(TYPE_ACCELEROMETER, interval);

  /// The update interval of magnetometer. The units are in microseconds.
  set magnetometerUpdateInterval(int interval) =>
      setSensorUpdateInterval(TYPE_MAGNETIC_FIELD, interval);

  /// The update interval of Gyroscope. The units are in microseconds.
  set gyroscopeUpdateInterval(int interval) =>
      setSensorUpdateInterval(TYPE_GYROSCOPE, interval);

  /// The update interval of user accelerometer. The units are in microseconds.
  set userAccelerometerUpdateInterval(int interval) =>
      setSensorUpdateInterval(TYPE_USER_ACCELEROMETER, interval);

  /// A broadcast stream of events from the device accelerometer.
  Stream<AccelerometerEvent> get accelerometer {
    if (_accelerometerEvents == null) {
      _accelerometerEvents = _accelerometerEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => AccelerometerEvent.fromMap(event as Map));
    }
    return _accelerometerEvents!;
  }

  /// A broadcast stream of events from the device gyroscope.
  Stream<GyroscopeEvent> get gyroscope {
    if (_gyroscopeEvents == null) {
      _gyroscopeEvents = _gyroscopeEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => GyroscopeEvent.fromMap(event as Map));
    }
    return _gyroscopeEvents!;
  }

  /// Events from the device accelerometer with gravity removed.
  Stream<UserAccelerometerEvent> get userAccelerometer {
    if (_userAccelerometerEvents == null) {
      _userAccelerometerEvents = _userAccelerometerEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => UserAccelerometerEvent.fromMap(event as Map));
    }
    return _userAccelerometerEvents!;
  }

  /// A broadcast stream of events from the device magnetometer.
  Stream<MagnetometerEvent> get magnetometer {
    if (_magnetometerEvents == null) {
      _magnetometerEvents = _magnetometerEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => MagnetometerEvent.fromMap(event as Map));
    }
    return _magnetometerEvents!;
  }
}
