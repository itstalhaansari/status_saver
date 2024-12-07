import 'dart:io';
import 'package:flutter/material.dart';
import 'package:status_saver/Utils/hivedb.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../Utils/functions.dart';

class VideoPlayerScreensaved extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreensaved({super.key, required this.videoPath});

  @override
  VideoPlayerScreensavedState createState() => VideoPlayerScreensavedState();
}

class VideoPlayerScreensavedState extends State<VideoPlayerScreensaved> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late UserDataDb db; // Declare UserDataDb instance
  String targetDirectory = '';

  @override
  void initState() {
    super.initState();
    db = UserDataDb(); // Initialize the database instance
    db.loaddata(); // Load data from Hive
    // targetDirectory = db.getTargetDirectory(); // Get target directory after loading
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.teal,
        handleColor: Colors.white,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black)),
                    onPressed: () => Sharefile(widget.videoPath, context),
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
