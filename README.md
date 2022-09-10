# sfmc_flutter
A Flutter implementation of Salesforce Marketing Cloud for iOS and Android.

## Features

- [X] Setup Marketing Cloud (iOS and Android)
- [X] Support for Push Notifications (iOS and Android)
- [X] Support Attributes (iOS and Android)
- [X] Support TAGS (iOS and Android)
- [X] Support Enable/Disable Verbose (iOS and Android)
- [X] Support Enable/Disable Push Notifications (iOS and Android)
- [ ] Support In-App Messaging
- [ ] Support Location Based Notifications
- [ ] Support Beacons

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  sfmc_flutter: <latest_version>
```

## Getting started

### Setup Android

1. [Connect Marketing Cloud Account to Your Android App](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/create-apps/create-apps-overview.html)
2. Folow [Firebase guide](https://firebase.google.com/docs/android/setup#console) (just until step 3.1) to add your `google-services.json` to `app/` directory.
3. (Optional) By default the icon used in notification is the app icon, but you can define other in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="SFCMNotificationIcon"
    android:resource="@drawable/custom_icon_here" />
```

### Setup iOS

1. [Create a .p8 Auth Key File](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/get-started-provision.html)
2. [Setup MobilePush Apps](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/get-started-setupapps.html)
3. Enable push notifications in your target’s [Capabilities settings](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/assets/SDKConfigure6.png).
4. Setup your `AppDelegate.swift` file to handle push notification.

```swift
import UIKit
import Flutter
import MarketingCloudSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        registerForRemoteNotification()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    /** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
    This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationUserInfo(userInfo)  
        completionHandler(.newData)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Required: tell the MarketingCloudSDK about the notification. This will collect MobilePush analytics
        // and process the notification on behalf of your application.
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
        completionHandler()
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    private func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
    }
}
```

### Setup Flutter

```dart
import 'package:flutter/foundation.dart';
import 'package:sfmc_flutter/sfmc_flutter.dart';
// and any others imports...

void main() {
  setupSFMC();
  runApp(const MyApp());
}

Future<void> setupSFMC() async {
  if (kDebugMode) {
    await SFMCSDK.enableVerbose();
  }
  await SFMCSDK.setupSFMC(
    appId: "{mc_application_id}",
    accessToken: "{mc_access_token}",
    mid: "{mid}",
    sfmcURL: "{marketing_cloud_url}",
    senderId: "{fcm_sender_id}",
    delayRegistration: true,
  );
}
```

#### Other available methods
```dart
await SFMCSDK.setContactKey("<contact_id>"); // Set Contact Key for desired user
  
await SFMCSDK.enablePush(); // Enables PUSH for SDK 
await SFMCSDK.disablePush(); // Disables PUSH for SDK  
await SFMCSDK.pushEnabled(); // Returns if push is enabled or not

await SFMCSDK.setAttribute("name", "Mark"); // Set a user attribute 
await SFMCSDK.clearAttribute("name"); // Removes a given user attribute  
  
await SFMCSDK.setTag("Barcelona"); // Set a user tag   
await SFMCSDK.removeTag("Barcelona"); // Removes a given user tag  
  
await SFMCSDK.enableVerbose(); // Enable native Verbose
await SFMCSDK.disableVerbose(); // Disable native Verbose
  
await SFMCSDK.sdkState(); // Returns the SDKState log
```

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].