import 'package:flutter/material.dart';
import 'dart:async';
import 'login-page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(
              email: '',
            )));
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    animation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInCirc));

    startTime();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 97, 119, 127),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Expanded(
                  flex: 4,
                  child: Text(
                    '\n\n\n\nWelcome',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(179, 255, 255, 255),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FadeTransition(
                    opacity: animation,
                    child: Container(
                      width: 1000,
                      height: 1000,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.jpg'),
                        ),
                        boxShadow: [],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Please Wait...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(179, 255, 255, 255),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
