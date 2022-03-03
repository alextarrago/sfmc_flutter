import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sfmc_flutter/sfmc_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await SFMCSDK.setupSFMC(
        appId: "",
        accessToken: "",
        mid: "",
        sfmcURL:
            "",
        delayRegistration: true);
    await SFMCSDK.setContactKey("");
    await SFMCSDK.enablePush();

    await SFMCSDK.setDeviceToken(
        "");

    await SFMCSDK.pushEnabled();
    await SFMCSDK.setAttribute("name", "");

    await SFMCSDK.setTag("");
    await SFMCSDK.removeTag("");

    await SFMCSDK.enableLocationWatching();
    await SFMCSDK.enableVerbose();

    await SFMCSDK.sdkState();

    await SFMCSDK.enableVerbose();
    Timer.periodic(Duration(seconds: 2), (timer) async {
      _platformVersion = (await SFMCSDK.sdkState())!;
      setState(() {});

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('SFMCSDK Plugin'),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Text(_platformVersion),
            ),
          )),
    );
  }
}
