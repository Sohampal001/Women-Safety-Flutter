import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety/db/shared_pref.dart'; // Ensure you have a method to get email from cookies
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
  List<Map<String, dynamic>> nearbyUsersInfo = []; // Store nearby users' info including distance
  String? currentUserId; // Store the current user's UID
  Timer? _timer; // Timer for automatic detection

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndNearbyUsers(); // Fetch nearby users immediately on load

    // Set up a timer to track user's location every 10 seconds and store it in Firestore
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _trackUserLocation(); // Track and update location every 10 seconds
      _getCurrentLocationAndNearbyUsers(); // Fetch nearby users every 10 seconds
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Track and store user's location in Firestore every 10 seconds
  Future<void> _trackUserLocation() async {
    try {
      currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (currentUserPosition != null) {
        // Get the currently logged-in user's UID
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          currentUserId = user.uid;

          // Update user's location in Firestore
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          DocumentReference userDoc = firestore.collection('users').doc(currentUserId);

          // Update latitude and longitude fields in Firestore
          await userDoc.update({
            'latitude': currentUserPosition!.latitude,
            'longitude': currentUserPosition!.longitude,
          });

          print("User location updated in Firestore.");
        }
      }
    } catch (e) {
      print("Error tracking location: $e");
      _showLocationError(); // Handle error if location is not found
    }
  }

  // Get the current user's location and then fetch nearby users
  Future<void> _getCurrentLocationAndNearbyUsers() async {
    try {
      currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      if (currentUserPosition != null) {
        _getNearbyUsers();
      }
    } catch (e) {
      _showLocationError(); // Handle the error when location is not found
    }
  }

  // Get the nearby users within 100 meters
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
    List<Map<String, dynamic>> nearbyUsers = []; // List of nearby users' info

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
            nearbyUsers.add({
              'name': data['name'], // Store the user's name
              'distance': distance * 1000 // Store the distance in meters
            });
          }
        }
      }
    }

    setState(() {
      nearbyUsersCount = nearbyUsers.length;
      nearbyUsersInfo = nearbyUsers;

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

  // Convert degrees to radians
  double _degToRad(double degree) {
    return degree * pi / 180.0;
  }
  // Calculate the distance between two coordinates using the Vincenty formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double a = 6378137.0; // WGS-84 ellipsoid parameters
    const double f = 1 / 298.257223563;
    const double b = 6356752.314245;

    double L = _degToRad(lon2 - lon1);
    double U1 = atan((1 - f) * tan(_degToRad(lat1)));
    double U2 = atan((1 - f) * tan(_degToRad(lat2)));
    double sinU1 = sin(U1), cosU1 = cos(U1);
    double sinU2 = sin(U2), cosU2 = cos(U2);

    double lambda = L, lambdaP, iterLimit = 100;
    double cosSqAlpha, sinSigma, cos2SigmaM, cosSigma, sigma;

    do {
      double sinLambda = sin(lambda), cosLambda = cos(lambda);
      sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
      if (sinSigma == 0) return 0; // co-incident points
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      double sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L + (1 - C) * f * sinAlpha *
          (sigma + C * sinSigma *
              (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    } while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0);

    if (iterLimit == 0) return double.nan; // formula failed to converge

    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B * sinSigma *
        (cos2SigmaM + B / 4 *
            (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) *
                    (-3 + 4 * cos2SigmaM * cos2SigmaM)));

    double s = b * A * (sigma - deltaSigma);

    return s / 1000; // Return distance in kilometers
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
        content: nearbyUsersInfo.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: nearbyUsersInfo
                    .map((user) => Text(
                          "${user['name']} - ${user['distance'].toStringAsFixed(2)} meters",
                          style: TextStyle(fontSize: 16),
                        ))
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
