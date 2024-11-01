import 'dart:async';
import 'package:big_mics_playtime/widgets/BigMic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:big_mics_playtime/objects/mic.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  late BigMic bigMicGame;
  int currentScore = -1;
  int highScore = 0;
  bool isGameActive = false;
  bool showMenu = true;

  @override
  void initState() {
    super.initState();
    bigMicGame = BigMic(
      onScoreChanged: (newScore) {
        setState(() {
          currentScore = newScore;
          if (currentScore > highScore) {
            highScore = currentScore;
          }
        });
      },
      onGameOver: () {
        setState(() {
          isGameActive = false;
          showMenu = true;
        });
      },
    );
    requestPermission();
  }

  Future<bool> checkPermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<PermissionStatus> requestPermission() async {
    return await Permission.microphone.request();
  }

  void startNewGame() {
    setState(() {
      isGameActive = true;
      showMenu = false;
      if (BigMic.of(context) != null) {
        BigMic.of(context)!.resetGame();
      }
    });
  }

  void micStart() async {
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

  Widget buildGameMenu() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Big Mic\'s Playtime',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: startNewGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text('Start Game', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          Text(
            'High Score: $highScore',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentPageIndex = 1; // Switch to mic test page
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child:
                const Text('Test Microphone', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Score: $currentScore',
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            'High Score: $highScore',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: startNewGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text('Play Again', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showMenu = true;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text('Main Menu', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        // Play page
        SafeArea(
          child: showMenu
              ? buildGameMenu()
              : isGameActive
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Make noise to jump.',
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 350,
                            height: 350,
                            child: bigMicGame,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Score: $currentScore',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 50),
                              Text(
                                'High Score: $highScore',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  : buildGameOver(),
        ),
        // Mic Test page
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  mic.getLatestReading() != null
                      ? mic
                          .getLatestReading()!
                          .meanDecibel
                          .toString()
                          .substring(0, 2)
                      : '0',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 30),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 75,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 75,
                        height: mic.getLatestReading() != null
                            ? mic.getLatestReading()!.meanDecibel * 3
                            : 20,
                        color: mic.getLatestReading() != null
                            ? (mic.getLatestReading()!.meanDecibel >= 60
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey,
                      ),
                    ),
                    Positioned(
                      bottom: 60 * 3,
                      left: -70,
                      right: -70,
                      child: Row(
                        children: [
                          const Text('60 dB  ', style: TextStyle(fontSize: 15)),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.black,
                            ),
                          ),
                          const Text('  Min. ', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
