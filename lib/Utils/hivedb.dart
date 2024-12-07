import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

class UserDataDb {
  final _mybox = Hive.box('mybox');
  String username = '';
  String profilePhotoPath = '';
  // String targetDirectory = ''; // New variable for target directory

  // Create initial database with an empty list
  void createdb() {
    username = 'Long press';
    profilePhotoPath = '';
    // targetDirectory = ''; // Initialize target directory
    _mybox.put('Username', username); // Ensure key is consistent
    _mybox.put('ProfilePhotoPath', profilePhotoPath);
    // _mybox.put('TargetDirectory', targetDirectory); // Store initial value
  }

  // Load data from the Hive box
  void loaddata() {
    username = _mybox.get('Username', defaultValue: 'Long Press');
    profilePhotoPath = _mybox.get('ProfilePhotoPath', defaultValue: '');
    // targetDirectory = _mybox.get('TargetDirectory', defaultValue: ''); // Load target directory
  }

  void update() {
    _mybox.put('Username', username);
    _mybox.put('ProfilePhotoPath', profilePhotoPath);
    // _mybox.put('TargetDirectory', targetDirectory); // Update target directory
  }

  // Function to update the username
  void updateUsername(String newUsername) {
    username = newUsername;
    update(); // Save changes to Hive box
  }

  // New method to set the target directory
  // void setTargetDirectory(String path) {
  //   targetDirectory = path;
  //   update(); // Save updated path to Hive box
  // }

  // New method to get the target directory
  // String getTargetDirectory() {
  //   return targetDirectory;
  // }

  Future<String> pickProfilePhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select your profile photo',
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_photo${path.extension(pickedFile.name)}';
        final savedFilePath = path.join(appDir.path, fileName);

        // Copy the file to the app's documents directory
        final bytes = await File(pickedFile.path!).readAsBytes();
        await File(savedFilePath).writeAsBytes(bytes);

        profilePhotoPath = fileName; // Store only the file name
        update(); // Save updated path to Hive box
        return 'Profile photo updated successfully.';
      } else {
        return 'No file selected.';
      }
    } catch (e) {
      return 'Error picking profile photo: $e';
    }
  }

  // New method to get the full path of the profile photo
  Future<String?> getProfilePhotoPath() async {
    if (profilePhotoPath.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      return path.join(appDir.path, profilePhotoPath);
    }
    return null;
  }
}
