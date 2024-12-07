import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:status_saver/Pages/saved_satuspage.dart';
import 'package:status_saver/Utils/hivedb.dart';
import '../Utils/MAlert.dart';
import '../Utils/functions.dart';
import 'image_page.dart'; // Imported the new image page
import 'video_page.dart'; // Imported the new video page
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<FileSystemEntity> imageFiles = [];
  List<FileSystemEntity> videoFiles = [];
  List<FileSystemEntity> savedstatusfiles = [];
  UserDataDb db = UserDataDb();
  final mcontroller = TextEditingController();
  final messagecontroller = TextEditingController();
  String? _profilePhotoPath;
  int _selectedIndex = 0;

  // this is a build in widget to control scrolling between different pages
  late PageController
      _pageController; // Track the selected index for navigation

  ImagePage? imgPage;
  VideoPage? vidpage;
  SavedStatusPage? savedStatusPage;

  @override
  void initState() {
    super.initState();
    db.loaddata();
    _loadProfilePhoto();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this); // Add observer
    requestPermissionsAndLoadStatuses();
    if (db.username.isEmpty && _profilePhotoPath == '') {
      db.createdb();
    }
  }

  //function to load profile photo
  Future<void> _loadProfilePhoto() async {
    final photoPath = await db.getProfilePhotoPath();
    if (photoPath != null) {
      setState(() {
        _profilePhotoPath = photoPath; // Update the state with the new path
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await loadStatuses(); // Reload statuses when app resumes
      imgPage = ImagePage(statusFiles: imageFiles);
      vidpage = VideoPage(statusFiles: videoFiles);
    }
  }

// Permission + loaddatabase function
  Future<void> requestPermissionsAndLoadStatuses() async {
    if (await requestPermission()) {
      await loadStatuses();
      imgPage = ImagePage(statusFiles: imageFiles);
      vidpage = VideoPage(statusFiles: videoFiles);
      savedStatusPage = SavedStatusPage(statusFiles: savedstatusfiles);
    } else {
      popup(context);
      Fluttertoast.showToast(
        msg: "Perissions not given",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Handle permission denied case
    }
  }

  Future<void> loadStatuses() async {
    final statusDir = await getWhatsAppStatusDirectory();
    final savedstatusdir = await getSavedStatusDirectory();

    if (savedstatusdir != null) {
      var savedallFiles = savedstatusdir.listSync(followLinks: false);
      setState(() {
        savedstatusfiles = savedallFiles.where((file) {
          return file.path.endsWith('.jpg') || file.path.endsWith('.mp4');
        }).toList();
        savedstatusfiles.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      });
    } else {}

    if (statusDir != null) {
      var allFiles = statusDir.listSync(followLinks: false);
      setState(() {
        imageFiles =
            allFiles.where((file) => file.path.endsWith('.jpg')).toList();
        videoFiles =
            allFiles.where((file) => file.path.endsWith('.mp4')).toList();

        // Sort files by modification time (newest first)
        imageFiles.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        videoFiles.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      }); //setstate ends here
    } else {}
  }

  // Future<void> _launchWhatsApp(BuildContext context) async {
  //   try {
  //     final Uri whatsappUri = Uri.parse('android-app://com.whatsapp');
  //
  //     if (await canLaunchUrl(whatsappUri)) {
  //       await launchUrl(whatsappUri);
  //     } else {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('WhatsApp is not installed on this device'),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error launching WhatsApp: $e'),
  //         ),
  //       );
  //     }
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey.shade400,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                // Background color of the header
                border: Border(
                  bottom: BorderSide(
                      color: Colors.black, width: 2.0), // Custom divider color
                ),
              ),
              child: Column(children: [
                GestureDetector(
                  onTap: () async {
                    // Pick a new profile photo
                    String message = await db.pickProfilePhoto();

                    // Reload the profile photo
                    db.loaddata(); // Ensure this is awaited
                    await _loadProfilePhoto();
                    setState(() {}); // Call setState to trigger a rebuild

                    // Show a Snackbar with the result message
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  },
                  child: CircleAvatar(
                    backgroundImage: _profilePhotoPath != null &&
                            File(_profilePhotoPath!).existsSync()
                        ? FileImage(File(_profilePhotoPath!))
                        : null,
                    backgroundColor: Colors.grey,
                    radius: 42,
                    child: _profilePhotoPath == null
                        ? const Icon(Icons.supervised_user_circle_outlined,
                            color: Colors.black)
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => MAlert(
                      con: mcontroller,
                      onsave: () {
                        setState(() {
                          String name = mcontroller.text;
                          db.updateUsername(name);
                          mcontroller.clear();
                          Navigator.pop(context);
                        });
                      },
                      tittletext: "Change User Name",
                      oncancel: () => Navigator.pop(context),
                    ),
                  ),
                  child: Text(
                    db.username,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]),
            ),
            MLIsttile(() {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => MAlert2(
                  con: mcontroller,
                  conmessage: messagecontroller,
                  onsave: () {
                    String phonenum = mcontroller.text;
                    String message = messagecontroller.text;
                    SendonWhatsApp(phonenum, message);
                    mcontroller.clear();
                    messagecontroller.clear();
                  },
                  tittletext: "Direct Chat",
                  oncancel: () {
                    Navigator.pop(context);
                    mcontroller.clear();
                    messagecontroller.clear();
                  },
                ),
              );
            },
                const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.teal,
                  size: 26,
                ),
                "Direct Message",
                18),
            // MLIsttile(() {
            //   _launchWhatsApp(context);
            //   print("helllo");
            // }, Icon(Icons.send), 'OP', 26),
            const Spacer(),
            MLIsttile(
                () => SystemNavigator.pop(),
                const Icon(
                  Icons.exit_to_app,
                  size: 26,
                  color: Colors.teal,
                ),
                "Close App",
                18),
            const Text(
              "Developed by Talha Ansari",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.teal,
              size: 27,
            ),
            SizedBox(
              width: 8,
            ),
            Text('Status Saver', style: TextStyle(color: Colors.black))
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => MAlert2(
                  con: mcontroller,
                  conmessage: messagecontroller,
                  onsave: () {
                    String phonenum = mcontroller.text;
                    String message = messagecontroller.text;
                    SendonWhatsApp(phonenum, message);
                    mcontroller.clear();
                    messagecontroller.clear();
                  },
                  tittletext: "Direct Chat",
                  oncancel: () {
                    Navigator.pop(context);
                    mcontroller.clear();
                    messagecontroller.clear();
                  },
                ),
              ),
              child: Icon(
                Icons.send,
                color: Colors.teal,
              ),
            ),
          )
        ],
        backgroundColor: Colors.grey.shade400,
      ),

      //Body of the HomePage starts here
      body: imgPage == null && vidpage == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView(
              controller: _pageController,
              onPageChanged: (pageindex) {
                setState(() {
                  _selectedIndex = pageindex;
                });
              },
              children: [
                ///ImagePage(statusFiles: imageFiles),
                imgPage!,
                vidpage!,
                savedStatusPage!
              ],
            ),
      // Display selected page

      bottomNavigationBar: Container(
        color: Colors.grey.shade400,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
          child: GNav(
            gap: 8,
            activeColor: Colors.teal,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey.shade100,
            color: Colors.black54,
            tabs: const [
              GButton(
                icon: Icons.image,
                text: "Images",
              ),
              GButton(
                icon: Icons.video_collection,
                text: "Videos",
              ),
              GButton(
                icon: Icons.save_sharp,
                text: "Saved",
              )
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) async {
              _selectedIndex = index;
              if (_selectedIndex == 2) {
                await loadStatuses();
                savedStatusPage =
                    SavedStatusPage(statusFiles: savedstatusfiles);
                print("Hello g");
              }
              setState(() {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastEaseInToSlowEaseOut,
                ); // Change page when tab is tapped
              });
            },
          ),
        ),
      ),
    );
  }
}
