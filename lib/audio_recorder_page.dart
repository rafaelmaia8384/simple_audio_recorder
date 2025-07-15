import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as recorder;
import 'package:sound_waveform/sound_waveform.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'timer_widget.dart';

class AudioRecorderPage extends StatefulWidget {
  const AudioRecorderPage({
    super.key,
    this.recordConfig,
    this.startRecordingWidget,
    this.stopRecordingWidget,
    this.readingTextWidget,
  });
  final recorder.RecordConfig? recordConfig;
  final Widget? startRecordingWidget;
  final Widget? stopRecordingWidget;
  final Widget? readingTextWidget;

  @override
  AudioRecorderPageState createState() => AudioRecorderPageState();
}

class AudioRecorderPageState extends State<AudioRecorderPage> {
  final recorder.AudioRecorder _audioRecorder = recorder.AudioRecorder();
  Stream<Amplitude>? _waveformAmplitudeStream;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    WakelockPlus.enable();
  }

  Future<String> _getFilePath(recorder.RecordConfig config) async {
    final directory = await getTemporaryDirectory();
    String getFileExtension(recorder.AudioEncoder encoder) {
      switch (encoder) {
        case recorder.AudioEncoder.aacLc:
        case recorder.AudioEncoder.aacEld:
        case recorder.AudioEncoder.aacHe:
          return 'm4a';
        case recorder.AudioEncoder.amrNb:
        case recorder.AudioEncoder.amrWb:
          return '3gp';
        case recorder.AudioEncoder.opus:
          return 'ogg';
        case recorder.AudioEncoder.flac:
          return 'flac';
        case recorder.AudioEncoder.wav:
          return 'wav';
        case recorder.AudioEncoder.pcm16bits:
          return 'pcm';
      }
    }

    final uuid = const Uuid().v4();
    return '${directory.path}/$uuid.${getFileExtension(config.encoder)}';
  }

  Future<void> _checkPermissions() async {
    if (!await _audioRecorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission to record audio denied.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final config = widget.recordConfig ?? const recorder.RecordConfig();
        final audioPath = await _getFilePath(config);
        await _audioRecorder.start(
          config,
          path: audioPath,
        );
        _waveformAmplitudeStream = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 100))
            .map((recorder.Amplitude amplitude) => Amplitude(
                  current: amplitude.current / 2,
                  max: amplitude.max / 2,
                ));
        setState(() {
          _isRecording = true;
          _filePath = audioPath;
        });
      }
    } catch (error) {
      log("SimpleAudioRecorder: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error while recording audio.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });
      await _audioRecorder.stop();
      if (mounted) {
        Navigator.pop(context, _filePath);
      }
    } catch (error) {
      log("SimpleAudioRecorder: $error");
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: widget.readingTextWidget ?? Container(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _isRecording
                      ? GestureDetector(
                          onTap: () {
                            _stopRecording();
                          },
                          child: widget.stopRecordingWidget ??
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.stop,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _startRecording();
                          },
                          child: widget.startRecordingWidget ??
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mic,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: _isRecording && _waveformAmplitudeStream != null
                      ? Center(
                          child: SizedBox(
                            width: double.maxFinite,
                            height: 100,
                            child: AnimatedWaveList(
                              stream: _waveformAmplitudeStream!,
                              barColor: Colors.red,
                              maxHeight: 4,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Center(
                      child: TimerWidget(
                        key: UniqueKey(),
                        started: _isRecording,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.close,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
