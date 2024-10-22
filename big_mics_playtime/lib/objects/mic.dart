import 'package:noise_meter/noise_meter.dart';
import 'dart:async';

class Mic {
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  double maxVol = 0.0; //The highest recorded mic reading
  double minVol = 60.0; //The value required for Bic Mic to jump
  bool recording = false;
  NoiseMeter noiseMeter = NoiseMeter();

  //Starts the mic, updating _latestReading and maxVol until stop is
  //called
  Future<void> start() async {
    _latestReading = null;
    maxVol = 0;
    _noiseSubscription = noiseMeter.noise.listen(onData);

  }
  //Stops the mic and stopls _latestReading and maxVol from updating.
  void stop() {
    _noiseSubscription?.cancel();
  }

  //The method that the noiseMeter listens to when start is called
  //Sets the maxVol as well as the _latestReading
  //Use _latestReading!.meanDecibel if you want _latestReading as a double.
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