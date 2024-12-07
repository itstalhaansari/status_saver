import 'package:flutter/material.dart';
import './MButton.dart';

class MAlert extends StatelessWidget {
  final TextEditingController con; // Specify type for 'con'
  final String tittletext;
  final VoidCallback onsave;
  final VoidCallback oncancel;

  const MAlert({
    super.key,
    required this.con,
    required this.onsave,
    required this.tittletext,
    required this.oncancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade400,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(
        child: Text(
          tittletext,
          style: TextStyle(
            color: Colors.black,
            shadows: List.filled(
              0,
              const Shadow(blurRadius: 2),
            ),
          ),
        ),
      ),
      content: Container(
        height: 120,
        color: Colors.grey.shade400,
        child: Column(
          children: [
            TextFormField(
              controller: con,
              decoration: InputDecoration(
                hintText: "Type here",
                hintStyle: TextStyle(
                  color: Colors.black,
                  shadows: List.filled(
                    0,
                    const Shadow(blurRadius: 2, color: Colors.black),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: Colors.teal,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(
                  color: Colors.black), // Added missing closing bracket
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Mybutton(
                  onPressed: oncancel,
                  text: "Cancel",
                  color: const Color.fromARGB(255, 238, 91, 80),
                ),
                const SizedBox(width: 10),
                Mybutton(
                  onPressed: onsave,
                  text: "Save",
                  color: Colors.green,
                ),
              ],
            )
          ], // Closing bracket for Column
        ),
      ),
    );
  }
}

//MAlert 2
class MAlert2 extends StatelessWidget {
  final TextEditingController con;
  final TextEditingController conmessage; // Specify type for 'con'
  final String tittletext;
  final VoidCallback onsave;
  final VoidCallback oncancel;

  const MAlert2({
    super.key,
    required this.con,
    required this.conmessage,
    required this.onsave,
    required this.tittletext,
    required this.oncancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade400,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(
        child: Text(
          tittletext,
          style: TextStyle(
            color: Colors.black,
            shadows: List.filled(
              0,
              const Shadow(blurRadius: 2),
            ),
          ),
        ),
      ),
      content: Container(
        height: 200,
        color: Colors.grey.shade400,
        child: Column(
          children: [
            TextFormField(
              controller: con,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.phone,
                  color: Colors.teal,
                ),
                hintText: "313.......",
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.3),
                  shadows: List.filled(
                    0,
                    const Shadow(blurRadius: 2, color: Colors.black),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: Colors.teal,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(
                  color: Colors.black), // Added missing closing bracket
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: conmessage,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.textsms_outlined,
                  color: Colors.teal,
                ),
                hintText: "Type Message here",
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.3),
                  shadows: List.filled(
                    0,
                    const Shadow(blurRadius: 2, color: Colors.black),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: Colors.teal,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(
                  color: Colors.black), // Added missing closing bracket
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Mybutton(
                  onPressed: oncancel,
                  text: "Cancel",
                  color: const Color.fromARGB(255, 238, 91, 80),
                ),
                const SizedBox(width: 10),
                Mybutton(
                  onPressed: onsave,
                  text: "Send",
                  color: Colors.green,
                ),
              ],
            )
          ], // Closing bracket for Column
        ),
      ),
    );
  }
}
