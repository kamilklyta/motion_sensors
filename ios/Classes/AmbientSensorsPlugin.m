#import "AmbientSensorsPlugin.h"
#if __has_include(<ambient_sensors/ambient_sensors-Swift.h>)
#import <ambient_sensors/ambient_sensors-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ambient_sensors-Swift.h"
#endif

@implementation AmbientSensorsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmbientSensorsPlugin registerWithRegistrar:registrar];
}
@end
