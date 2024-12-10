import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/AppStrings.dart';
import '../Data/Global.dart';
import 'InGameScreen.dart';
import 'IntroScreen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Extract the tap handling logic into a separate method
  Future<void> _handleTap() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sfxEnabled') ?? true) {
      await AudioPlayer().play(AssetSource('sound/click2.mp3'));
    }

    if(userProgressBox.isEmpty){
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => IntroScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => InGameScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Image(
                  image: AssetImage('assets/drawables/start.gif'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF28c96d),
                      width: 7.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  AppStrings.get('app_title'),
                  style: TextStyle(fontFamily: 'mnc', fontSize: 36.0, color: Color(0xFF28c96d)),
                ),
              ),
            ),
            Positioned(
              bottom: 60.0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _handleTap,
                  child: BlinkText(
                    AppStrings.get("click_to_start"),
                    style: TextStyle(fontFamily: 'VT323', fontSize: 24.0, color: Color(0xFF035f0a)),
                    duration: Duration(seconds: 2),
                    endColor: Color(0xFF34f285),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}