import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/AppStrings.dart';
import '../Data/Global.dart';

class WaitingScreen extends StatefulWidget {
  final int durationInSeconds;
  final Widget child;
  final String? message;
  final String? action;
  final Widget homeScreen;
  final String timerKey;
  final VoidCallback? onTimerComplete;
  final Function(bool)? onTimerStatus;

  final String backgroundDrawableName;
  final String topText;
  final double topTextDistanceFromTop;
  final bool topTextStyle;           //false - black and big, true - green and small
  final String bottomText;
  final double bottomTextDistanceFromBottom;
  final bool bottomTextStyle;     //false - black and big, true - green and small

  const WaitingScreen({
    Key? key,
    required this.durationInSeconds,
    required this.child,
    required this.action,
    required this.homeScreen,
    required this.timerKey,
    required this.topText,
    required this.topTextStyle,
    required this.topTextDistanceFromTop,
    required this.bottomText,
    required this.bottomTextStyle,
    required this.bottomTextDistanceFromBottom,
    required this.backgroundDrawableName,
    this.message,
    this.onTimerComplete,
    this.onTimerStatus,
  }) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isLocked = true;
  bool _isInitialized = false;
  final String _endTimeKey = '_endTime';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeTimer();
    _checkTimerStatus();
  }

  _getTextStyle(bool style) {
    if(style == true) {
      return TextStyle(fontFamily: 'mnc', fontSize: 24.0, color: Color(0xFF219653));
    } else {
      return TextStyle(
        fontFamily: 'VT323',
        fontSize: 46.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );
    }
  }

  Future<void> _checkTimerStatus() async {
    final isCompleted = await isTimerCompleted(widget.timerKey);
    widget.onTimerStatus?.call(isCompleted);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child),
              (route) => false,
        );
      },
    );

    final prefsInstance = await prefs;
    final notificationsEnabledPref = prefsInstance.getBool("notificationsEnabled") ?? true;

    if (notificationsEnabledPref == true) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'timer_completion',
      'Timer Notifications',
      channelDescription: 'Notifications for timer completion',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final prefsInstance = await prefs;
    final notificationsEnabledPref = prefsInstance.getBool("notificationsEnabled") ?? true;
    if (notificationsEnabledPref == true) {

      await flutterLocalNotificationsPlugin.show(
        0,
        '',
        AppStrings.get(widget.action!)+
        AppStrings.get('notification_content'),
        platformChannelSpecifics,
      );
    }
  }

  Future<void> _initializeTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final endTimeMillis = prefs.getInt('${widget.timerKey}$_endTimeKey');

    if (endTimeMillis != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
      final now = DateTime.now();

      if (endTime.isAfter(now)) {
        _remainingSeconds = endTime.difference(now).inSeconds;
        widget.onTimerStatus?.call(false); // Timer is still running
      } else {
        _remainingSeconds = 0;
        _isLocked = false;
        widget.onTimerStatus?.call(true); // Timer has completed
      }
    } else {
      _remainingSeconds = widget.durationInSeconds;
      final endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
      await prefs.setInt('${widget.timerKey}$_endTimeKey', endTime.millisecondsSinceEpoch);
      widget.onTimerStatus?.call(false); // New timer started
    }

    setState(() {
      _isInitialized = true;
    });

    if (_isLocked && _remainingSeconds > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isLocked = false;
          _timer.cancel();
          _clearTimer();
          _showNotification();
          widget.onTimerStatus?.call(true); // Timer completed
          widget.onTimerComplete?.call();
        }
      });
    });
  }

  Future<void> _clearTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.timerKey}$_endTimeKey');
    await prefs.remove(widget.timerKey);
  }

  Future<bool> _onWillPop() async {
    if (!_isLocked) return true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget.homeScreen),
          (route) => false,
    );
    return false;
  }

  @override
  void dispose() {
    if (_isLocked && _remainingSeconds > 0) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    child: Image(
                      image: AssetImage('assets/drawables/${widget.backgroundDrawableName}.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: widget.topTextDistanceFromTop,
                  left: 20,
                  right: 20,
                  child: Center(
                      child: Text(
                        widget.topText,
                        textAlign: TextAlign.center,
                        style: _getTextStyle(widget.topTextStyle),
                      )
                  ),
                ),
                Positioned(
                  bottom: widget.bottomTextDistanceFromBottom,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF219653).withOpacity(0.4),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.bottomText,
                        textAlign: TextAlign.center,
                        style: _getTextStyle(widget.bottomTextStyle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}