import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roam_ai/pages/my_accuracy_engine_page.dart';
import 'package:roam_ai/pages/my_items_page.dart';
import 'package:roam_ai/pages/my_location_tracking_page.dart';
import 'package:roam_ai/pages/my_users_page.dart';
import 'package:roam_ai/pages/my_subscription_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:roam_flutter/roam_flutter.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );
  service.startService();
}

void onStart(ServiceInstance serviceInstance) {
  DartPluginRegistrant.ensureInitialized();
  Roam.onLocation((location) async {
    print(jsonEncode(location));
    Fluttertoast.showToast(
      msg: jsonEncode(location),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyItemsPage.routeName: (BuildContext context) =>
          MyItemsPage(title: "Trips Page"),
      MyUsersPage.routeName: (BuildContext context) =>
          MyUsersPage(title: "Users Page"),
      MySubcriptionPage.routeName: (BuildContext context) =>
          MySubcriptionPage(title: "Subscription Page"),
      MyAccuracyEnginePage.routeName: (BuildContext context) =>
          MyAccuracyEnginePage(title: "Accuracy Engine Page"),
      MyLocationTrackingPage.routeName: (BuildContext context) =>
          MyLocationTrackingPage(title: "Location Tracking Page"),
    };
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Demo'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  bool isTracking = false;
  String? myLocation;
  String? myUser;
  bool isAccuracyEngineEnabled = false;
  final String roam_ai_publishable_key =
      dotenv.env['ROAM_AI_PUBLISHABLE_KEY'] ?? '';

  // Native to Flutter Channel
  static const MethodChannel platform = MethodChannel("myChannel");

  @override
  void initState() async {
    await dotenv.load(fileName: ".env");
    super.initState();
    platform.setMethodCallHandler(nativeMethodCallHandler);
    initPlatformState();
    Roam.initialize(publishKey: roam_ai_publishable_key);
  }

  // Native to Flutter Channel
  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "location":
        print(methodCall.arguments);
        setState(() {
          myLocation = methodCall.arguments;
        });
        break;
      default:
        return "Nothing";
    }
  }

  Future<void> initPlatformState() async {
    String? platformVersion;
    try {
      platformVersion = await Roam.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roam Plugin Example App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText('Running on: $_platformVersion\n'),
            SelectableText(
              'Received Location:\n ${myLocation ?? 'No location received'}\n',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              child: const Text('Request Location Permissions'),
              onPressed: () async {
                try {
                  await Permission.locationWhenInUse.request();
                } on PlatformException {
                  print('Error getting location permissions');
                }
              },
            ),
            ElevatedButton(
              child: const Text('Disable Battery Optimization'),
              onPressed: () async {
                try {
                  await Roam.disableBatteryOptimization();
                } on PlatformException {
                  print('Disable Battery Optimization Error');
                }
              },
            ),
            ElevatedButton(
              child: const Text('Get Current Location'),
              onPressed: () async {
                setState(() {
                  myLocation = "Fetching location...";
                });
                try {
                  await Roam.getCurrentLocation(
                    accuracy: 100,
                    callBack: ({location}) {
                      setState(() {
                        myLocation = jsonEncode(location);
                      });
                      print(location);
                    },
                  );
                } on PlatformException {
                  print('Get Current Location Error');
                }
              },
            ),
            ElevatedButton(
              child: Text('Initialize SDK'),
              onPressed: () async {
                try {
                  await Roam.initialize(
                    publishKey:
                        '34efb72045ad4307d10f527f4727f055115421f787a19dce31135d8820207e7f',
                  );
                } on PlatformException {
                  print('Initialization Error');
                }
              },
            ),
            ElevatedButton(
                onPressed: _onUsersButtonPressed, child: const Text('Users')),
            ElevatedButton(
              onPressed: _onSubscriptionButtonPressed,
              child: const Text('Subscribe Location/Events'),
            ),
            ElevatedButton(
              onPressed: _onAccuracyEngineButtonPressed,
              child: const Text('Accuracy Engine'),
            ),
            ElevatedButton(
              onPressed: _onLocationTrackingButtonPressed,
              child: const Text('Location Tracking'),
            ),
            ElevatedButton(
                onPressed: _onButtonPressed, child: const Text('Trips')),
          ],
        ),
      ),
    );
  }

  void _onButtonPressed() {
    Navigator.pushNamed(context, MyItemsPage.routeName);
  }

  void _onUsersButtonPressed() {
    Navigator.pushNamed(context, MyUsersPage.routeName);
  }

  void _onSubscriptionButtonPressed() {
    Navigator.pushNamed(context, MySubcriptionPage.routeName);
  }

  void _onAccuracyEngineButtonPressed() {
    Navigator.pushNamed(context, MyAccuracyEnginePage.routeName);
  }

  void _onLocationTrackingButtonPressed() {
    Navigator.pushNamed(context, MyLocationTrackingPage.routeName);
  }
}
