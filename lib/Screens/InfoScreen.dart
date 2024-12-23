import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';

import '../Data/AppStrings.dart';

class InfoScreen extends StatelessWidget {
  final Widget child;
  final String backgroundDrawableName;
  final String topText;
  final double topTextDistanceFromTop;
  final bool topTextStyle;           //false - black and big, true - green and small

  const InfoScreen({
    Key? key,
    required this.child,
    required this.topText,
    required this.topTextStyle,
    required this.topTextDistanceFromTop,
    required this.backgroundDrawableName,
  }) : super(key: key);

  TextStyle _getTextStyle(bool style) {
    if(style == true) {
      return TextStyle(fontFamily: 'mnc', fontSize: 18.0, color: Color(0xFF219653));
    } else {
      return TextStyle(fontFamily: 'VT323', fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold);
    }
  }

  void _handleNavigation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => _handleNavigation(context),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    child: Image(
                      image: AssetImage('assets/drawables/$backgroundDrawableName.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: topTextDistanceFromTop,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                        child: Text(
                          topText,
                          textAlign: TextAlign.center,
                          style: _getTextStyle(topTextStyle),
                        )
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _handleNavigation(context),
                      child: BlinkText(
                        AppStrings.get('click_to_continue'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 24.0,
                            color: Color(0xFF035f0a)
                        ),
                        duration: Duration(seconds: 2),
                        endColor: Color(0xFF34f285),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}