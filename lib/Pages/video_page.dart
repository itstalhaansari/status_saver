import 'dart:io';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:status_saver/Pages/video_player_screen.dart';
import 'package:status_saver/Utils/functions.dart';
import 'package:status_saver/Utils/hivedb.dart';

class VideoPage extends StatelessWidget {
  final List<FileSystemEntity> statusFiles;

  VideoPage({super.key, required this.statusFiles});

  final UserDataDb db = UserDataDb();

  void _showPopover(BuildContext context, String videoPath) {
    showPopover(
      backgroundColor: Colors.grey.shade400,
      context: context,
      bodyBuilder: (context) => _buildPopoverMenu(context, videoPath),
      // direction: PopoverDirection.bottom,
      // placement: PopoverPlacement.bottom,
      width: 150,
    );
  }

  Future<String?> _getCachedThumbnail(String videoPath) async {
    return await generateThumbnail(
        videoPath); // Call generateThumbnail directly
  }

//Function of popover items for popoverwidget
  Widget _buildPopoverMenu(BuildContext context, String videoPath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          tileColor: Colors.grey.shade400,
          title: const Text('Save Video'),
          onTap: () {
            saveFile(
              videoPath,
              context,
            );
            Navigator.of(context).pop(); // Close popover
          },
        ),
        ListTile(
          tileColor: Colors.grey.shade400,
          title: const Text('Share Video'),
          onTap: () {
            Sharefile(videoPath, context);
            Navigator.of(context).pop(); // Close popover
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth / 2 - 15; // 2 items per row with spacing
        final double itemHeight =
            itemWidth * 1.5; // Adjust this ratio for desired height
        return statusFiles.isEmpty
            ? Center(
                child: Text(
                  "No Video Status Found!!\n Please open WhatsApp and see some status first",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //this widget is used to fix silver delegate error
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
                      //gesture dectector ko builder se wrap kiya ha taka silver deligate wala error fix ho
                      onTap: () {
                        if (file.path.endsWith('.mp4')) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(videoPath: file.path)),
                          );
                        }
                      },
                      onLongPress: () {
                        db.loaddata();
                        _showPopover(context, file.path); // Show popover menu
                      },
                      child: FutureBuilder<String?>(
                        future: _getCachedThumbnail(file.path),
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
                                    offset:
                                        Offset(0, 4), // Shadow positioned below
                                  ),
                                ],
                                color: Colors.transparent,
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
                            return const Icon(Icons.videocam, size: 50);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
