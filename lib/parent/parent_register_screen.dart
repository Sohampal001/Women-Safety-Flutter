import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/components/custom_textfield.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/components/secondaryButton.dart';
import 'package:women_safety/child/child_login_screen.dart';
import 'package:women_safety/model/user_model.dart';
import 'package:women_safety/utils/constants.dart';

class RegisterParentScreen extends StatefulWidget {
  @override
  State<RegisterParentScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterParentScreen> {
  bool isPasswordShown=false;
  bool isRetypePasswordShown=false;

  final _formKey= GlobalKey<FormState>();

  final _fromData =Map<String,Object>();

  _onSubmit() async {
  _formKey.currentState!.save();
  if (_fromData['Password'] != _fromData['rPassword']) {
    dialogBox(context, "Password isn't matching");
    return;
  }

  progressIndicator(context);
  try {
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _fromData['gemail'].toString(),
      password: _fromData["Password"].toString(),
  );
  if(userCredential.user!=null){

  }DocumentReference<Map<String, dynamic>> db = 
      FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);

    final User = UserModel(
      name: _fromData['name'].toString(),
      phone: _fromData['phone'].toString(),
      childEmail: _fromData['cemail'].toString(),
      parentEmail: _fromData['gemail'].toString(),
      id: userCredential.user!.uid,
      type: "parent",
    );

    final jsonData = User.toJson();

    await db.set(jsonData);
    print("Data added to Firestore");
    Navigator.of(context).pop(); // Dismiss the progress dialog
    goTo(context, LoginScreen());
} on FirebaseAuthException catch (e) {
  Navigator.of(context).pop();
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
     dialogBox(context, 'The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.'); 
    dialogBox(context, 'The account already exists for that email.');
  }
} catch (e) {
  Navigator.of(context).pop();
  print(e);
   dialogBox(context, e.toString());
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
              children:[
                Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("REGISTER FOR PARENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 216, 69, 118)
                      ),
                      )
                    ],),
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.75,
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
                    onsave:(name) {
                      _fromData['name']=name ?? "";
                    },
                    validate: ( email){
                      if (email !.isEmpty || email.length<3) {
                        return " Enter correct Name";
                      }
                      return null;
                    },
                        ),
                        CustomTextfield(
                        hintText: "Enter Phone N0",
                    textInputAction: TextInputAction.next,
                    Keyboardtype: TextInputType.phone,
                    prefix: Icon(Icons.woman_2_rounded),
                    onsave:(phone) {
                      _fromData['phone']=phone ?? "";
                    },
                    validate: ( email){
                      if (email !.isEmpty || email.length<10) {
                        return " Enter correct phone";
                      }
                      return null;
                    },
                        ),
                        CustomTextfield(
                        hintText: "Enter Email...",
                    textInputAction: TextInputAction.next,
                    Keyboardtype: TextInputType.emailAddress,
                    prefix: Icon(Icons.email),
                    onsave:(email) {
                      _fromData['gemail']=email ?? "";
                    },
                    validate: ( email){
                      if (email !.isEmpty || email.length<3 || !email.contains("@")) {
                        return " Enter correct Email";
                      }
                      return null;
                    },
                        ),
                        CustomTextfield(
                        hintText: "Enter child Email...",
                    textInputAction: TextInputAction.next,
                    Keyboardtype: TextInputType.emailAddress,
                    prefix: Icon(Icons.email),
                    onsave:(cemail) {
                      _fromData['cemail']=cemail ?? "";
                    },
                    validate: ( email){
                      if (email !.isEmpty || email.length<3 || !email.contains("@")) {
                        return " Enter correct Email";
                      }
                      return null;
                    },
                        ),
                         CustomTextfield(
            
                          
                    hintText: "Enter Password",
                    isPassword: isPasswordShown,
                    prefix: Icon(Icons.vpn_key_rounded),
                    onsave:(Password) {
                      _fromData['Password']=Password ?? "";
                    },
                    validate: ( Password){
                      if (Password !.isEmpty || Password.length<7) {
                        return " Enter correct Password";
                      }
                      return null;
                    },
                    suffix: IconButton(onPressed: () {
                      setState(() {
                        isPasswordShown=!isPasswordShown;
                      });
                      
                    },icon: isPasswordShown?Icon(Icons.visibility_off): Icon(Icons.visibility),),
                  ),
                  CustomTextfield(
            
                          
                    hintText: "Retype Password",
                    isPassword: isRetypePasswordShown,
                    prefix: Icon(Icons.vpn_key_rounded),
                    onsave:(Password) {
                      _fromData['rPassword']=Password ?? "";
                    },
                    validate: ( Password){
                      if (Password !.isEmpty || Password.length<7) {
                        return " Enter correct Password";
                      }
                      return null;
                    },
                    suffix: IconButton(onPressed: () {
                      setState(() {
                        isRetypePasswordShown=!isRetypePasswordShown;
                      });
                      
                    },icon: isRetypePasswordShown?Icon(Icons.visibility_off): Icon(Icons.visibility),),
                  ),
                  primaryButton(onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      _onSubmit();
                    }
                    
                  }, title: "REGISTER")
            
                      ],
                    ),
                  ),
                ),
                
                secondaryButton(title: "Login with your account", onPressed: (){
                  goTo(context, LoginScreen());
                })
              ],),
          ),
        ),
      ),
    );
  }
}