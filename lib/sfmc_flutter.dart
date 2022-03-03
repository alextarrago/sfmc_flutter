import 'dart:async';
import 'package:flutter/services.dart';

class SFMCSDK {
  static const MethodChannel _channel = MethodChannel('sfmc_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool?> setupSFMC(
      {String? appId,
      String? accessToken,
      String? mid,
      String? sfmcURL,
      String? senderId,
      bool? locationEnabled,
      bool? inboxEnabled,
      bool? analyticsEnabled,
      bool? delayRegistration}) async {
    final bool? result = await _channel.invokeMethod('setupSFMC', {
      "appId": appId,
      "accessToken": accessToken,
      "mid": mid,
      "sfmcURL": sfmcURL,
      "senderId": senderId,
      "locationEnabled": locationEnabled,
      "inboxEnabled": inboxEnabled,
      "analyticsEnabled": analyticsEnabled,
      "delayRegistration": delayRegistration,
    });
    return result;
  }

  static Future<bool?> setDeviceToken(String deviceToken) async {
    final bool? result = await _channel
        .invokeMethod('setDeviceToken', {"deviceKey": deviceToken});
    return result;
  }
  static Future<String?> getDeviceToken() async {
    final String? result = await _channel
        .invokeMethod('getDeviceToken');
    return result;
  }

  static Future<String?> getDeviceIdentifier() async {
    final String? result = await _channel
        .invokeMethod('getDeviceIdentifier');
    return result;
  }

  static Future<bool?> setContactKey(String contactKey) async {
    final bool? result =
        await _channel.invokeMethod('setContactKey', {"cId": contactKey});
    return result;
  }

  /*
  * Attribute Management
  */
  static Future<bool?> setAttribute(String attrName, String attrValue) async {
    final bool? result = await _channel
        .invokeMethod('setAttribute', {"name": attrName, "value": attrValue});
    return result;
  }

  static Future<bool?> clearAttribute(String attrName) async {
    final bool? result =
        await _channel.invokeMethod('clearAttribute', {"name": attrName});
    return result;
  }

  /*
  * Tag Management
  */
  static Future<bool?> setTag(String tagName) async {
    final bool? result =
        await _channel.invokeMethod('setTag', {"tag": tagName});
    return result;
  }

  static Future<bool?> removeTag(String tagName) async {
    final bool? result =
        await _channel.invokeMethod('removeTag', {"tag": tagName});
    return result;
  }

  /*
  * Push Management
  */
  static Future<bool?> pushEnabled() async {
    final bool? result = await _channel.invokeMethod('pushEnabled');
    return result;
  }

  static Future<bool?> enablePush() async {
    final bool? result = await _channel.invokeMethod('enablePush');
    return result;
  }

  static Future<bool?> disablePush() async {
    final bool? result = await _channel.invokeMethod('disablePush');
    return result;
  }

  /*
  * SDK State Management
  */
  static Future<String?> sdkState() async {
    final String? result = await _channel.invokeMethod('sdkState');
    return result;
  }

  /*
     * Location Watching
     */
  static Future<bool?> enableLocationWatching() async {
    final bool? result = await _channel.invokeMethod('enableWatchingLocation');
    return result;
  }
  static Future<bool?> disableLocationWatching() async {
    final bool? result = await _channel.invokeMethod('disableWatchingLocation');
    return result;
  }


/*
  * Verbose Management
  */
  static Future<bool?> enableVerbose() async {
    final bool? result = await _channel.invokeMethod('enableVerbose');
    return result;
  }

  static Future<bool?> disableVerbose() async {
    final bool? result = await _channel.invokeMethod('disableVerbose');
    return result;
  }
}
