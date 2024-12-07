import 'package:flutter/material.dart';
import 'package:simple_audio_recorder/simple_audio_recorder.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _audioPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Audio Recorder')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final audioPath = await SimpleAudioRecorder.open(
                  context,
                  recordConfig: const RecordConfig(
                    encoder: AudioEncoder.opus,
                  ),
                );
                if (audioPath != null) {
                  setState(() {
                    _audioPath = audioPath;
                  });
                }
              },
              child: const Text('Open Audio Recorder'),
            ),
            if (_audioPath != null) ...[
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Result: $_audioPath'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
