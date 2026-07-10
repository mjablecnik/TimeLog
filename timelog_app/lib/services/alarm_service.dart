import 'dart:developer' as dev;

import 'package:audioplayers/audioplayers.dart';

class AlarmService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> play() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/alarm.mp3'));
      _isPlaying = true;
    } catch (e, st) {
      dev.log('AlarmService: failed to play alarm', error: e, stackTrace: st);
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop().timeout(const Duration(milliseconds: 200));
      _isPlaying = false;
    } catch (e, st) {
      dev.log('AlarmService: failed to stop alarm', error: e, stackTrace: st);
      _isPlaying = false;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
