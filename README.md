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

In your library add the following import:

```dart
import 'package:sfmc_flutter/sfmc_flutter.dart';
```

## Getting started
### Setup Android
1. Add SFMCSdk to project-level `build.gradle`
```gradle
allprojects {  
  repositories {  
	  ...
      maven {  
		  url "https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/repository"  
	  }  
  }
}
 ```
2. Add SFMCSdk to app-level `app/build.gradle`
```gradle
implementation ("com.salesforce.marketingcloud:marketingcloudsdk:8.0.4")  
implementation 'com.google.android.gms:play-services-location:17.1.0'  
  
implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"  
implementation platform('com.google.firebase:firebase-bom:29.0.0')  
implementation 'com.google.firebase:firebase-messaging:20.1.2'
 ```
3. Add your `google-services.json` from your Firebase to `app/`.
4. Open `app/src/main/<your_package_name>/MainActivity.kt` and add the following code.

```kotlin
...
import io.flutter.embedding.android.FlutterActivity  
import com.salesforce.marketingcloud.MarketingCloudSdk  
import com.salesforce.marketingcloud.MCLogListener  
import com.salesforce.marketingcloud.MarketingCloudConfig  
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions  
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk  
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkModuleConfig  
  
  
class MainActivity : FlutterActivity() {  
    override fun onCreate(savedInstanceState: Bundle?) {  
        super.onCreate(savedInstanceState)  
        SFMCSdk.configure(applicationContext as Application, SFMCSdkModuleConfig.build {  
  pushModuleConfig = MarketingCloudConfig.builder().apply {  
				setApplicationId("<your_application_id>")  
                setAccessToken("<your_access_token>")  
                setSenderId("<your_sender_id>")  
                setMarketingCloudServerUrl("<your_marketing_cloud_url>")  
                setMid("<your_mid>")  
                setNotificationCustomizationOptions(  
                    NotificationCustomizationOptions.create(R.drawable.ic_notification_icon)  
                )  
            }.build(applicationContext)  
        }) { initStatus ->  
   }  
 }  
}
```

### Setup iOS
1. Setup your `AppDelegate.swift` file with Marketing Cloud initialization.
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
        self.configureMarketingCloudSDK()  
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)  
    }  
      
    func configureMarketingCloudSDK() {  
        let builder = MarketingCloudSDKConfigBuilder()  
            .sfmc_setApplicationId("<your_application_id>")  
            .sfmc_setAccessToken("<your_access_token>")  
            .sfmc_setMarketingCloudServerUrl("<your_marketing_cloud_url>")  
            .sfmc_setMid("<your_mid>")  
            .sfmc_build()!  
          
        do {  
            try MarketingCloudSDK.sharedInstance().sfmc_configure(with:builder)  
            registerForRemoteNotification()  
        } catch let error as NSError {  
            
        }  
    }  
      
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {  
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)  
    }  
    func registerForRemoteNotification() {  
            if #available(iOS 10.0, *) {  
                let center  = UNUserNotificationCenter.current()  
  
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in  
 if error == nil{  
                        UIApplication.shared.registerForRemoteNotifications()  
                    }  
                }  
  
            }  
            else {  
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))  
                UIApplication.shared.registerForRemoteNotifications()  
            }  
        }  
      
    override func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {  
        if(MarketingCloudSDK.sharedInstance().sfmc_isReady() == false) {  
            self.configureMarketingCloudSDK()  
        }  
    }  
}
```

### Flutter

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