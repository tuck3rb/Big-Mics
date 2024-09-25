import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Forces portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Big Mic-s Playtime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  int currentPageIndex = 0;
  NoiseMeter noiseMeter = NoiseMeter();
  double maxVol = 0.0;
  double minVol = 30.0;
  bool recording = true;


@override
void initState() {
  super.initState();
  requestPermission();
  noiseMeter = NoiseMeter();
  }
  
  Future<bool> checkPermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<PermissionStatus> requestPermission() async {
    PermissionStatus permissionStatus = await Permission.microphone.request();
    return permissionStatus;
  }

  Future<void> start() async {
    _latestReading = null;
    maxVol = 0;
    _noiseSubscription = noiseMeter.noise.listen(onData);
    print(_noiseSubscription);
    setState(() => recording = true);
  }

  void stop() {
    _noiseSubscription?.cancel();
    setState(() => recording = false);
  }

  void onData(NoiseReading noiseReading) => setState(() {
    _latestReading = noiseReading;
    if (_latestReading != null) {
      if (_latestReading!.meanDecibel > maxVol) {
        maxVol = _latestReading!.meanDecibel;
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        // Play page
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Make noise to jump.',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 20), // Functions as a spacer
                Container( 
                  width: 350,
                  height: 350,
                  child: Placeholder(), // Future implementation of game
                ),
                const SizedBox(height: 20), // Functions as a spacer
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Score: ', // Will need to update this to be non const and add in score variable
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 50),
                    const Text(
                      'High Score: ', // Will need to update this to be non const and add in high_score variable
                      style: TextStyle(fontSize: 15),)
                  ]
                ),
                const SizedBox(height: 20), // Functions as a spacer
              ],
            ),
          ),
        ),
        // Mic Test page
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  _latestReading != null
                    ? _latestReading!.meanDecibel
                      .toString()
                      .substring(0, 2)
                    : '0',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 30), // Functions as a spacer
                Container( 
                  width: 75,
                  height: 400,
                  child: Placeholder(), // Mic test bar
                ),
                const SizedBox(height: 30), // Functions as a spacer
                RawMaterialButton(
                  onPressed: recording ? stop : start,
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.mic,
                    size: 35.0,
                  ),
                ),
              ],
            ),
          ),
        ),
    ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.grey,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.play_arrow),
            icon: Icon(Icons.play_arrow),
            label: 'Play',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.mic),
            icon: Icon(Icons.mic),
            label: 'Test',
          ),
        ],
      ),
    );
  }

}
