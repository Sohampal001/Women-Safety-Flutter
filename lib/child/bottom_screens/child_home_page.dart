import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluttertoast/fluttertoast.dart';
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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _hasStarted = false; // Track if recognition has started once
  String _voiceStatus = "Not Listening";
  String _recognizedWords = "";

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  @override
  void initState() {
    getRandomQuote();
    _speech = stt.SpeechToText();
    super.initState();
    _initializeSpeechRecognition();
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          setState(() {
            _voiceStatus = "Start recognising";
          });

          // Show the toast only the first time recognition starts
          if (!_hasStarted) {
            _showToast("Start recognising");
            _hasStarted = true; // Mark that it has started
          }
        } else if (status == 'done') {
          setState(() {
            _voiceStatus = "Not Listening";
          });
          // Automatically continue listening
          _startListening();
        }
      },
      onError: (error) {
        setState(() {
          _voiceStatus = "Error: $error";
        });
      },
    );

    if (available) {
      _startListening();
    } else {
      setState(() {
        _voiceStatus = "Speech recognition unavailable";
      });
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (val) {
        setState(() {
          _recognizedWords = val.recognizedWords;

          if (_recognizedWords.toLowerCase().contains('hello')) {
            _showToast("Hello Soham");
          }
        });
      },
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
              Color.fromARGB(255, 98, 180, 243),
              Color.fromARGB(255, 194, 225, 231),
              Color.fromARGB(255, 98, 180, 243),
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
                // Voice recognition section
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _voiceStatus,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Recognized words: $_recognizedWords',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
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
