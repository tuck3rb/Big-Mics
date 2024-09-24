import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void _testMicrophone() { // Will need to update
    print('Microphone Testing button pressed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        // Play page
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Make noise to jump.',
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 30), // Functions as a spacer
              Container( 
                width: 350,
                height: 350,
                child: Placeholder(), // Future implementation of game
              ),
              const SizedBox(height: 30), // Functions as a spacer
              const Text(
                'Score: ', // Will need to update this to be non const and add in score variable
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 30), // Functions as a spacer
              const Text(
                'High Score: ', // Will need to update this to be non const and add in high_score variable
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
        // Mic Test page
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Test microphone.',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 30), // Functions as a spacer
              Container( 
                width: 75,
                height: 400,
                child: Placeholder(), // Mic test bar
              ),
              const SizedBox(height: 30), // Functions as a spacer
              RawMaterialButton(
                onPressed: _testMicrophone,
                elevation: 2.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.mic,
                  size: 35.0,
                ),
                padding: const EdgeInsets.all(15.0),
                shape: const CircleBorder(),
              ),
            ],
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
