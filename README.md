## Simple Audio Recorder

Simple Audio Recorder is a lightweight and user-friendly package that provides a screen for recording audio and returns the file path of the recorded audio. It leverages the power of record, sound_waveform, and wakelock_plus libraries under the hood to ensure a seamless and efficient recording experience.

<img src = "https://raw.githubusercontent.com/rafaelmaia8384/simple_audio_recorder/main/assets/simple_audio_recorder.png" >

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  simple_audio_recorder: latest_version
```

## Usage

# Basic Example

Below is an example of how to use SimpleAudioRecorder:

```dart
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
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

Simple Audio Recorder is licensed under the MIT License. See the LICENSE file for more details.

## Credits

Simple Audio Recorder is inspired by sound_waveform.