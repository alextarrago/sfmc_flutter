package com.dribba.sfmc_flutter

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import com.salesforce.marketingcloud.MCLogListener
import com.salesforce.marketingcloud.MarketingCloudConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkModuleConfig
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

private const val SFMC_NOTIFICATION_ICON_KEY = "SFCMNotificationIcon"

/** SfmcFlutterPlugin */
class SfmcFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sfmc_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "setupSFMC") {
            val appId = call.argument<String>("appId")
            val accessToken = call.argument<String>("accessToken")
            val mid = call.argument<String>("mid")
            val sfmcURL = call.argument<String>("sfmcURL")
            val senderId = call.argument<String>("senderId")

            if (appId == null || accessToken == null || mid == null || sfmcURL == null || senderId == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setupSFMC(appId, accessToken, mid, sfmcURL, senderId))
        } else if (call.method == "setContactKey") {
            val cKey = call.argument<String>("cId")
            if (cKey == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setContactKey(cKey))
        } else if (call.method == "setTag") {

            val tag = call.argument<String>("tag")
            if (tag == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setTag(tag))
        } else if (call.method == "removeTag") {
            val tag = call.argument<String>("tag")
            if (tag == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(removeTag(tag))
        } else if (call.method == "setAttribute") {
            val attrName = call.argument<String>("name")
            val attrValue = call.argument<String>("value")
            if (attrName == null || attrValue == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setAttribute(attrName, attrValue))
        } else if (call.method == "clearAttribute") {
            val attrName = call.argument<String>("name")
            if (attrName == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
            }
            result.success(attrName?.let { clearAttribute(it) })
        } else if (call.method == "pushEnabled") {
            pushEnabled() { res ->
                result.success(res)
            }
        } else if (call.method == "enablePush") {
            result.success(setPushEnabled(true))
        } else if (call.method == "disablePush") {
            result.success(setPushEnabled(false))
        } else if (call.method == "getPushToken") {
            getPushToken(result::success)
        } else if (call.method == "sdkState") {
            getSDKState() { res ->
                result.success(res)
            }
        } else if (call.method == "enableVerbose") {
            result.success(setupVerbose(true))
        } else if (call.method == "disableVerbose") {
            result.success(setupVerbose(false))
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    fun setupSFMC(appId: String, accessToken: String, mid: String, sfmcURL: String, senderId: String): Boolean {
        val notificationIcon = getNotificationIcon()

        SFMCSdk.configure(context.applicationContext, SFMCSdkModuleConfig.build {
            pushModuleConfig = MarketingCloudConfig.builder().apply {
                setApplicationId(appId)
                setAccessToken(accessToken)
                setSenderId(senderId)
                setMarketingCloudServerUrl(sfmcURL)
                setMid(mid)
                setNotificationCustomizationOptions(
                    NotificationCustomizationOptions.create(notificationIcon)
                )
                // Other configuration options
            }.build(context.applicationContext)
        }) { initStatus ->
            // TODO handle initialization status
        }
        return true
    }

    /*
    * Contact Key Management
    * */
    fun setContactKey(contactKey: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            val registrationManager = sdk.registrationManager
            registrationManager.edit().run {
                setContactKey(contactKey)
                commit()
            }
        }
        return true
    }

    /*
     * Attribute Management
     */
    fun setAttribute(name: String, value: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                // Set Attribute value
                setAttribute(name, value)
                commit()
            }
        }
        return true
    }

    fun clearAttribute(name: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                clearAttribute(name)
                commit()
            }
        }
        return true
    }

    fun attributes(): Array<String> {
        return emptyArray<String>()
    }

    /*
     * TAG Management
     */
    fun setTag(tag: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->

            sdk.registrationManager.edit().run {
                addTags(tag)
                commit()
            }
        }
        return true
    }

    fun removeTag(tag: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                removeTags(tag)
                commit()
            }
        }
        return true
    }

    /*
     * Verbose Management
     */
    fun setupVerbose(isEnabled: Boolean): Boolean {
        if (isEnabled) {
            MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE)
            MarketingCloudSdk.setLogListener(MCLogListener.AndroidLogListener())
        } else {
            MarketingCloudSdk.setLogLevel(MCLogListener.ERROR)
            MarketingCloudSdk.setLogListener(null)
        }
        return true
    }

    /*
     * Token Management
     */
    fun pushEnabled(result: (Any?) -> Unit) {
        MarketingCloudSdk.requestSdk { sdk ->
            result.invoke(sdk.pushMessageManager.isPushEnabled())
        }
    }

    fun setPushEnabled(status: Boolean): Boolean {
        if (status) {
            MarketingCloudSdk.requestSdk { sdk -> sdk.pushMessageManager.enablePush() }
        } else {
            MarketingCloudSdk.requestSdk { sdk -> sdk.pushMessageManager.disablePush() }
        }
        return true
    }

    fun getPushToken(onResult: (String?) -> Unit) {
        SFMCSdk.requestSdk { sdk ->
            sdk.mp {
                onResult(it.pushMessageManager.pushToken)
            }
        }
    }

    /*
     * SDKState Management
     */
    fun getSDKState(result: (Any?) -> Unit) {
        MarketingCloudSdk.requestSdk { sdk ->
            result.invoke(sdk.sdkState.toString())
        }
    }

    override fun onDetachedFromActivity() = Unit

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = Unit

    override fun onAttachedToActivity(binding: ActivityPluginBinding) = Unit

    override fun onDetachedFromActivityForConfigChanges() = Unit

    private fun getNotificationIcon(): Int {
        val appInfo = context
            .applicationContext
            .packageManager
            .getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)

        val metaData = appInfo.metaData
        if (metaData.containsKey(SFMC_NOTIFICATION_ICON_KEY)) {
            return metaData.getInt(SFMC_NOTIFICATION_ICON_KEY)
        }

        return appInfo.icon
    }
}
