import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:media_store_plus/media_store_platform_interface.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/Utils/MButton.dart';
import 'package:url_launcher/url_launcher.dart';

Future<int> getAndroidSdkVersion() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo
        .version.sdkInt; // This will give you the correct SDK version
  }

  return 0; // Return 0 if not on Android
}

//Request Permission of App
Future<bool> requestPermission() async {
  // Check for Android platform
  if (Platform.isAndroid) {
    // Get the current Android SDK version
    int sdkVersion = await getAndroidSdkVersion();

    if (sdkVersion >= 30) {
      // For Android 11 (API 30) and above, request manage external storage permission if necessary
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "MANAGE_EXTERNAL_STORAGE permission denied",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    } else {
      // For Android 10 (API 29) and below, request read and write permissions
      var status = await [Permission.storage].request();

      return status[Permission.storage]!.isGranted;
    }
  }

  return false; // Return false if not on Android
}

// Function to get the WhatsApp Status directory

Future<Directory?> getWhatsAppStatusDirectory() async {
  try {
    if (Platform.isAndroid) {
      // Check the Android SDK version
      int sdkVersion = await getAndroidSdkVersion();

      String whatsappPath;
      if (sdkVersion >= 30) {
        // Scoped storage path for Android 11 (API 30) and above
        whatsappPath =
            '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
      } else {
        // Legacy path for Android 10 (API 29) and below
        whatsappPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';
      }

      Directory statusDir = Directory(whatsappPath);

      if (await statusDir.exists()) {
        return statusDir;
      } else {
        Fluttertoast.showToast(
          msg: "WhatsApp status directory not found",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error getting WhatsApp status directory: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  return null;
}

// Function to generate a thumbnail from a video file
Future<String?> generateThumbnail(String videoPath) async {
  final plugin = FcNativeVideoThumbnail();

  try {
    // Get the app's temporary directory to save the thumbnail
    final tempDir = await getTemporaryDirectory();
    final thumbnailName = '${videoPath.split('/').last}.jpeg';
    String thumbnailPath = '${tempDir.path}/$thumbnailName';

    // Check if thumbnail already exists
    File thumbnailFile = File(thumbnailPath);
    if (await thumbnailFile.exists()) {
      // Check if the thumbnail is older than 24 hours
      DateTime lastModified = await thumbnailFile.lastModified();
      if (isExpired(lastModified)) {
        // Thumbnail is older than 24 hours, delete it
        await thumbnailFile.delete();
      } else {
        // Thumbnail is still valid, return it
        return thumbnailPath;
      }
    }

    // Generate a new thumbnail if it doesn't exist or was deleted
    final thumbnailGenerated = await plugin.getVideoThumbnail(
      srcFile: videoPath,
      destFile: thumbnailPath,
      width: 1024, // Increase width for better quality
      height: 1024, // Increase height for better quality
      format: 'jpeg',
      quality: 100, // Set quality to maximum
    );

    return thumbnailGenerated ? thumbnailPath : null;
  } catch (err) {
    // Handle error and log if necessary
    return null;
  }
}

// Helper function to check if the file is older than 24 hours
bool isExpired(DateTime lastModified) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(lastModified);
  return difference.inHours >= 24;
}

//Share functionality
Future<void> Sharefile(String sharepath, BuildContext context) async {
  try {
    await Share.shareXFiles(
      [XFile(sharepath)],
    );
  } catch (e) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Error sharing File: $e")),
    // );
    Fluttertoast.showToast(
      msg: "Error sharing File: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

// Function to select a target directory

//Function to save file
// Add this package
Future<void> saveFile(
  String sourcePath,
  BuildContext context,
) async {
  try {
    final File originalFile = File(sourcePath);

    if (!await originalFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The specified file does not exist.")),
      );
      return;
    }

    String fileName = basename(sourcePath);
    String mimeType;
    DirType dirType;

    // Determine MIME type and directory type based on file extension
    if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      mimeType = 'image/jpeg';
      dirType = DirType.photo;
    } else if (fileName.endsWith('.mp4') || fileName.endsWith('.mov')) {
      mimeType = 'video/mp4';
      dirType = DirType.video;
    } else {
      throw Exception("Unsupported file type");
    }

    // Create a temporary path for the copied file
    String tempDir =
        '/storage/emulated/0/Download/'; // Change this to your desired temporary directory
    String tempFilePath = '$tempDir$fileName';

    // Copy the original file to a new location
    await originalFile.copy(tempFilePath);

    // Save the copied file to MediaStore
    final SaveInfo? saveInfo = await MediaStorePlatform.instance.saveFile(
      tempFilePath: tempFilePath,
      fileName: fileName,
      dirType: dirType,
      dirName: dirType == DirType.photo ? DirName.download : DirName.download,
      relativePath: 'Status Saver',
    );

    if (saveInfo == null) {
      throw Exception("Failed to save the file.");
    }

    // Notify user of success
    Fluttertoast.showToast(
      msg: "File saved Successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    // Handle any errors that occur during file saving
    // Fluttertoast.showToast(
    //   msg: "Error saving File: $e",
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.BOTTOM,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.red,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
  }
}

//my list tile
Widget MLIsttile(
    void Function()? onTap, Widget? Icon, String text, double? fontSize) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
    child: ListTile(
      title: Text(
        text,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
      leading: Icon,
      onTap: onTap,
    ),
  );
}

void SendonWhatsApp(String Phonenum, String usermessage) async {
  // Replace with your phone number in international format

  String phoneNumber = "92" + Phonenum; // Example format
  var message = usermessage;
  print(phoneNumber);

  final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

void popup(BuildContext context) async {
  if (Platform.isAndroid) {
    // Get the current Android SDK version
    int sdkVersion = await getAndroidSdkVersion();

    if (sdkVersion >= 30) {
      // For Android 11 (API 30) and above, request manage external storage permission if necessary
      if (await Permission.manageExternalStorage.isGranted) {
      } else if (await Permission.manageExternalStorage.isDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
                "To make the app run properly it is necessary to give permissions"),
            actions: [
              Mybutton(
                onPressed: () => requestPermission,
                text: "GivePermission",
                color: Colors.grey,
              ),
              Mybutton(
                onPressed: () => SystemNavigator.pop(),
                text: "Close App",
                color: Colors.grey,
              )
            ],
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        );
      }
    }
  }
}

//Saved Directory Path fetch
Future<Directory?> getSavedStatusDirectory() async {
  try {
    String Savedstatuspath;
    Savedstatuspath = '/storage/emulated/0/Download/Status Saver';
    Directory statusDir = Directory(Savedstatuspath);
    if (await statusDir.exists()) {
      return statusDir;
    } else {
      return null;
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error getting WhatsApp status directory: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  return null;
}
