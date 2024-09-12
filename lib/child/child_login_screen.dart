import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/components/custom_textfield.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/components/secondaryButton.dart';
import 'package:women_safety/child/register_child.dart';
import 'package:women_safety/db/shared_pref.dart';
import 'package:women_safety/parent/parent_home_screen.dart';
import 'package:women_safety/parent/parent_register_screen.dart';
import 'package:women_safety/utils/constants.dart';

import 'package:women_safety/child/bottom_screens/child_home_page.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = false;
  final _formKey = GlobalKey<FormState>();
  final _fromData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();
  try {
    progressIndicator(context);
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _fromData["email"].toString(),
      password: _fromData["Password"].toString(),
    );
    FirebaseFirestore.instance.collection('users')
    .doc(userCredential.user!.uid)
    .get()
    .then((Value){
      if (Value['type']=='parent') {
        MySharedPrefference.saveUserType('parent');
        Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ParentHomeScreen()),
    );
      }
      else{
        MySharedPrefference.saveUserType('child');

      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => BottomPage()),
    );

      }
    });
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => HomeScreen()),
    // );

  } on FirebaseAuthException catch (e) {
    Navigator.of(context).pop(); // Close the progress indicator

    if (e.code == 'user-not-found') {
      dialogBox(context, 'No user found for that email.');
    } else if (e.code == 'wrong-password') {
      dialogBox(context, 'Wrong password provided for that user.');
    } else if (e.code == 'invalid-email') {
      dialogBox(context, 'The email address is badly formatted.');
    } else if (e.code == 'user-disabled') {
      dialogBox(context, 'This user has been disabled.');
    } else if (e.code == 'operation-not-allowed') {
      dialogBox(context, 'Operation not allowed. Please contact support.');
    } else if (e.code == 'too-many-requests') {
      dialogBox(context, 'Too many attempts to sign in. Please try again later.');
    } else {
      dialogBox(context, 'An unknown error occurred: ${e.message}');
    }
  } catch (e) {
    Navigator.of(context).pop();
    dialogBox(context, 'An error occurred: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "USER LOGIN",
                  style: TextStyle(
                      fontSize: 40,
                      color: const Color.fromARGB(255, 233, 30, 142),
                      fontWeight: FontWeight.bold),
                ),
                CustomTextfield(
                  hintText: "Enter Email...",
                  textInputAction: TextInputAction.next,
                  Keyboardtype: TextInputType.emailAddress,
                  prefix: Icon(Icons.email),
                  onsave: (email) {
                    _fromData['email'] = email ?? "";
                  },
                  validate: (email) {
                    if (email!.isEmpty || email.length < 3 || !email.contains("@")) {
                      return " Enter correct Email";
                    }
                    return null;
                  },
                ),
                CustomTextfield(
                  hintText: "Enter Password",
                  isPassword: isPasswordShown,
                  prefix: Icon(Icons.vpn_key_rounded),
                  onsave: (Password) {
                    _fromData['Password'] = Password ?? "";
                  },
                  validate: (Password) {
                    if (Password!.isEmpty || Password.length < 7) {
                      return " Enter correct Password";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordShown = !isPasswordShown;
                      });
                    },
                    icon: isPasswordShown
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                  ),
                ),
                primaryButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _onSubmit();
                      }
                    },
                    title: "LOGIN"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot Password",
                      style: TextStyle(fontSize: 18),
                    ),
                    secondaryButton(
                        title: "click here", onPressed: () {}),
                  ],
                ),
                secondaryButton(
                    title: "Register As child",
                    onPressed: () {
                      goTo(context, RegisterChildScreen());
                    }),
                secondaryButton(
                    title: "Register  As Parent",
                    onPressed: () {
                      goTo(context, RegisterParentScreen());
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
