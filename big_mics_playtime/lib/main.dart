import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:big_mics_playtime/objects/mic.dart';



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
  int currentPageIndex = 0;
  Mic mic = Mic();
  late Timer timer;

@override
void initState() {
  super.initState();
  requestPermission();
  }
  
  Future<bool> checkPermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<PermissionStatus> requestPermission() async {
    PermissionStatus permissionStatus = await Permission.microphone.request();
    return permissionStatus;
  }



  void micStart() async{
    mic.start();
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() => mic.recording = true);
    });
  }
  void micStop() {
    mic.stop();
    cancelTimer();
    setState(() => mic.recording = false);
  }

  void cancelTimer() {
    timer.cancel();
  }

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
                  mic.getLatestReading()!= null
                    ? mic.getLatestReading()!.meanDecibel
                      .toString()
                      .substring(0, 2)
                    : '0',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 30), // Functions as a spacer
                Container(
                  width: 75,
                  height:300,
                  alignment: Alignment.bottomCenter,
                  child: Container( 
                    width: 75,
                    height: mic.getLatestReading() != null
                      ? mic.getLatestReading()!.meanDecibel * 4
                  
                      : 20,
                      color: Colors.green,
                     // Mic test bar
                  ),
                ),
                const SizedBox(height: 30), // Functions as a spacer
                RawMaterialButton(
                  onPressed: mic.recording ? micStop : micStart,
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
