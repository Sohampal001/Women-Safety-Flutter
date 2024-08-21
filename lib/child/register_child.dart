import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/components/custom_textfield.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/components/secondaryButton.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:women_safety/model/user_model.dart';
import 'package:women_safety/utils/constants.dart';

class RegisterChildScreen extends StatefulWidget {
  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  bool isPasswordShown = false;
  bool isRetypePasswordShown = false;
  
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  _onSubmit() async {
    _formKey.currentState!.save();
    
    if (_formData['Password'] != _formData['rPassword']) {
      dialogBox(context, "Passwords do not match");
      return;
    }

    progressIndicator(context);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _formData['cemail']!,
        password: _formData["Password"]!,
      );

      if (userCredential.user != null) {
        DocumentReference<Map<String, dynamic>> db = 
            FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);

        final user = UserModel(
          name: _formData['name']!,
          phone: _formData['phone']!,
          childEmail: _formData['cemail']!,
          parentEmail: _formData['gemail']!,
          id: userCredential.user!.uid,
          type: 'child'
        );

        final jsonData = user.toJson();
        await db.set(jsonData);
        print("Data added to Firestore");

        Navigator.of(context).pop(); // Dismiss the progress dialog
        goTo(context, LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      if (e.code == 'weak-password') {
        dialogBox(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        dialogBox(context, 'The account already exists for that email.');
      } else {
        dialogBox(context, e.message ?? 'An error occurred.');
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "REGISTER FOR NEW USER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 216, 69, 118),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTextfield(
                          hintText: "Enter Name",
                          textInputAction: TextInputAction.next,
                          Keyboardtype: TextInputType.name,
                          prefix: Icon(Icons.woman_2_rounded),
                          onsave: (name) {
                            _formData['name'] = name ?? "";
                          },
                          validate: (name) {
                            if (name!.isEmpty || name.length < 3) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                        ),
                        CustomTextfield(
                          hintText: "Enter Phone No",
                          textInputAction: TextInputAction.next,
                          Keyboardtype: TextInputType.phone,
                          prefix: Icon(Icons.phone),
                          onsave: (phone) {
                            _formData['phone'] = phone ?? "";
                          },
                          validate: (phone) {
                            if (phone!.isEmpty || phone.length < 10) {
                              return "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),
                        CustomTextfield(
                          hintText: "Enter Email...",
                          textInputAction: TextInputAction.next,
                          Keyboardtype: TextInputType.emailAddress,
                          prefix: Icon(Icons.email),
                          onsave: (email) {
                            _formData['cemail'] = email ?? "";
                          },
                          validate: (email) {
                            if (email!.isEmpty || !email.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        CustomTextfield(
                          hintText: "Enter Guardian Email...",
                          textInputAction: TextInputAction.next,
                          Keyboardtype: TextInputType.emailAddress,
                          prefix: Icon(Icons.email),
                          onsave: (gemail) {
                            _formData['gemail'] = gemail ?? "";
                          },
                          validate: (gemail) {
                            if (gemail!.isEmpty || !gemail.contains("@")) {
                              return "Enter a valid guardian email";
                            }
                            return null;
                          },
                        ),
                        CustomTextfield(
                          hintText: "Enter Password",
                          isPassword: isPasswordShown,
                          prefix: Icon(Icons.vpn_key_rounded),
                          onsave: (password) {
                            _formData['Password'] = password ?? "";
                          },
                          validate: (password) {
                            if (password!.isEmpty || password.length < 7) {
                              return "Enter a valid password";
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
                        CustomTextfield(
                          hintText: "Retype Password",
                          isPassword: isRetypePasswordShown,
                          prefix: Icon(Icons.vpn_key_rounded),
                          onsave: (rPassword) {
                            _formData['rPassword'] = rPassword ?? "";
                          },
                          validate: (rPassword) {
                            if (rPassword!.isEmpty || rPassword.length < 7) {
                              return "Enter a valid password";
                            }
                            return null;
                          },
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                isRetypePasswordShown = !isRetypePasswordShown;
                              });
                            },
                            icon: isRetypePasswordShown
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
                          title: "REGISTER",
                        ),
                      ],
                    ),
                  ),
                ),
                secondaryButton(
                  title: "Login with your account",
                  onPressed: () {
                    goTo(context, LoginScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
