import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BackgroundSoundService.dart';
import '../Data/AppStrings.dart';
import '../Data/ViewModel.dart';
import 'StartScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool musicEnabled = true;
  bool sfxEnabled = true;
  bool notificationsEnabled = true;

  final backgroundSound = BackgroundSoundService();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      musicEnabled = prefs.getBool('musicEnabled') ?? true;
      sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Color(0xFF28c96d),
                width: 7.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('reset'),
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 40.0,
                    color: Color(0xff4ec557),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  AppStrings.get('reset_message'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 24.0,
                    color: Color(0xff4ec557),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff4ec557),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      child: Text(
                        AppStrings.get('no'),
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 24.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        clearUserProgress();
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StartScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff4ec557),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      child: Text(
                        AppStrings.get('yes'),
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 24.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                  onTap: () {},
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
                    child: Stack(
                      children: [
                        // Back Button
                        Positioned(
                          left: 16,
                          top: 16,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xff4ec557),
                              size: 32,
                            ),
                          ),
                        ),
                        // Main Content
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    AppStrings.get('menu'),
                                    style: TextStyle(
                                      fontFamily: 'VT323',
                                      fontSize: 40.0,
                                      color: Color(0xff4ec557),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        musicEnabled = !musicEnabled;
                                        saveSettings('musicEnabled', musicEnabled);
                                      });

                                      if (musicEnabled == true) {
                                        await backgroundSound.play();
                                      } else {
                                        await backgroundSound.pause();
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppStrings.get('music'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                        Text(
                                          musicEnabled ? AppStrings.get('on') : AppStrings.get('off'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        sfxEnabled = !sfxEnabled;
                                        saveSettings('sfxEnabled', sfxEnabled);
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppStrings.get('sfx'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                        Text(
                                          sfxEnabled ? AppStrings.get('on') : AppStrings.get('off'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        notificationsEnabled = !notificationsEnabled;
                                        saveSettings('notificationsEnabled', notificationsEnabled);
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppStrings.get('notifications'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                        Text(
                                          notificationsEnabled ? AppStrings.get('on') : AppStrings.get('off'),
                                          style: TextStyle(
                                            fontFamily: 'VT323',
                                            fontSize: 24.0,
                                            color: Color(0xff4ec557),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _showResetConfirmationDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff4ec557),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  minimumSize: Size.fromHeight(50),
                                ),
                                child: Text(
                                  AppStrings.get('reset'),
                                  style: TextStyle(
                                    fontFamily: 'VT323',
                                    fontSize: 24.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
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