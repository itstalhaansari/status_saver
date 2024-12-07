import 'dart:io';
import 'package:flutter/material.dart';
import 'package:status_saver/Utils/hivedb.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../Utils/functions.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
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
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black)),
                  onPressed: () => saveFile(
                    widget.videoPath,
                    context,
                  ),
                  child: const Icon(Icons.save, color: Colors.white),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black)),
                  onPressed: () => Sharefile(widget.videoPath, context),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
