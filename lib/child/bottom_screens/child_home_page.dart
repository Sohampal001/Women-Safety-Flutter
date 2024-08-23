import 'dart:math';
import 'package:flutter/material.dart';
import 'package:women_safety/widgets/home_widgets/CustomCarouel.dart';
import 'package:women_safety/widgets/home_widgets/custom_appBar.dart';
import 'package:women_safety/widgets/home_widgets/emergency.dart';
import 'package:women_safety/widgets/live_safe.dart';
import 'package:women_safety/widgets/safeHome/safe_home.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 2;

  getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(6);
      print("Quote index updated: $qIndex"); // Debug print
    });
  }

  @override
  void initState() {
    getRandomQuote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Color.fromARGB(255, 244, 243, 244), // Light Mint Green
 
              Color.fromARGB(255, 98, 180, 243), // Light Lavender
              Color.fromARGB(255, 194, 225, 231), // Light Mint Green
              Color.fromARGB(255, 98, 180, 243), // Light Lemon Yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CustomAppbar(
                  quoteIndex: qIndex,
                  oneTap: getRandomQuote,
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      CustomCarouel(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Emergency",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Emergency(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Explore LiveSafe",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      LiveSafe(),
                      Safehome(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
