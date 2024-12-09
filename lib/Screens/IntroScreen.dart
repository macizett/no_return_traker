import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/AppStrings.dart';
import '../Data/NodeModel.dart';
import '../Data/ViewModel.dart';
import 'InGameScreen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  Node? node; // Declare node as nullable since it might be null initially
  int index = 0;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  Future<void> _loadNode() async {
    var fetchedNode = await getNodeById(index);
    setState(() {
      node = fetchedNode; // Set the node when data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  if (prefs.getBool('sfxEnabled') ?? true) {
                    await AudioPlayer().play(AssetSource('sound/click2.mp3'));
                  }

                  if (index <= 1) {
                    setState(() {
                      index++;
                    });
                    _loadNode(); // Load the next node when index is incremented
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InGameScreen(),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500), // Transition duration
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Image.asset(
                      'assets/drawables/$index.png', // Use the index to select the image
                      key: ValueKey<int>(index),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: IgnorePointer(
                ignoring: true,
                child:AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child); // Fade transition effect
                  },
                  child:  Text(
                  node!.options[0].text,
                  key: ValueKey<String>(node!.options[0].text),
                  style: TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 20.0,
                      color: Color(0xFF28c96d)),
                ),
                )
              )
            ),

            Positioned(
              top: 30, // Position 30 dpi from the top
              left: 20,
              right: 20,
              child: node == null
                  ? CircularProgressIndicator() // Show a loading indicator while node is null
                  : IgnorePointer(
                ignoring: true,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child); // Fade transition effect
                  },
                  child: Text(
                    node!.variant[0], // Access the node text when it's loaded
                    key: ValueKey<String>(node!.variant[0]), // Update key based on text
                    style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 24.0,
                        color: Color(0xFF28c96d)),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60.0, // Position 60 dpi from the bottom
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  ignoring: true,
                  child: BlinkText(
                    AppStrings.get('click_to_continue'),
                    style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 24.0,
                        color: Color(0xFF035f0a)),
                    duration: Duration(seconds: 2),
                    endColor: Color(0xFF34f285),
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
