import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'package:women_safety/db/shared_pref.dart'; // Make sure you have a method to get email from cookies
import 'package:fluttertoast/fluttertoast.dart'; // Import for toast notifications
import 'dart:math';
import 'dart:async'; // Import for Timer

class NearestUsers extends StatefulWidget {
  @override
  _NearestUsersState createState() => _NearestUsersState();
}

class _NearestUsersState extends State<NearestUsers> {
  int nearbyUsersCount = 0;
  Position? currentUserPosition;
  List<String> nearbyUserNames = [];
  String? currentUserId; // Store the current user's UID
  Timer? _timer; // Timer for automatic detection

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndNearbyUsers(); // Fetch nearby users immediately on load

    // Set up a timer to detect nearby users every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _getCurrentLocationAndNearbyUsers();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Get the current user's location and then fetch nearby users
  Future<void> _getCurrentLocationAndNearbyUsers() async {
    try {
      currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (currentUserPosition != null) {
        _getNearbyUsers();
      }
    } catch (e) {
      _showLocationError(); // Handle the error when location is not found
    }
  }

  // Get the currently logged-in user's UID using the email stored in cookies and exclude them from the nearby users list
  Future<void> _getNearbyUsers() async {
    String? email = await MySharedPrefference.getUserEmail(); // Fetch email from cookies

    if (email != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == email) {
        currentUserId = user.uid; // Set current user UID
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    List<String> nearbyUsers = [];

    for (var doc in usersSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Exclude the current user from the nearby users list based on UID
      if (data['uid'] != currentUserId) {
        if (data['latitude'] != null && data['longitude'] != null) {
          double userLat = data['latitude'];
          double userLng = data['longitude'];

          double distance = _calculateDistance(
            currentUserPosition!.latitude,
            currentUserPosition!.longitude,
            userLat,
            userLng,
          );

          // Check if the user is within 100 meters
          if (distance <= 0.1) {
            nearbyUsers.add(data['name']); // Store the user's name
          }
        }
      }
    }

    setState(() {
      nearbyUsersCount = nearbyUsers.length;
      nearbyUserNames = nearbyUsers;

      // If no nearby users, show notification that the user is alone
      if (nearbyUsersCount == 1) {
        _showAloneNotification();
      }
    });
  }

  // Function to show a toast notification if no nearby users are found
  void _showAloneNotification() {
    Fluttertoast.showToast(
      msg: "You are alone. No nearby users found.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Calculate the distance between two coordinates using the Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c; // Distance in kilometers

    return distance; // Return distance in kilometers
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  // Show an alert dialog if location cannot be found
  void _showLocationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Error"),
        content: Text("Could not fetch location. Please reset the app."),
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

  // Function to show nearest users in a dialog
  void _showNearestUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nearest Users"),
        content: nearbyUserNames.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: nearbyUserNames
                    .map((name) => Text(name, style: TextStyle(fontSize: 16)))
                    .toList(),
              )
            : Text("No nearby users found."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: _showNearestUsersDialog, // Show users on tap
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 64, 231, 189),
                  Color.fromARGB(255, 118, 90, 233),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: Image.asset("assets/images/nearUser.png"),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nearest Users",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                          ),
                        ),
                        Text(
                          "Number of nearby users",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "$nearbyUsersCount",
                              style: TextStyle(
                                color: Colors.red[300],
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
