import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety/db/shared_pref.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:women_safety/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  Map<String, dynamic>? userData; // Store user data here

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the logged-in user's data from Firestore
  Future<void> _fetchUserData() async {
    try {
      // Get the currently logged-in user from Firebase Auth
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser!.uid;

        // Get the user data from Firestore based on UID
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?; // Store the user data
          });
        } else {
          print("User data not found.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Logout logic
  Future<void> logoutUser(BuildContext context) async {
    try {
      // Clear user email from shared preferences
      await MySharedPrefference.clearUserEmail();
      
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Navigate to the login screen and remove all previous routes (so the user can't navigate back)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), 
        (Route<dynamic> route) => false, // This clears the entire navigation stack
      );
    } on FirebaseAuthException catch (e) {
      // Show error if Firebase throws any exception
      dialogBox(context, e.toString()); // Assuming `dialogBox` is a utility function to show a dialog box with an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: userData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display user's profile image
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: userData!['profileImageUrl'] != null
                          ? NetworkImage(userData!['profileImageUrl'])
                          : null,
                      child: userData!['profileImageUrl'] == null
                          ? Icon(Icons.person, size: 50, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),

                  // User's Name
                  Text(
                    userData!['name'] ?? 'No Name Available',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Decorative Email Card
                  Card(
                    color: Colors.lightBlue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.email, color: Colors.blueAccent),
                      title: Text(
                        currentUser!.email ?? 'No Email Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Decorative Phone Card
                  Card(
                    color: Colors.lightBlue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.phone, color: Colors.blueAccent),
                      title: Text(
                        userData!['phone'] ?? 'No Phone Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  Spacer(),

                  // Logout Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      await logoutUser(context); // Call logout function
                    },
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(), // Show loader while fetching data
            ),
    );
  }
}
