import 'dart:io';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:status_saver/Pages/fullscreen_imagesaved.dart';
import 'package:status_saver/Pages/video_player_screensaved.dart';
import '../Utils/functions.dart';
import '../Utils/hivedb.dart';

class SavedStatusPage extends StatelessWidget {
  final List<FileSystemEntity> statusFiles;
  SavedStatusPage({super.key, required this.statusFiles});
  final UserDataDb db = UserDataDb();

  void _showPopover(BuildContext context, String imagePath) {
    showPopover(
      backgroundColor: Colors.grey.shade400,
      context: context,
      bodyBuilder: (context) => _buildPopoverMenu(context, imagePath),
      // direction: PopoverDirection.bottom,
      width: 150,
    );
  }

  Widget _buildPopoverMenu(BuildContext context, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          tileColor: Colors.grey.shade400,
          title: const Text('Share Image'),
          onTap: () {
            Sharefile(imagePath, context);
            Navigator.of(context).pop(); // Close popover
          },
        ),
      ],
    );
  }

  Future<String?> _getCachedImage(String imagePath) async {
    // You can implement your image caching logic here if needed
    return imagePath; // For now, return the original path
  }

  Future<String?> _getCachedThumbnail(String videoPath) async {
    return await generateThumbnail(
        videoPath); // Call generateThumbnail directly
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth / 2 - 15; // 2 items per row with spacing
        final double itemHeight =
            itemWidth * 1.5; // Adjust this ratio for desired height
        return GestureDetector(
          child: statusFiles.isEmpty
              ? Center(
                  child: Text(
                  "No files in Saved yet",
                  style: TextStyle(fontSize: 18),
                ))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: itemWidth / itemHeight,
                  ),
                  itemCount: statusFiles.length,
                  itemBuilder: (context, index) {
                    final file = statusFiles[index];
                    return Builder(
                      // Wrap with Builder
                      builder: (context) => GestureDetector(
                        onTap: () {
                          if (file.path.endsWith('.jpg') ||
                              file.path.endsWith('.png')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenImagesaved(
                                      imagePath: file.path)),
                            );
                          } else if (file.path.endsWith('.mp4')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreensaved(
                                      videoPath: file.path)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Something went wrong")));
                          }
                        },
                        onLongPress: () {
                          db.loaddata();
                          _showPopover(context, file.path); // Show popover menu
                        },
                        child: file.path.endsWith('.jpg') ||
                                file.path.endsWith('.png')
                            ? FutureBuilder<String?>(
                                future: _getCachedImage(
                                    file.path), // Call the caching function
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.35), // Shadow color with opacity
                                            spreadRadius: 0, // No spread
                                            blurRadius: 10, // Blur radius
                                            offset: Offset(0,
                                                4), // Shadow positioned below
                                          ),
                                        ],
                                        // color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.file(
                                        File(snapshot.data!),
                                        fit: BoxFit.cover,
                                        height: itemHeight,
                                        width: itemWidth,
                                      ),
                                    );
                                  } else {
                                    return const Icon(Icons.image,
                                        size:
                                            50); // Placeholder icon for images
                                  }
                                },
                              )
                            : FutureBuilder<String?>(
                                future: _getCachedThumbnail(file.path),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.35), // Shadow color with opacity
                                                spreadRadius: 0, // No spread
                                                blurRadius: 10, // Blur radius
                                                offset: Offset(0,
                                                    4), // Shadow positioned below
                                              ),
                                            ],
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.file(
                                            File(snapshot.data!),
                                            fit: BoxFit.cover,
                                            height: itemHeight,
                                            width: itemWidth,
                                          ),
                                        ),
                                        Center(
                                          child: Icon(
                                            Icons.play_circle_outline,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    );
                                  } else {
                                    return const Icon(Icons.videocam, size: 50);
                                  }
                                },
                              ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
