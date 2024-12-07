import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import './Pages/home_page.dart';

void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: unused_local_variable
  var box = await Hive.openBox('mybox');
  await FilePicker.platform.clearTemporaryFiles();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: HomePage(), debugShowCheckedModeBanner: false);
  }
}
