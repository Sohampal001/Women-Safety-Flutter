/*
import 'dart:async';
import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety/db/db_services.dart';
import 'package:women_safety/model/contactsm.dart';
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
  
  Position? _currentPosition;
  String? _currentAddress;
  bool _isFetchingLocation = true;
  int? _selectedSimSlot;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getPermission();
    _startLocationTracking();
    _loadSimSlot();
    _speech = stt.SpeechToText();
    super.initState();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  _getPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await [Permission.sms, Permission.location].request();
    }
  }

  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _loadSimSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSimSlot = prefs.getInt('simSlot');
    });
  }

  _saveSimSlot(int simSlot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('simSlot', simSlot);
    setState(() {
      _selectedSimSlot = simSlot;
    });
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    if (_selectedSimSlot == null) {
      await _selectSimSlot();
    }

    if (_selectedSimSlot != null) {
      var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: _selectedSimSlot!,
      );

      if (result == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent through SIM ${_selectedSimSlot! + 1}");
      } else {
        Fluttertoast.showToast(msg: "Message failed to send");
      }
    }
  }

  Future<void> _selectSimSlot() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select SIM Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("SIM 1"),
                onTap: () {
                  _saveSimSlot(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("SIM 2"),
                onTap: () {
                  _saveSimSlot(1);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startLocationTracking() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
    );

    AndroidSettings androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    );

    AppleSettings appleSettings = AppleSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _fetchAddress();
      });
    });
  }

  Future<void> _fetchAddress() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (!mounted) return;
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.subLocality}";
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Failed to get address: $e");
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _sendLocationToContacts() async {
    if (_isFetchingLocation) {
      Fluttertoast.showToast(msg: "Fetching location, please wait...");
      return;
    }

    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Location is not available.");
      return;
    }

    String messageBody = "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";

    if (await _isPermissionGranted()) {
      List<Tcontact> contactList = await DatabaseHelper().getContactList();
      for (Tcontact contact in contactList) {
        await _sendSms(contact.number, "I am in trouble, please reach me at $messageBody");
      }
    } else {
      Fluttertoast.showToast(msg: "SMS permission not granted.");
    }
  }

  void triggerSOS() async {
    await _sendLocationToContacts();
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

          if (_recognizedWords.toLowerCase().contains('me to')) {
            _sendLocationToContacts();
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

*/




import 'dart:async';
import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety/db/db_services.dart';
import 'package:women_safety/model/contactsm.dart';
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
  bool _isListening = false; // Controls if speech recognition is enabled
  bool _hasStarted = false; // Track if recognition has started once
  String _voiceStatus = "Not Listening";
  String _recognizedWords = "";

  Position? _currentPosition;
  String? _currentAddress;
  bool _isFetchingLocation = true;
  int? _selectedSimSlot;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getPermission();
    _startLocationTracking();
    _loadSimSlot();
    getRandomQuote();
    _speech = stt.SpeechToText();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Permissions
  _getPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await [Permission.sms, Permission.location].request();
    }
  }

  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  // Load SIM slot
  _loadSimSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSimSlot = prefs.getInt('simSlot');
    });
  }

  _saveSimSlot(int simSlot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('simSlot', simSlot);
    setState(() {
      _selectedSimSlot = simSlot;
    });
  }

  // Send SMS
  Future<void> _sendSms(String phoneNumber, String message) async {
    if (_selectedSimSlot == null) {
      await _selectSimSlot();
    }

    if (_selectedSimSlot != null) {
      var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: _selectedSimSlot!,
      );

      if (result == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent through SIM ${_selectedSimSlot! + 1}");
      } else {
        Fluttertoast.showToast(msg: "Message failed to send");
      }
    }
  }

  Future<void> _selectSimSlot() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select SIM Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("SIM 1"),
                onTap: () {
                  _saveSimSlot(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("SIM 2"),
                onTap: () {
                  _saveSimSlot(1);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Location Tracking
  void _startLocationTracking() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _fetchAddress();
      });
    });
  }

  Future<void> _fetchAddress() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (!mounted) return;
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.subLocality}";
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Failed to get address: $e");
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  // Send location to contacts
  Future<void> _sendLocationToContacts() async {
    if (_isFetchingLocation) {
      Fluttertoast.showToast(msg: "Fetching location, please wait...");
      return;
    }

    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Location is not available.");
      return;
    }

    String messageBody =
        "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";

    if (await _isPermissionGranted()) {
      List<Tcontact> contactList = await DatabaseHelper().getContactList();
      for (Tcontact contact in contactList) {
        await _sendSms(contact.number, "I am in trouble, please reach me at $messageBody");
      }
    } else {
      Fluttertoast.showToast(msg: "SMS permission not granted.");
    }
  }

  // Random Quote
  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  // Speech Recognition Initialization
  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          setState(() {
            _voiceStatus = "Listening";
          });

          if (!_hasStarted) {
            _showToast("Start recognising");
            _hasStarted = true;
          }
        } else if (status == 'done') {
          setState(() {
            _voiceStatus = "Not Listening";
          });
          if (_isListening) {
            _startListening(); // Automatically restart if still enabled
          }
        }
      },
      onError: (error) {
        setState(() {
          _voiceStatus = "Error: $error";
        });
      },
    );
  }

  // Start Listening
  void _startListening() {
    _speech.listen(
      onResult: (val) {
        setState(() {
          _recognizedWords = val.recognizedWords;

          if (_recognizedWords.toLowerCase().contains('me to')) {
            _sendLocationToContacts();
          }
        });
      },
    );
  }

  // Toggle Voice Recognition
  void _toggleVoiceRecognition() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _voiceStatus = "Not Listening";
      });
    } else {
      setState(() {
        _isListening = true;
        _voiceStatus = "Listening";
      });
      _startListening();
    }
  }

  // Show Toast Message
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
                  // Removed the `quoteIndex` and `oneTap` parameters if not needed
                ),
                // Voice recognition section with toggle button
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
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _toggleVoiceRecognition,
                        child: Text(_isListening ? "Stop Listening" : "Start Listening"),
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
