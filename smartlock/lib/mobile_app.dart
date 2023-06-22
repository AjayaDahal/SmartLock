import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:smartlock/mobile_keypad.dart';

class MobileApp extends StatefulWidget {
  @override
  _MobileAppState createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp>
    with SingleTickerProviderStateMixin {
  AuthState authState = AuthState.Idle;
  String originalPassword = '';
  String enteredPassword = '';
  late String remoteUnlockVal;
  late String lockStatus;
  Timer? _timer;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('Lock');

  TextEditingController passcodeController = TextEditingController();
  bool showNewPasswordField = false;

  late bool _isLocked;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void updatePassword(String value) {
    setState(() {
      if (authState == AuthState.Recording) {
        if (value == '#') {
          if (enteredPassword == originalPassword) {
            authState = AuthState.Authenticated;
            showNewPasswordField = true;
            lockStatus = lockStatus == "Locked" ? "Unlocked" : "Locked";
            _database.child('RemoteKey').set("True");
            _database.child('LocalKey').set("False");
            _database.child('Status').set(lockStatus);
            _database.child('methodType').set("Digital KeyPad");
            DateTime now = new DateTime.now();
            String dateTime = "${now.toString()}";
            _database.child('dateTime').set(dateTime);
          } else {
            authState = AuthState.Failed;
          }
        } else {
          enteredPassword += value;
        }
      } else {
        if (value == '*') {
          authState = AuthState.Recording;
          enteredPassword = '';
        }
      }
    });

    _timer?.cancel();
    if (authState == AuthState.Authenticated || authState == AuthState.Failed) {
      _timer = Timer(Duration(seconds: 3), () {
        setState(() {
          authState = AuthState.Idle;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _database.child('CurrentPassword').once().then((DatabaseEvent snapshot) {
      setState(() {
        originalPassword = snapshot.snapshot.value.toString();
      });
    });

    _database.child('Status').once().then((DatabaseEvent snapshot) {
      setState(() {
        lockStatus = snapshot.snapshot.value.toString();
      });
    });

    if (lockStatus == "Locked") {
      _isLocked = true;
    } else {
      _isLocked = false;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  void backToMain() {
    super.didChangeDependencies();
    // Resume the state here
    _database.child('CurrentPassword').once().then((DatabaseEvent snapshot) {
      setState(() {
        originalPassword = snapshot.snapshot.value.toString();
      });
    });

    _database.child('Status').once().then((DatabaseEvent snapshot) {
      setState(() {
        lockStatus = snapshot.snapshot.value.toString();
      });
    });

    if (lockStatus == "Locked") {
      _isLocked = false;
    } else {
      _isLocked = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    passcodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      if (_isLocked) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  Future<void> navigateToKeypadPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Keypad()),
    );

    // Perform an action based on the result
    setState(() {
      backToMain();
      _toggleLock();
    });
  }

  @override
  Widget build(BuildContext context) {
    while (lockStatus == null) {}

    return Scaffold(
      appBar: AppBar(
        title: Text('Keypad'),
      ),
      body: Column(
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _isLocked ? Colors.red.shade900 : Colors.green.shade900,
                    _isLocked ? Colors.red.shade600 : Colors.green.shade600
                  ],
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _isLocked ? Colors.red.shade800 : Colors.green.shade800,
                        _isLocked ? Colors.red.shade300 : Colors.green.shade300
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _isLocked ? Icons.lock : Icons.lock_open,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: _isLocked ? 0 : null,
                        right: _isLocked ? null : 0,
                        top: 0,
                        bottom: 0,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget? child) {
                            return Container(
                              width: 100 * _animation.value,
                              color: Color.fromARGB(150, 23, 100, 154),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (lockStatus == "Locked")
            Container(
              child: Text(
                'Locked',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          if (lockStatus == "Unlocked")
            Container(
              child: Text(
                'Unlocked',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 252, 254, 252),
              child: GestureDetector(
                onTap: () async {
                  var availability = await FlutterNfcKit.nfcAvailability;
                  if (availability != NFCAvailability.available) {
                    // oh-no
                  }

                  // timeout only works on Android, while the latter two messages are only for iOS
                  var tag = await FlutterNfcKit.poll(
                    timeout: Duration(seconds: 10),
                    iosMultipleTagMessage: "Multiple tags found!",
                    iosAlertMessage: "Scan your tag",
                  );

                  // read NDEF records if available
                  if (tag.ndefAvailable!) {
                    /// decoded NDEF records (see [ndef.NDEFRecord] for details)
                    /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
                    for (var record
                        in await FlutterNfcKit.readNDEFRecords(cached: false)) {
                      print(record.toString());
                    }

                    /// raw NDEF records (data in hex string)
                    /// `{identifier: "", payload: "00010203", type: "0001", typeNameFormat: "nfcWellKnown"}`
                    for (var record in await FlutterNfcKit.readNDEFRawRecords(
                        cached: false)) {
                      print(jsonEncode(record).toString());
                    }
                  }

                  // Call finish() only once
                  await FlutterNfcKit.finish();
                  // iOS only: show alert/error message on finish
                  await FlutterNfcKit.finish(iosAlertMessage: "Success");
                  // or
                  await FlutterNfcKit.finish(iosErrorMessage: "Failed");
                },
                child: Image.asset('assets/images/rfid.gif'),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    navigateToKeypadPage();
                  },
                  child: Text('Go to Keypad'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
