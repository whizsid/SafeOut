import UIKit
import Flutter
import GoogleMaps
#import "FlutterConfigPlugin.h"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let googleApiKey = FlutterConfigPlugin.env(for: "GOOGLE_API_KEY")

    GMSServices.provideAPIKey(googleApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
