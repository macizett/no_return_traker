import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Data/AppStrings.dart';
import '../Data/Global.dart';
import 'InGameScreen.dart';
import 'IntroScreen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isAdShown = false;  // Track if ad has been shown

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only handle resume events if we're still on the StartScreen and haven't shown the ad
    if (state == AppLifecycleState.resumed && mounted && !_isAdShown) {
      _loadAppOpenAd();
    }
  }

  void _loadAppOpenAd() {
    // Don't load if we've already shown the ad
    if (_isAdShown) return;

    AppOpenAd.load(
      adUnitId: 'ca-app-pub-4136563182662861/7704341646',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
          _showAppOpenAd();
        },
        onAdFailedToLoad: (error) {
          print('App open ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (!_isAdLoaded || _isAdShown) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAdShown = true;  // Mark ad as shown
        print('App open ad showed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('App open ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isAdLoaded = false;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('App open ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        _isAdLoaded = false;
      },
    );

    _appOpenAd!.show();
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
                onTap: () async {
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
                },
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
                child: BlinkText(
                  AppStrings.get("click_to_start"),
                  style: TextStyle(fontFamily: 'VT323', fontSize: 24.0, color: Color(0xFF035f0a)),
                  duration: Duration(seconds: 2),
                  endColor: Color(0xFF34f285),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}