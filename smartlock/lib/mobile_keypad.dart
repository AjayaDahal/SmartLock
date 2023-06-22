import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

enum AuthState { Idle, Recording, Authenticated, Failed }

class Keypad extends StatefulWidget {
  @override
  _KeypadState createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  AuthState authState = AuthState.Idle;
  String originalPassword = '';
  String enteredPassword = '';
  Timer? _timer;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('Lock');

  TextEditingController passcodeController = TextEditingController();
  bool showNewPasswordField = false;

  late String lockStatus;

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keypad'),
      ),
      body: Container(
        alignment: Alignment.bottomLeft,
        color: Color.fromARGB(255, 255, 255, 255),
        padding: EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(44, 44, 44, 44),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KeypadButton(
                          text: '1',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('1'),
                        ),
                        KeypadButton(
                          text: '2',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('2'),
                        ),
                        KeypadButton(
                          text: '3',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('3'),
                        ),
                        KeypadButton(
                          text: 'A',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('A'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KeypadButton(
                          text: '4',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('4'),
                        ),
                        KeypadButton(
                          text: '5',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('5'),
                        ),
                        KeypadButton(
                          text: '6',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('6'),
                        ),
                        KeypadButton(
                          text: 'B',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('B'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KeypadButton(
                          text: '7',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('7'),
                        ),
                        KeypadButton(
                          text: '8',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('8'),
                        ),
                        KeypadButton(
                          text: '9',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('9'),
                        ),
                        KeypadButton(
                          text: 'C',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('C'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KeypadButton(
                          text: '*',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('*'),
                        ),
                        KeypadButton(
                          text: '0',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('0'),
                        ),
                        KeypadButton(
                          text: '#',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('#'),
                        ),
                        KeypadButton(
                          text: 'D',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          onPressed: () => updatePassword('D'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (authState != AuthState.Idle)
                      AnimatedOpacity(
                        opacity: authState == AuthState.Recording ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          'Enter password',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (authState == AuthState.Authenticated)
                      AnimatedOpacity(
                        opacity:
                            authState == AuthState.Authenticated ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          'Authentication Successful',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (authState == AuthState.Failed)
                      AnimatedOpacity(
                        opacity: authState == AuthState.Failed ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          'Authentication Failed',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    SizedBox(height: 10.0),
                    if (showNewPasswordField)
                      TextField(
                        controller: passcodeController,
                        decoration: InputDecoration(
                          hintText: 'Enter new password',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    SizedBox(height: 10.0),
                    if (showNewPasswordField)
                      ElevatedButton(
                        onPressed: () {
                          if (passcodeController.text.isNotEmpty) {
                            _database
                                .child('CurrentPassword')
                                .set(passcodeController.text);
                            setState(() {
                              originalPassword = passcodeController.text;
                              passcodeController.clear();
                              showNewPasswordField = false;
                            });
                          }
                        },
                        child: Text('Update Password'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeypadButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Function onPressed;

  const KeypadButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: TextButton(
        onPressed: () => onPressed(),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 24.0),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
      ),
    );
  }
}
