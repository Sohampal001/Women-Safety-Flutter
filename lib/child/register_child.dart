import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/components/custom_textfield.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/components/secondaryButton.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:women_safety/model/user_model.dart';
import 'package:women_safety/utils/constants.dart';
import 'package:geolocator/geolocator.dart'; // Geolocator for fetching location

class RegisterChildScreen extends StatefulWidget {
  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  bool isPasswordShown = false;
  bool isRetypePasswordShown = false;

  final _formKey = GlobalKey<FormState>();
  final Map<String, String?> _formData = {};
  String? _selectedGender;

  // Method to get current location
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Location services are disabled
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Location permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Location permissions are permanently denied
    }

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      return null; // Error fetching location
    }
  }

  _onSubmit() async {
    _formKey.currentState?.save();

    if (_formData['Password'] != _formData['rPassword']) {
      dialogBox(context, "Passwords do not match");
      return;
    }

    if (_selectedGender == null) {
      dialogBox(context, "Please select a gender");
      return;
    }

    progressIndicator(context);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _formData['cemail']!,
        password: _formData["Password"]!,
      );

      if (userCredential.user != null) {
        // Get current location
        Position? position = await _determinePosition();

        if (position == null) {
          // If location is not found, show alert to the user
          Navigator.of(context).pop(); // Dismiss the progress dialog
          dialogBox(context, "Unable to retrieve location. Please reset the app and try again.");
          return;
        }

        DocumentReference<Map<String, dynamic>> db = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);

        final user = UserModel(
          name: _formData['name'],
          phone: _formData['phone'],
          childEmail: _formData['cemail'],
          parentEmail: _formData['gemail'],
          id: userCredential.user!.uid,
          gender: _selectedGender, // Added gender field to the UserModel
          type: 'child',
          latitude: position.latitude, // Storing latitude
          longitude: position.longitude, // Storing longitude
        );

        final jsonData = user.toJson();
        await db.set(jsonData);
        print("Data and location added to Firestore");

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
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromARGB(255, 227, 143, 193), width: 2),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            hint: Text(
                              "Select Gender",
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            dropdownColor: Colors.white,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                            onSaved: (value) {
                              _selectedGender = value;
                            },
                            items: ['Male', 'Female', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.black, fontSize: 18),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a gender';
                              }
                              return null;
                            },
                            iconEnabledColor: Colors.white,
                          ),
                        ),



                        CustomTextfield(
                          hintText: "Enter Name",
                          textInputAction: TextInputAction.next,
                          Keyboardtype: TextInputType.name,
                          prefix: Icon(Icons.woman_2_rounded),
                          onsave: (name) {
                            _formData['name'] = name;
                          },
                          validate: (name) {
                            if (name == null || name.isEmpty || name.length < 3) {
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
                            _formData['phone'] = phone;
                          },
                          validate: (phone) {
                            if (phone == null || phone.isEmpty || phone.length < 10) {
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
                            _formData['cemail'] = email;
                          },
                          validate: (email) {
                            if (email == null || email.isEmpty || !email.contains("@")) {
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
                            _formData['gemail'] = gemail;
                          },
                          validate: (gemail) {
                            if (gemail == null || gemail.isEmpty || !gemail.contains("@")) {
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
                            _formData['Password'] = password;
                          },
                          validate: (password) {
                            if (password == null || password.isEmpty || password.length < 7) {
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
                          hintText: "Re-Enter Password",
                          isPassword: isRetypePasswordShown,
                          prefix: Icon(Icons.vpn_key_rounded),
                          onsave: (rPassword) {
                            _formData['rPassword'] = rPassword;
                          },
                          validate: (rPassword) {
                            if (rPassword == null || rPassword.isEmpty || rPassword.length < 7) {
                              return "Re-Enter Password";
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

                        // Primary Button for Registration
                        primaryButton(
                          title: "Register",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _onSubmit();
                            }
                          },
                        ),
                        secondaryButton(
                          title: "Already have an Account? Login",
                          onPressed: () {
                            goTo(context, LoginScreen());
                          },
                        ),
                      ],
                    ),
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
