import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'audio_recorder_page.dart';

export 'audio_player_widget.dart';
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
    Widget? readingTextWidget,
  }) async {
    return await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AudioRecorderPage(
          recordConfig: recordConfig,
          startRecordingWidget: startRecordingWidget,
          stopRecordingWidget: stopRecordingWidget,
          readingTextWidget: readingTextWidget,
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
