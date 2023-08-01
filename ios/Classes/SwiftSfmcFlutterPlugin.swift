import Flutter
import UIKit
import SFMCSDK
import MarketingCloudSDK

public class SwiftSfmcFlutterPlugin: NSObject, FlutterPlugin, InAppMessageEventDelegate, URLHandlingDelegate, MarketingCloudSDKEventDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sfmc_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftSfmcFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if call.method == "setupSFMC" {
            guard let args = call.arguments as? [String : Any] else {return}
            
            let appId = args["appId"] as? String
            let accessToken = args["accessToken"] as? String
            let mid = args["mid"] as? String
            let sfmcURL = args["sfmcURL"] as? String
            let locationEnabled = args["locationEnabled"] as? Bool
            let inboxEnabled = args["inboxEnabled"] as? Bool
            let analyticsEnabled = args["analyticsEnabled"] as? Bool
            let delayRegistration = args["delayRegistration"] as? Bool
            
            if appId == nil || accessToken == nil || mid == nil || sfmcURL == nil {
                result(false)
                return
            }
            
            setupSFMC(appId: appId!, accessToken: accessToken!, mid: mid!, sfmcURL: sfmcURL!, locationEnabled: locationEnabled, inboxEnabled: inboxEnabled, analyticsEnabled: analyticsEnabled, delayRegistration: delayRegistration, onDone: { sfmcResult, message, code in
                if (sfmcResult) {
                    result(true)
                } else {
                    result(FlutterError(code: "\(code!)",
                                        message: message,
                                        details: nil))
                }
            })
        } else if call.method == "setDeviceToken" {
            guard let args = call.arguments as? [String : Any] else {return}
            let deviceKey = args["deviceId"] as! String?
            if deviceKey == nil {
                result(false)
                return
            }
            result(setDeviceKey(deviceKey: deviceKey!))
        } else if call.method == "getDeviceToken" {
            result(getDeviceToken())
        } else if call.method == "getDeviceIdentifier" {
            result(getDeviceIdentifier())
        } else if call.method == "setContactKey" {
            guard let args = call.arguments as? [String : Any] else {return}
            let cKey = args["cId"] as! String?
            if cKey == nil {
                result(false)
                return
            }
            
            result(setContactKey(contactKey: cKey!))
        } else if call.method == "setTag" {
            
            guard let args = call.arguments as? [String : Any] else {return}
            let tag = args["tag"] as! String?
            if tag == nil {
                result(false)
                return
            }
            
            result(setTag(tag: tag!))
        } else if call.method == "removeTag" {
            guard let args = call.arguments as? [String : Any] else {return}
            let tag = args["tag"] as! String?
            if tag == nil {
                result(false)
                return
            }
            result(removeTag(tag:tag!))
        } else if call.method == "setAttribute" {
            guard let args = call.arguments as? [String : Any] else {return}
            let attrName = args["name"] as! String?
            let attrValue = args["value"] as! String?
            if attrName == nil || attrValue == nil {
                result(false)
                return
            }
            result(setAttribute(name: attrName!, value: attrValue!));
        } else if call.method == "clearAttribute" {
            guard let args = call.arguments as? [String : Any] else {return}
            let attrName = args["name"] as! String?
            
            if attrName == nil
            {
                result(false)
                return
            }
            result(clearAttribute(name: attrName!));
            
        }else if call.method == "pushEnabled" {
            result(pushEnabled());
        }else if call.method == "enablePush" {
            result(setPushEnabled(status: true));
        } else if call.method == "disablePush" {
            result(setPushEnabled(status: false));
        } else if call.method == "getPushToken" {
            result(getPushToken());
        } else if call.method == "sdkState" {
            result(getSDKState())
        } else if call.method == "enableVerbose" {
            result(setupVerbose(status: true))
        } else if call.method == "disableVerbose" {
            result(setupVerbose(status: false))
        } else if call.method == "enableWatchingLocation" {
            result(enableLocationWatching())
        } else if call.method == "disableWatchingLocation" {
            result(disableLocationWatching())
        } else {
            result(FlutterError(code: "METHOD_NOT_AVAILABLE",
                                message: "METHOD_NOT_ALLOWED",
                                details: nil))
        }
    }
    
    public func setupSFMC(appId: String, accessToken: String, mid: String, sfmcURL: String, locationEnabled: Bool?, inboxEnabled: Bool?, analyticsEnabled: Bool?, delayRegistration: Bool?, onDone: (_ result: Bool, _ message: String?, _ code: Int?) -> Void) {
        SFMCSdk.mp.tearDown()

       let builder = PushConfigBuilder(appId: appId)
            .setAccessToken(accessToken)
            .setMarketingCloudServerUrl(URL(string: sfmcURL)!)
            .setMid(mid)
            .setDelayRegistrationUntilContactKeyIsSet(delayRegistration ?? false)
            .setInboxEnabled(inboxEnabled ?? true)
            .setLocationEnabled(locationEnabled ?? true)
            .setAnalyticsEnabled(analyticsEnabled ?? true)
            .build()

        SFMCSdk.mp.setURLHandlingDelegate(self)
        SFMCSdk.mp.setEventDelegate(self)

        do {
            try SFMCSdk.initializeSdk(ConfigBuilder().setPush(config: builder).build())
            onDone(true, nil, nil);
        } catch let error as NSError {
            onDone(false, error.localizedDescription, error.code);
        }
    }
    
    /*
     * Device Key Management
     */
    public func setDeviceKey(deviceKey: String) -> Bool? {
        let data = deviceKey.data(using: .utf8)
        if (data == nil) {
            return true
        }

        SFMCSdk.mp.setDeviceToken(data!)
        return true
    }

    public func getDeviceToken() -> String? {
        return SFMCSdk.mp.deviceToken()
    }

    public func getDeviceIdentifier() -> String? {
        return SFMCSdk.mp.deviceIdentifier()
    }
    
    /*
     * Contact Key Management
     */
    public func setContactKey(contactKey: String) -> Bool? {
        SFMCSdk.identity.setProfileId(contactKey)
        return true
    }
    
    /*
     * Attribute Management
     */
    public func setAttribute(name: String, value: Any) -> Bool {
        SFMCSdk.identity.setProfileAttribute(name, "\(value)")
        return true
    }
    public func clearAttribute(name: String) -> Bool {
        SFMCSdk.identity.clearProfileAttribute(key: name)
        
        return true
    }
    public func attributes() -> [String: String] {
        return (SFMCSdk.mp.attributes() ?? [:]) as! [String : String]
    }
    
    /*
     * TAG Management
     */
    public func setTag(tag: String) -> Bool {
        SFMCSdk.mp.addTag(tag)
        return true
    }
    public func removeTag(tag: String) -> Bool {
        SFMCSdk.mp.removeTag(tag)
        return true
    }
    public func tags() -> [String] {
        //var tags: [String] = Array(MarketingCloudSDK.sharedInstance().sfmc_tags()!)
        return []
    }
    
    /*
     * Verbose Management
     */
    public func setupVerbose(status: Bool) -> Bool {
        SFMCSdk.mp.setDebugLoggingEnabled(status)
        return true
    }
    
    /*
     * Verbose Management
     */
    public func pushEnabled() -> Bool {
        return SFMCSdk.mp.pushEnabled()
    }

    public func setPushEnabled(status: Bool) -> Bool {
        SFMCSdk.mp.setPushEnabled(status)
        return true
    }

    public func getPushToken() -> String? {
        return SFMCSdk.mp.deviceToken()
    }
    
    /*
     * SDKState Management
     */
    public func getSDKState() -> String {
        let status = SFMCSdk.mp.getStatus()
        return String(describing: status)
    }
    
    /*
     * Location
     */
    public func enableLocationWatching() -> Bool {
        SFMCSdk.mp.startWatchingLocation()
        return true;
    }
    public func disableLocationWatching() -> Bool {
        SFMCSdk.mp.stopWatchingLocation()
        return true;
    }

    /*
     * URL Handling
     */
    public func sfmc_handleURL(_ url: URL, type: String) {
        if UIApplication.shared.canOpenURL(url) == true {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if success {
                        print("url \(url) opened successfully")
                    } else {
                        print("url \(url) could not be opened")
                    }
                })
            } else {
                if UIApplication.shared.openURL(url) == true {
                    print("url \(url) opened successfully")
                } else {
                    print("url \(url) could not be opened")
                }
            }
        }
    }
    
    /*
     * IN-APP Messaging
     */
    public func sfmc_didShow(inAppMessage message: [AnyHashable : Any]) {
        // message shown
    }

    public func sfmc_didClose(inAppMessage message: [AnyHashable : Any]) {
        // message closed
    }
}
