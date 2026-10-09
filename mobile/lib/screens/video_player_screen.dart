import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_client.dart';
import '../theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const VideoPlayerScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final _api = ApiClient();
  VideoPlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Fetched fresh on every open — the URL expires in ~1 hour and is scoped
      // to this lesson, so there is nothing long-lived worth caching here.
      final url = await _api.fetchVideoUrl(widget.lessonId);
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
      controller.play();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.lessonTitle),
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, style: const TextStyle(color: Colors.white)),
              )
            : _controller == null
                ? const CircularProgressIndicator(color: AppColors.primary)
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller!),
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppColors.primary,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white10,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
    );
  }
}
