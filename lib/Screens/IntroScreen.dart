import 'package:audioplayers/audioplayers.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Data/AppStrings.dart';
import '../Data/NodeModel.dart';
import '../Data/ViewModel.dart';
import 'InGameScreen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> with WidgetsBindingObserver {
  Node? node;
  int index = 0;
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isAdShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNode();
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
    if (state == AppLifecycleState.resumed && mounted && !_isAdShown) {
      _loadAppOpenAd();
    }
  }

  void _loadAppOpenAd() {
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
        _isAdShown = true;
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

  Future<void> _loadNode() async {
    var fetchedNode = await getNodeById(index);
    setState(() {
      node = fetchedNode;
    });
  }

  // Shared navigation function
  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sfxEnabled') ?? true) {
      await AudioPlayer().play(AssetSource('sound/click2.mp3'));
    }

    if (index <= 1) {
      setState(() {
        index++;
      });
      _loadNode();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InGameScreen(),
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
              child: GestureDetector(
                onTap: _handleNavigation,
                child: SizedBox(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Image.asset(
                      'assets/drawables/$index.png',
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
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        node!.options[0].text,
                        key: ValueKey<String>(node!.options[0].text),
                        style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 20.0,
                            color: Color(0xFF28c96d)
                        ),
                      ),
                    )
                )
            ),
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: node == null
                  ? CircularProgressIndicator()
                  : IgnorePointer(
                ignoring: true,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    node!.variant[0],
                    key: ValueKey<String>(node!.variant[0]),
                    style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 24.0,
                        color: Color(0xFF28c96d)
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60.0,
              left: 0,
              right: 0,
              child: Center(
                  child: GestureDetector(
                    onTap: _handleNavigation,
                    child: BlinkText(
                      AppStrings.get('click_to_continue'),
                      style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 24.0,
                          color: Color(0xFF035f0a)
                      ),
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