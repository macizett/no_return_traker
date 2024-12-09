import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSoundService {
  static final BackgroundSoundService _instance = BackgroundSoundService._internal();
  final prefs = SharedPreferences.getInstance();
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  factory BackgroundSoundService() {
    return _instance;
  }

  BackgroundSoundService._internal() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Set looping
    await _audioPlayer.setSourceAsset('sound/background_music.mp3');
    await _audioPlayer.setVolume(0.8); // Set volume (0.0 to 1.0)
  }

  Future<void> play() async {
    final prefsInstance = await prefs;
    bool musicEnabled = prefsInstance.getBool("musicEnabled") ?? true;
    if (!_isPlaying && musicEnabled) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}