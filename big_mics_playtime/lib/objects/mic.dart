import 'package:noise_meter/noise_meter.dart';
import 'dart:async';

class Mic {
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  double maxVol = 0.0;
  double minVol = 50.0;
  bool recording = false;
  NoiseMeter noiseMeter = NoiseMeter();

  Future<void> start() async {
    _latestReading = null;
    maxVol = 0;
    _noiseSubscription = noiseMeter.noise.listen(onData);

  }

  void stop() {
    _noiseSubscription?.cancel();
  }

  void onData(NoiseReading noiseReading) {
    _latestReading = noiseReading;
    if (_latestReading != null) {
      if (_latestReading!.meanDecibel > maxVol) {
        maxVol = _latestReading!.meanDecibel;
      }
    }
  }
  NoiseReading? getLatestReading() {
    return _latestReading;
  }
}