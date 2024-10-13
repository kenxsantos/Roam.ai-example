import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roam_flutter/roam_flutter.dart';

class MyAccuracyEnginePage extends StatefulWidget {
  const MyAccuracyEnginePage({super.key, required this.title});
  static const String routeName = "/MyAccuracyEnginePage";
  final String title;
  @override
  _MyAccuracyEnginePageState createState() => new _MyAccuracyEnginePageState();
}

class _MyAccuracyEnginePageState extends State<MyAccuracyEnginePage> {
  bool? isAccuracyEngineEnabled;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SelectableText(
                '\nAccuracy Engine status: $isAccuracyEngineEnabled\n'),
            ElevatedButton(
                child: const Text('Enable Accuracy Engine'),
                onPressed: () async {
                  setState(() {
                    isAccuracyEngineEnabled = true;
                  });
                  try {
                    await Roam.enableAccuracyEngine();
                  } on PlatformException {
                    print('Enable Accuracy Engine Error');
                  }
                }),
            ElevatedButton(
                child: const Text('Disable Accuracy Engine'),
                onPressed: () async {
                  setState(() {
                    isAccuracyEngineEnabled = false;
                  });
                  try {
                    await Roam.disableAccuracyEngine();
                  } on PlatformException {
                    print('Disable Accuracy Engine Error');
                  }
                }),
          ],
        ),
      ),
    );
  }
}
