import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'BackgroundSoundService.dart';
import 'Data/AppStrings.dart';
import 'Data/Global.dart';
import 'Data/JSONParser.dart';
import 'Data/NodeModel.dart';
import 'Data/NodesProgressModel.dart';
import 'Screens/StartScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NodeAdapter());
  Hive.registerAdapter(OptionAdapter());
  Hive.registerAdapter(UserProgressNodeAdapter());

  nodeBox = await Hive.openBox<Node>('nodeBox');
  userProgressBox = await Hive.openBox<UserProgressNode>('userProgress');

  await loadJsonToHive();

  // Initialize background music
  final backgroundMusic = BackgroundSoundService();
  await backgroundMusic.initialize();


  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
  ));

 await AppStrings.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final BackgroundSoundService _backgroundMusic = BackgroundSoundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _backgroundMusic.play();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundMusic.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:  // Add this case
        _backgroundMusic.pause();
        break;
      case AppLifecycleState.resumed:
        _backgroundMusic.play();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.black
      ),
      home: StartScreen(),
    );
  }
}