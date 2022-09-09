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

Add your `google-services.json` from your Firebase to `app/`.

### Setup iOS

No additional setup is needed for iOS.

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