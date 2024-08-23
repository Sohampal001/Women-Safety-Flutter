import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/db/db_services.dart';
import 'package:women_safety/model/contactsm.dart';

class Safehome extends StatefulWidget {
  const Safehome({super.key});

  @override
  State<Safehome> createState() => _SafehomeState();
}

class _SafehomeState extends State<Safehome> {
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    ).then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent");
      } else {
        Fluttertoast.showToast(msg: "Message failed");
      }
    });
  }

  _getCurrentLocation() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
         _currentAddress= "${place.locality}, ${place.postalCode},${place.street}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState( ){
    super.initState();
    _getPermission();
    _getCurrentLocation();
  }



  showModalSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 148, 176, 218),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SEND YOUR LOCATION TO YOUR TRUSTED CONTACT",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                if(_currentPosition!=null) Text(_currentAddress!),
                primaryButton(onPressed: () {
                  _getCurrentLocation();
                }, title: "GET LOCATION"),
                SizedBox(height: 10),
                primaryButton(onPressed: () async{
                  List<Tcontact> contactList= await DatabaseHelper().getContactList();
                  String recipients = "";
                  int i =1;
                  for (Tcontact contact in contactList) {
                    recipients+=contact.number;
                    if (i!=contactList.length) {
                      recipients+=";";
                      i++;
                    }
                  }
                  String messageBody="https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";
                  if (await _isPermissionGranted()) {
                    contactList.forEach((element){
                      _sendSms("${element.number}", "I am in trouble please reach me out at $messageBody",simSlot: 1);
                    });
                  }
                  else{
                    Fluttertoast.showToast(msg: "something wrong");
                  }
                }, title: "SEND ALERT"),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Send Location'),
                      subtitle: Text("Share Location"),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/images/location.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
