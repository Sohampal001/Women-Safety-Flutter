import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

class SurroundedByMen extends StatefulWidget {
  @override
  _SurroundedByMenState createState() => _SurroundedByMenState();
}

class _SurroundedByMenState extends State<SurroundedByMen> {
  bool isTracking = false; // Toggle for tracking
  Timer? _timer;
  List<Map<String, dynamic>> menNearby = [];
  Position? currentPosition;

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  // Start or stop tracking based on button press
  void _toggleTracking() {
    if (isTracking) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  // Start tracking nearby men users
  void _startTracking() {
    setState(() {
      isTracking = true;
    });
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getCurrentLocationAndNearbyUsers();
    });
    _getCurrentLocationAndNearbyUsers(); // Immediately call the function
  }

  // Stop tracking nearby users
  void _stopTracking() {
    setState(() {
      isTracking = false;
    });
    _timer?.cancel(); // Cancel the timer
    menNearby.clear(); // Clear the list of men nearby
  }

  // Get the current location and find nearby users
  Future<void> _getCurrentLocationAndNearbyUsers() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (currentPosition != null) {
        await _findNearbyMenUsers(); // Fetch nearby men users

        if (mounted) { // Ensure widget is still mounted
          setState(() {});
        }
      }
    } catch (e) {
      print("Error getting location: $e");
      if (mounted) {
        _showLocationError();
      }
    }
  }

  // Find nearby male users within 10 meters
  Future<void> _findNearbyMenUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();

    List<Map<String, dynamic>> nearbyMen = [];
    bool femaleFound = false;

    for (var doc in usersSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      if (data['latitude'] != null && data['longitude'] != null) {
        double userLat = data['latitude'];
        double userLng = data['longitude'];
        double distance = _calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
          userLat,
          userLng,
        );

        if (distance <= 0.01) {
          // User within 10 meters
          if (data['gender'] == 'Male') {
            nearbyMen.add({
              'name': data['name'],
              'distance': distance * 1000, // Distance in meters
            });
          } else if (data['gender'] == 'Female') {
            femaleFound = true; // Female user found
          }
        }
      }
    }

    if (mounted) { // Ensure widget is still mounted
      setState(() {
        menNearby = nearbyMen;

        // If no female users found, alert the user
        if (!femaleFound) {
          _showAlert();
        }
      });
    }
  }

  // Show an alert if no female users are nearby
  void _showAlert() {
    Fluttertoast.showToast(
      msg: "You're surrounded by men!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Calculate distance between two locations
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the earth in kilometers
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c; // Distance in kilometers
    return distance; // Distance in kilometers
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  // Show an error if location cannot be fetched
  void _showLocationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Error"),
        content: Text("Could not fetch location. Please enable GPS."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,  // Icon to represent alert or caution
              color: Colors.redAccent,      // Warning color
              size: 30,                     // Adjust icon size
            ),
            SizedBox(width: 10),             // Space between icon and text
            Text(
              'Surrounded by Men',
              style: TextStyle(
                color: Colors.white,          // Text color
                fontWeight: FontWeight.bold,  // Bold font for emphasis
                fontSize: 22,                 // Adjust text size
              ),
            ),
          ],
        ),
        centerTitle: true,                  // Center align the title
        elevation: 5,                       // Add slight shadow for depth
        backgroundColor: Colors.deepPurple, // Custom background color
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            color: Colors.white,            // Add an info button for help/details
            onPressed: () {
              // Action to be performed
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.blueAccent], // Gradient background
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(isTracking ? "Stop Tracking" : "Start Tracking"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTracking ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: menNearby.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(menNearby[index]['name']),
                    subtitle: Text(
                      "${menNearby[index]['distance'].toStringAsFixed(2)} meters",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
