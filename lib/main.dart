import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/db/shared_pref.dart';
import 'package:women_safety/parent/parent_home_screen.dart';
// import 'package:women_safety/utils/constants.dart';
// import 'package:women_safety/child/bottom_screens/child_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MySharedPrefference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.balooTamma2TextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 58, 160, 183)),
        useMaterial3: true,
      ),
      home: 
      const AuthChecker(), // Updated to use a dedicated widget
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: MySharedPrefference.getUserType(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show progress indicator while loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
        } else {
          final userType = snapshot.data ?? ""; // Default to empty string if null

          if (userType.isEmpty) {
            return LoginScreen(); // Show login screen if user is not logged in
          } else if (userType == "child") {
            return BottomPage(); // Navigate to child home screen
          } else if (userType == "parent") {
            return ParentHomeScreen(); // Navigate to parent home screen
          } else {
            return LoginScreen(); // Default to login screen if data is unexpected
          }
        }
      },
    );
  }
}
