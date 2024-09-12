import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:women_safety/db/shared_pref.dart';
import 'package:women_safety/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logoutUser() async {
  await MySharedPrefference.clearUserEmail();
  
  
  // Navigate to login screen or take other logout actions
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: TextButton(onPressed: ()async{
        try {

          FirebaseAuth.instance.signOut();
          logoutUser();
          goTo(context, LoginScreen());
        }on  FirebaseAuthException catch (e) {
          dialogBox(context, e.toString());
        }
      }, child: Text('SIGN OUT'))),
    );
  }
}