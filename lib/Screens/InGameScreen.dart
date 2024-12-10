import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/AppStrings.dart';
import '../Data/Global.dart';
import '../Data/NodeModel.dart';
import '../Data/ViewModel.dart';
import 'CallScreen.dart';
import 'GameOverScreen.dart';
import 'InfoScreen.dart';
import 'MenuScreen.dart';
import 'StartScreen.dart';
import 'WaitingScreen.dart';

class InGameScreen extends StatefulWidget {
  const InGameScreen({super.key});

  @override
  State<InGameScreen> createState() => InGameScreenState();
}

class InGameScreenState extends State<InGameScreen> with WidgetsBindingObserver {
  Node? node;
  Node? previousNode;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  final Map<String, Map<int, int>> choiceToVariantMapping = {
    'venturi_or_selenari': {
      0: 0,
      1: 1,
    },
    'drone_or_gear': {
      0: 0,
      1: 1,
    }
  };

  int nodeIndex = 0;
  int currentChoice = 0;
  int choice = 0;
  int uniqueKey = 0;
  bool choiceChecking = false;

  int currentNodeId = 3;
  List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  String? lastSelectedOption;
  bool isLoadingProgress = false;
  int currentAct = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastSavedProgress();
    _loadNativeAd();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-4136563182662861/7568711901',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-4136563182662861/6670563208',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('Native ad loaded.');
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: $error');
          ad.dispose();
        },
        onAdClicked: (ad) {
          debugPrint('Native ad clicked.');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white, // Changed to black
        cornerRadius: 0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Color(0xFF28c96d),
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Color(0xFF28c96d),
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Color(0xFF28c96d),
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Color(0xFF28c96d),
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }


  @override
  void dispose() {
    _nativeAd?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> clearProgress() async {
    setState(() {
      messages.clear();
      previousNode = null;
      lastSelectedOption = null;
    });

    await clearUserProgress();
  }

  Future<void> _loadLastSavedProgress() async {
    setState(() {
      isLoadingProgress = true;
    });

    var userProgress = await getUserProgress();
    if (userProgress.isNotEmpty) {
      messages.clear();

      for (var progressNode in userProgress) {
        var savedNode = await getNodeById(progressNode.id);
        if (savedNode != null) {
          messages.add({
            'text': progressNode.text,
            'isNode': true,
            'person': savedNode.person,
            'act': savedNode.act,
          });

          messages.add({
            'text': progressNode.option,
            'isNode': false,
            'act': savedNode.act,
          });
        }
      }

      var lastProgressNode = userProgress.last;
      var lastNode = await getNodeById(lastProgressNode.id);

      if (lastNode != null) {
        setState(() {
          currentAct = lastNode.act!;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final tabController = DefaultTabController.of(context);
          if (tabController != null) {
            tabController.animateTo(lastNode.act!);
          }
        });

        var selectedOption = lastNode.options.firstWhere(
              (option) => option.text == lastProgressNode.option,
          orElse: () => lastNode.options.first,
        );

        if (selectedOption.nextNode != null) {
          currentNodeId = selectedOption.nextNode!;
          await _loadNode(isInitialLoad: true);
        }
      }
    } else {
      await _loadNode(isInitialLoad: true);
    }

    setState(() {
      isLoadingProgress = false;
      if (node != null) {
        _handleNodeAction(node!.action, node!.id);
      }
    });
  }

  Future<void> _navigateToNode(int nextNodeId,
      String selectedOptionText) async {
    if (nextNodeId == 3) {
      await clearProgress();
    }

    setState(() {
      messages.add({
        'text': selectedOptionText,
        'isNode': false,
        'act': node?.act,
      });
      lastSelectedOption = selectedOptionText;
      currentNodeId = nextNodeId;
    });

    await _loadNode();
    _scrollToBottom();
  }

  Future<void> _loadNode({bool isInitialLoad = false}) async {
    var fetchedNode = await getNodeById(currentNodeId);

    if (choiceChecking == true) {
      choiceChecking = false;
      print("Using variant index: $choice");
      nodeIndex = choice;
    } else {
      nodeIndex = 0;
    }

    setState(() {
      if (fetchedNode != null) {
        previousNode = node;
        node = fetchedNode;

        if (previousNode != null && previousNode!.act != fetchedNode.act) {
          currentAct = fetchedNode.act!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final tabController = DefaultTabController.of(context);
            if (tabController != null) {
              tabController.animateTo(fetchedNode.act! - 1);
            }
          });
        }

        if (messages.isEmpty || messages.last['isNode'] == false) {
          messages.add({
            'text': fetchedNode.variant[nodeIndex],
            'isNode': true,
            'person': fetchedNode.person,
            'act': fetchedNode.act,
          });
        }

        if (!isInitialLoad &&
            previousNode != null &&
            lastSelectedOption != null &&
            currentNodeId != 3) {
          try {
            putUserProgress(previousNode!.id, previousNode!.variant[nodeIndex],
                lastSelectedOption!, previousNode!.person!, previousNode!.act!);
          } catch (e) {
            putUserProgress(previousNode!.id, previousNode!.variant[0],
                lastSelectedOption!, previousNode!.person!, previousNode!.act!);
          }
        }

        if (!isLoadingProgress) {
          _handleNodeAction(fetchedNode.action, fetchedNode.id);
        }

        handleActions = true;
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleNodeAction(String? action, int nodeId) async {


    void _showWaitingScreen(int duration,
        String screenName,
        String topText,
        String bottomText,
        bool topTextStyle,
        bool bottomTextStyle,
        double bottomTextDistanceFromBottom,
        double topTextDistanceFromTop) async {

      if(handleActions == true){
        handleActions = false;
        String timerKey = 'timer_key_$screenName';
        print('Starting _showWaitingScreen with key: $timerKey');

        bool isCompleted = await isTimerCompleted(timerKey);
        print('Initial completion check: $isCompleted');

        if (isCompleted) {
          print('Timer was already completed, skipping...');
          return;
        }

        print('Showing waiting screen...');

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WaitingScreen(
                  durationInSeconds: duration,
                  child: InGameScreen(),
                  homeScreen: StartScreen(),
                  timerKey: timerKey,
                  bottomText: bottomText,
                  bottomTextStyle: bottomTextStyle,
                  bottomTextDistanceFromBottom: bottomTextDistanceFromBottom,
                  topTextDistanceFromTop: topTextDistanceFromTop,
                  topText: topText,
                  topTextStyle: topTextStyle,
                  backgroundDrawableName: "waiting_screen_$screenName",
                  onTimerComplete: () async {
                    print('Timer complete callback fired');
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(timerKey, true);
                    
                      Navigator.pop(context);
                      currentNodeId = node!.options[0].nextNode!;
                      _navigateToNode(currentNodeId, node!.options[0].text);
                      _scrollToBottom();

                  },
                  onTimerStatus: (isCompleted) {
                    print('Timer status update: $isCompleted');
                  },
                ),
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

    void _showCallScreen(String option_text, String person,
        String person_avatar) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CallScreen(
                    child: InGameScreen(),
                    option_text: option_text,
                    person: person,
                    person_avatar: person_avatar)),
      );

      currentNodeId = node!.options[0].nextNode!;
      _navigateToNode(currentNodeId, node!.options[0].text);
    }

    void _showGameOverScreen(String topText, bool topTextStyle,
        double topTextDistanceFromTop, String backgroundDrawableName) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GameOverScreen(
                    child: StartScreen(),
                    topText: topText,
                    topTextStyle: topTextStyle,
                    topTextDistanceFromTop: topTextDistanceFromTop,
                    backgroundDrawableName: backgroundDrawableName)),
            (route) => false,
      );
    }

    void _showInfoScreen(String topText, bool topTextStyle,
        double topTextDistanceFromTop, String backgroundDrawableName) {
        currentNodeId = node!.options[0].nextNode!;
        _navigateToNode(currentNodeId, node!.options[0].text);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  InfoScreen(
                      child: InGameScreen(),
                      topText: topText,
                      topTextStyle: topTextStyle,
                      topTextDistanceFromTop: topTextDistanceFromTop,
                      backgroundDrawableName: backgroundDrawableName)),
              (route) => false,
        );
    }

    switch (action) {
      case 'show_ad':
        if(handleActions == true){

          handleActions = false;
        if (_isInterstitialAdLoaded && _interstitialAd != null) {
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _loadInterstitialAd(); // Reload for next time
                  // Continue with the game after ad
                  currentNodeId = node!.options[0].nextNode!;
                  _navigateToNode(currentNodeId, node!.options[0].text);
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('Failed to show ad: $error');
                  ad.dispose();
                  _loadInterstitialAd();
                  // Continue with the game even if ad failed
                  currentNodeId = node!.options[0].nextNode!;
                  _navigateToNode(currentNodeId, node!.options[0].text);
                },
              );

          // Show the ad
          _interstitialAd!.show();

          // Start a timer to force-close the ad after 30 seconds
          Future.delayed(Duration(seconds: 30), () {
            _interstitialAd?.dispose();
            currentNodeId = node!.options[0].nextNode!;
            _navigateToNode(currentNodeId, node!.options[0].text);
          });
        } else {
          // If ad isn't loaded, just continue with the game
          currentNodeId = node!.options[0].nextNode!;
          _navigateToNode(currentNodeId, node!.options[0].text);
        }
    }
        break;

      case 'show_waiting_screen_recruitment':
        _showWaitingScreen(
            10,
            "recruitment",
            AppStrings.get('please_wait'),
            node!.variant[0],
            false,
            true,
            130,
            80);
        break;

      case 'show_waiting_screen_starting':
        _showWaitingScreen(
            10,
            "starting",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;

      case 'show_waiting_screen_hibernation':
        if(handleActions == true) {
          handleActions = false;
          _showWaitingScreen(
              10,
              "hibernation",
              node!.variant[0],
              AppStrings.get('please_wait'),
              true,
              false,
              30,
              50);
        }
        break;

      case 'show_waiting_screen_explosion':
        _showWaitingScreen(
            10,
            "explosion",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;

      case 'show_waiting_screen_crossing':
        _showWaitingScreen(
            10,
            "crossing",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;

      case 'show_waiting_screen_returning_to_ship':
        _showWaitingScreen(
            10,
            "returning_to_ship",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;

      case 'show_waiting_screen_climbing':
        _showWaitingScreen(
            10,
            "climbing",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;


      case 'show_waiting_screen_analysis':
        _showWaitingScreen(
            10,
            "analysis",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            60,
            80);
        break;

      case 'show_waiting_screen_alien':
        _showWaitingScreen(
            10,
            "alien",
            node!.variant[0],
            AppStrings.get('please_wait'),
            true,
            false,
            30,
            80);
        break;

      case 'show_officer_call_screen':
        _showCallScreen(
            node!.options[0].text, node!.person!, "recruitment_officer");
        break;

      case 'show_control_center_call_screen':
        _showCallScreen(node!.options[0].text, node!.person!, "control_center");
        break;

      case 'show_survivor_call_screen':
        _showCallScreen(node!.options[0].text, node!.person!, "survivor");
        break;

      case 'info_screen_crystal_shaking':
        _showInfoScreen(
            node!.variant[0], true, 60, "info_screen_crystal_shaking");
        break;

      case 'game_over_storm':
        _showGameOverScreen(
            node!.variant[0].toUpperCase(), true, 80, "game_over_coldness");
        break;

      case 'game_over_coldness':
        _showGameOverScreen(
            node!.variant[0].toUpperCase(), true, 80, "game_over_coldness");
        break;

      case 'game_over_crystal_explosion':
        _showGameOverScreen(node!.variant[0].toUpperCase(), true, 80,
            "game_over_crystal_explosion");
        break;

      case 'game_over_gas_intoxication':
        _showGameOverScreen(node!.variant[0].toUpperCase(), true, 80,
            "game_over_gas_intoxication");
        break;

      case 'game_over_storm':
        _showGameOverScreen(node!.variant[0].toUpperCase(), true, 80,
            "waiting_screen_explosion");
        break;

      case 'game_over_ship_explosion':
        _showGameOverScreen(node!.variant[0].toUpperCase(), true, 40,
            "game_over_ship_explosion");
        break;

      case 'game_over_black_hole':
        _showGameOverScreen(
            node!.variant[0].toUpperCase(), true, 80, "game_over_black_hole");
        break;

      case 'game_over_cliff_fall':
        _showGameOverScreen(
            node!.variant[0].toUpperCase(), true, 40, "game_over_cliff_fall");
        break;

      case 'game_over_void_fall':
        _showGameOverScreen(
            node!.variant[0].toUpperCase(), true, 40, "game_over_cliff_fall");
        break;

      case 'check_starting_criteria':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? startingCriteria = await prefs.getInt('starting_criteria');
        if (startingCriteria != 0) {
          _showGameOverScreen(
              AppStrings.get('ship_exploded'), true, 40,
              "game_over_ship_explosion");
        }
        else {
          _showWaitingScreen(
              10,
              "starting",
              AppStrings.get('ship_starting'),
              AppStrings.get('please_wait'),
              true,
              false,
              30,
              80);
        }
        break;

      case 'save_starting_criteria':
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // First check if it was ever 1
        bool wasEverOne = prefs.getBool('starting_criteria_was_one') ?? false;

        // If it was ever 1, or currentChoice is 1 now
        if (currentChoice == 1 || wasEverOne) {
          // Save that it was 1
          await prefs.setBool('starting_criteria_was_one', true);
          // Force save as 1
          await prefs.setInt('starting_criteria', 1);
          print('Saved starting criteria: 1 (locked)');
        } else {
          // Normal save behavior if never was 1
          await prefs.setInt('starting_criteria', currentChoice);
          print('Saved starting criteria: $currentChoice');
        }
        break;

      case 'save_choice_venturi_or_selenari':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('class_choice', currentChoice);
        print('Saved class choice: $currentChoice');
        break;

      case 'check_choice_venturi_or_selenari':
        choiceChecking = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int savedChoice = (await prefs.getInt('class_choice'))!;
        choice =
            choiceToVariantMapping['venturi_or_selenari']?[savedChoice] ?? 0;
        break;

      case 'save_choice_drone_or_gear':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('gear_choice', currentChoice);
        print('Saved gear choice: $currentChoice');
        break;

      case 'check_choice_drone_or_gear':
        choiceChecking = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int savedChoice = (await prefs.getInt('gear_choice'))!;
        choice = choiceToVariantMapping['drone_or_gear']?[savedChoice] ?? 0;
        break;

      default:
        print('action undefined');
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery
        .of(context)
        .size
        .width - 30;

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
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      Spacer(),
                      Container(
                        height: 40.0,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MenuScreen()
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                          ),
                          child: Row(
                            children: [
                              Text(
                                AppStrings.get('menu'),
                                style: TextStyle(
                                  color: Color(0xFF28c96d),
                                  fontSize: 16,
                                  fontFamily: 'VT323',
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Icon(Icons.menu, color: Color(0xFF28c96d)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                    ],
                  ),
                ),
                Expanded(
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
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: message['isNode']
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, top: 10.0),
                                child: Text(
                                  message['person'] ?? "",
                                  style: TextStyle(
                                    color: Color(0xFF28c96d),
                                    fontSize: 14,
                                    fontFamily: 'VT323',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        switch (message['person']) {
                                          'Oficer rekrutujący' =>
                                          'assets/drawables/recruitment_officer_avatar.png',
                                          'Recruitment Officer' =>
                                          'assets/drawables/recruitment_officer_avatar.png',
                                          'Centrum kontroli lotu' =>
                                          'assets/drawables/control_center_avatar.png',
                                          'Mission Control Center' =>
                                          'assets/drawables/control_center_avatar.png',
                                          'ECHO' =>
                                          'assets/drawables/echo_avatar.png',
                                          "Harûn'kal" =>
                                          'assets/drawables/alien_avatar.png',
                                          'Rozbitek' =>
                                          'assets/drawables/survivor_avatar.png',
                                          'Survivor' =>
                                          'assets/drawables/survivor_avatar.png',
                                          String() =>
                                          'assets/drawables/recruitment_officer_avatar.png',
                                          _ =>
                                          'assets/drawables/recruitment_officer_avatar.png',
                                        },
                                        width: 40.0,
                                        height: 40.0,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                        ),
                                        padding: EdgeInsets.only(
                                            bottom: 6.0,
                                            right: 8.0,
                                            left: 8.0),
                                        child: Text(
                                          message['text'],
                                          style: TextStyle(
                                            color: Color(0xFF28c96d),
                                            fontSize: 18,
                                            fontFamily: 'VT323',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                              : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF28c96d),
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 8.0),
                                  child: Text(
                                    message['text'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'VT323',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: containerWidth,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Color(0xFF28c96d),
                      width: 7,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  child: node == null
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                    List.generate(node!.options.length, (index) {
                      BorderRadius borderRadius;
                      if (node!.options.length == 1) {
                        borderRadius = BorderRadius.circular(16.0);
                      } else if (index == 0) {
                        borderRadius = BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        );
                      } else if (index == node!.options.length - 1) {
                        borderRadius = BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        );
                      } else {
                        borderRadius = BorderRadius.zero;
                      }

                      return ClipRRect(
                        borderRadius: borderRadius,
                        child: GestureDetector(
                          onTap: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            if (prefs.getBool("sfxEnabled") ?? true) {
                              await AudioPlayer()
                                  .play(AssetSource('sound/click.mp3'));
                            }
                            resetTimer('hibernation');
                            handleActions = true;
                            currentChoice = index;
                            _navigateToNode(
                              node!.options[index].nextNode!,
                              node!.options[index].text,
                            );
                          },
                          child: Container(
                            width: containerWidth,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                top: index != 0
                                    ? BorderSide(
                                    color: Color(0xFF28c96d),
                                    width: 7)
                                    : BorderSide.none,
                              ),
                            ),
                            padding:
                            EdgeInsets.symmetric(vertical: 16.0),
                            alignment: Alignment.center,
                            child: Text(
                              node!.options[index].text,
                              style: TextStyle(
                                color: Color(0xFF28c96d),
                                fontSize: 18,
                                fontFamily: 'VT323',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 100), // Space for the ad
              ],
            ),
            if (_isNativeAdLoaded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 90,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  padding: EdgeInsets.zero, // Remove any padding
                  child: AdWidget(ad: _nativeAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}