package com.dribba.sfmc_flutter_example

import android.app.Application
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
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
        Log.d("myTag", "This is my message");

        SFMCSdk.configure(applicationContext as Application, SFMCSdkModuleConfig.build {
            pushModuleConfig = MarketingCloudConfig.builder().apply {
                setApplicationId("")
                setAccessToken("")
                setSenderId("")
                setMarketingCloudServerUrl("")
                setMid("")
                setNotificationCustomizationOptions(
                        NotificationCustomizationOptions.create(R.drawable.ic_notification_icon)
                )
            }.build(applicationContext)
        }) { initStatus ->

        }
    }

}
