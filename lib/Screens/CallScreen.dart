import 'package:flutter/material.dart';
import 'package:blinking_text/blinking_text.dart';

import '../Data/Global.dart';

class CallScreen extends StatefulWidget {
  final String person_avatar;
  final String option_text;
  final String person;
  final Widget child;

  const CallScreen({Key? key,
    required this.person_avatar,
    required this.person,
    required this.option_text,
    required this.child
  }) : super(key: key);

  @override
  State<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 30;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Image.asset(
              'assets/drawables/0.png',
              key: ValueKey<int>(0),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => widget.child),
                          (route) => false,
                    );
                  },
                  child: Container(
                    width: containerWidth,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Color(0xFF28c96d),
                        width: 7.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(
                                'assets/drawables/${widget.person_avatar}_avatar.png',
                                width: 120.0,
                                height: 120.0,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              widget.person,
                              style: TextStyle(
                                color: Color(0xFF28c96d),
                                fontSize: 24,
                                fontFamily: 'VT323',
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 60.0),
                          child: BlinkText(
                            widget.option_text,
                            style: TextStyle(
                                fontFamily: 'VT323',
                                fontSize: 24.0,
                                color: Color(0xFF035f0a)
                            ),
                            duration: Duration(seconds: 2),
                            endColor: Color(0xFF34f285),
                          ),
                        ),
                      ],
                    ),
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