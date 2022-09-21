import Flutter
import UIKit
import CoreMotion

let GRAVITY = 9.8
let TYPE_ACCELEROMETER = 1
let TYPE_MAGNETIC_FIELD = 2
let TYPE_GYROSCOPE = 4
let TYPE_USER_ACCELEROMETER = 10


// translate from https://github.com/flutter/plugins/tree/master/packages/sensors
public class SwiftMotionSensorsPlugin: NSObject, FlutterPlugin {
    private let accelerometerStreamHandler = AccelerometerStreamHandler()
    private let magnetometerStreamHandler = MagnetometerStreamHandler()
    private let gyroscopeStreamHandler = GyroscopeStreamHandler()
    private let userAccelerometerStreamHandler = UserAccelerometerStreamHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let METHOD_CHANNEL_NAME = "motion_sensors/method"
        let instance = SwiftMotionSensorsPlugin(registrar: registrar)
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        let ACCELEROMETER_CHANNEL_NAME = "motion_sensors/accelerometer"
        let MAGNETOMETER_CHANNEL_NAME = "motion_sensors/magnetometer"
        let GYROSCOPE_CHANNEL_NAME = "motion_sensors/gyroscope"
        let USER_ACCELEROMETER_CHANNEL_NAME = "motion_sensors/user_accelerometer"
        
        let accelerometerChannel = FlutterEventChannel(name: ACCELEROMETER_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        accelerometerChannel.setStreamHandler(accelerometerStreamHandler)
        
        let magnetometerChannel = FlutterEventChannel(name: MAGNETOMETER_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        magnetometerChannel.setStreamHandler(magnetometerStreamHandler)
        
        let gyroscopeChannel = FlutterEventChannel(name: GYROSCOPE_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        gyroscopeChannel.setStreamHandler(gyroscopeStreamHandler)
        
        let userAccelerometerChannel = FlutterEventChannel(name: USER_ACCELEROMETER_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        userAccelerometerChannel.setStreamHandler(userAccelerometerStreamHandler)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSensorAvailable":
            result(isSensorAvailable(call.arguments as! Int))
        case "setSensorUpdateInterval":
            let arguments = call.arguments as! NSDictionary
            setSensorUpdateInterval(arguments["sensorType"] as! Int, arguments["interval"] as! Int)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func isSensorAvailable(_ sensorType: Int) -> Bool {
        let motionManager = CMMotionManager()
        switch sensorType {
        case TYPE_ACCELEROMETER:
            return motionManager.isAccelerometerAvailable
        case TYPE_MAGNETIC_FIELD:
            return motionManager.isMagnetometerAvailable
        case TYPE_GYROSCOPE:
            return motionManager.isGyroAvailable
        case TYPE_USER_ACCELEROMETER:
            return motionManager.isDeviceMotionAvailable
        default:
            return false
        }
    }
    
    public func setSensorUpdateInterval(_ sensorType: Int, _ interval: Int) {
        let timeInterval = TimeInterval(Double(interval) / 1000000.0)
        switch sensorType {
        case TYPE_ACCELEROMETER:
            accelerometerStreamHandler.setUpdateInterval(timeInterval)
        case TYPE_MAGNETIC_FIELD:
            magnetometerStreamHandler.setUpdateInterval(timeInterval)
        case TYPE_GYROSCOPE:
            gyroscopeStreamHandler.setUpdateInterval(timeInterval)
        case TYPE_USER_ACCELEROMETER:
            userAccelerometerStreamHandler.setUpdateInterval(timeInterval)
        default:
            break
        }
    }
}

class AccelerometerStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: queue) { (data, error) in
                if data != nil {
                    var event: [String: Any] = [:]
                    event["timestamp"] = Int(data!.timestamp * 1000) // convert from seconds to milliseconds
                    event["x"] = -data!.acceleration.x * GRAVITY
                    event["y"] = -data!.acceleration.y * GRAVITY
                    event["z"] = -data!.acceleration.z * GRAVITY
                    events(event)
//                    events([-data!.acceleration.x * GRAVITY, -data!.acceleration.y * GRAVITY, -data!.acceleration.z * GRAVITY])
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        return nil
    }
    
    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.accelerometerUpdateInterval = interval
    }
}

class UserAccelerometerStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: queue) { (data, error) in
                if data != nil {
                    var event: [String: Any] = [:]
                    event["timestamp"] = Int(data!.timestamp * 1000) // convert from seconds to milliseconds
                    event["x"] = -data!.userAcceleration.x * GRAVITY
                    event["y"] = -data!.userAcceleration.y * GRAVITY
                    event["z"] = -data!.userAcceleration.z * GRAVITY
                    events(event)
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
    
    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.deviceMotionUpdateInterval = interval
    }
}

class GyroscopeStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: queue) { (data, error) in
                if data != nil {
                    var event: [String: Any] = [:]
                    event["timestamp"] = Int(data!.timestamp * 1000) // convert from seconds to milliseconds
                    event["x"] = data!.rotationRate.x
                    event["y"] = data!.rotationRate.y
                    event["z"] = data!.rotationRate.z
                    events(event)
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopGyroUpdates()
        return nil
    }
    
    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.gyroUpdateInterval = interval
    }
}

class MagnetometerStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isDeviceMotionAvailable {
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: queue) { (data, error) in
                if data != nil {
                    var event: [String: Any] = [:]
                    event["timestamp"] = Int(data!.timestamp * 1000) // convert from seconds to milliseconds;
                    event["x"] = data!.magneticField.field.x
                    event["y"] = data!.magneticField.field.y
                    event["z"] = data!.magneticField.field.z
                    events(event)
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
    
    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.deviceMotionUpdateInterval = interval
    }
}
