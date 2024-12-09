import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
    _startUpdatingPosition();

    // Listener para detectar quando o áudio termina.
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _resetAudioPlayer();
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      // Carregar o arquivo local.
      await _audioPlayer.setFilePath(widget.audioPath);

      // Garantir que o áudio não toque em loop.
      _audioPlayer.setLoopMode(LoopMode.off);

      // Obter a duração total do áudio.
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _audioDuration = duration ?? Duration.zero;
        });
      });
    } catch (e) {
      debugPrint("Erro ao carregar o áudio: $e");
    }
  }

  void _startUpdatingPosition() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_audioPlayer.playing) {
        setState(() {
          _currentPosition = _audioPlayer.position;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seekAudio(double value) {
    final position = Duration(milliseconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void _resetAudioPlayer() {
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
    _audioPlayer.stop(); // Parar completamente o player.
    _audioPlayer.seek(Duration.zero); // Resetar a posição do áudio.
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: _audioDuration.inMilliseconds.toDouble(),
            value: _currentPosition.inMilliseconds
                .toDouble()
                .clamp(0, _audioDuration.inMilliseconds.toDouble()),
            onChanged: _isPlaying
                ? (value) {
                    _seekAudio(value);
                  }
                : null, // Desativa o seek quando o áudio está pausado.
          ),
        ),
        Text(
          "${_formatDuration(_currentPosition)} / ${_formatDuration(_audioDuration)}",
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          width: 12,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
