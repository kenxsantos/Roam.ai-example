import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roam_flutter/roam_flutter.dart';

class MyUsersPage extends StatefulWidget {
  MyUsersPage({super.key, required this.title});
  static const String routeName = "/MyUsersPage";
  final String title;
  @override
  _MyUsersPageState createState() => new _MyUsersPageState();
}

class _MyUsersPageState extends State<MyUsersPage> {
  String? myUser;
  String? codeDialog;
  String? valueText;
  final TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter User Id'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter User Id"),
            ),
            actions: <Widget>[
              TextButton(
                // color: Colors.red,
                // textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                // color: Colors.green,
                // textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  setState(() {
                    try {
                      Roam.getUser(
                          userId: valueText ?? '',
                          callBack: ({user}) {
                            setState(() {
                              myUser = user;
                            });
                            print(user);
                          });
                    } on PlatformException {
                      print('Create User Error');
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SelectableText(
              '\nUser Details:\n $myUser\n',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                child: Text('Create User'),
                onPressed: () async {
                  setState(() {
                    myUser = "creating user..";
                  });
                  try {
                    await Roam.createUser(
                        description: 'Joe',
                        callBack: ({user}) {
                          setState(() {
                            myUser = user;
                          });
                          print(user);
                          Roam.offlineTracking(true);
                          Roam.allowMockLocation(allow: true);
                        });
                  } on PlatformException {
                    print('Create User Error');
                  }
                }),
            ElevatedButton(
                child: Text('Get User'),
                onPressed: () async {
                  _displayTextInputDialog(context);
                }),
            ElevatedButton(
                child: Text('Toogle Listener'),
                onPressed: () async {
                  setState(() {
                    myUser = "updating user listener status..";
                  });
                  try {
                    await Roam.toggleListener(
                        locations: true,
                        events: true,
                        callBack: ({user}) {
                          setState(() {
                            myUser = user;
                          });
                          print(user);
                        });
                  } on PlatformException {
                    print('Toggle Listener Error');
                  }
                }),
            ElevatedButton(
                child: Text('Toogle Events'),
                onPressed: () async {
                  setState(() {
                    myUser = "updating user events status..";
                  });
                  try {
                    await Roam.toggleEvents(
                        location: true,
                        geofence: true,
                        trips: true,
                        movingGeofence: true,
                        callBack: ({user}) {
                          setState(() {
                            myUser = user;
                          });
                          print(user);
                        });
                  } on PlatformException {
                    print('Toggle Events Error');
                  }
                }),
            ElevatedButton(
                child: Text('Get Listener Status'),
                onPressed: () async {
                  setState(() {
                    myUser = "fetching user listener status..";
                  });
                  try {
                    await Roam.getListenerStatus(callBack: ({user}) {
                      setState(() {
                        myUser = user;
                      });
                      print(user);
                    });
                  } on PlatformException {
                    print('Get Listener Status Error');
                  }
                }),
            ElevatedButton(
                child: Text('Logout User'),
                onPressed: () async {
                  try {
                    await Roam.logoutUser();
                  } on PlatformException {
                    print('Logout User Error');
                  }
                }),
          ],
        ),
      ),
    );
  }
}
