import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'audio_recorder_page.dart';

export 'package:record/record.dart'
    show
        RecordConfig,
        AudioEncoder,
        InputDevice,
        AndroidRecordConfig,
        IosRecordConfig;

class SimpleAudioRecorder {
  static Future<String?> open(
    BuildContext context, {
    RecordConfig? recordConfig,
    Widget? startRecordingWidget,
    Widget? stopRecordingWidget,
    Widget? labelStartWidget,
    Widget? labelStopWidget,
  }) async {
    return await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AudioRecorderPage(
          recordConfig: recordConfig,
          startRecordingWidget: startRecordingWidget,
          stopRecordingWidget: stopRecordingWidget,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
