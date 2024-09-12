import 'dart:async';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isFetchingLocation = true;
  int? _selectedSimSlot;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getPermission();
    _startLocationTracking();
    _loadSimSlot();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  _getPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await [Permission.sms, Permission.location].request();
    }
  }

  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _loadSimSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSimSlot = prefs.getInt('simSlot');
    });
  }

  _saveSimSlot(int simSlot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('simSlot', simSlot);
    setState(() {
      _selectedSimSlot = simSlot;
    });
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    if (_selectedSimSlot == null) {
      await _selectSimSlot();
    }

    if (_selectedSimSlot != null) {
      var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: _selectedSimSlot!,
      );

      if (result == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message sent through SIM ${_selectedSimSlot! + 1}");
      } else {
        Fluttertoast.showToast(msg: "Message failed to send");
      }
    }
  }

  Future<void> _selectSimSlot() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select SIM Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("SIM 1"),
                onTap: () {
                  _saveSimSlot(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("SIM 2"),
                onTap: () {
                  _saveSimSlot(1);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startLocationTracking() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
    );

    AndroidSettings androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    );

    AppleSettings appleSettings = AppleSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _fetchAddress();
      });
    });
  }

  Future<void> _fetchAddress() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (!mounted) return;
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.subLocality}";
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Failed to get address: $e");
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _sendLocationToContacts() async {
    if (_isFetchingLocation) {
      Fluttertoast.showToast(msg: "Fetching location, please wait...");
      return;
    }

    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Location is not available.");
      return;
    }

    String messageBody = "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";

    if (await _isPermissionGranted()) {
      List<Tcontact> contactList = await DatabaseHelper().getContactList();
      for (Tcontact contact in contactList) {
        await _sendSms(contact.number, "I am in trouble, please reach me at $messageBody");
      }
    } else {
      Fluttertoast.showToast(msg: "SMS permission not granted.");
    }
  }

  void triggerSOS() async {
    await _sendLocationToContacts();
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
                if (_isFetchingLocation)
                  CircularProgressIndicator()
                else if (_currentAddress != null)
                  Text(_currentAddress!),
                SizedBox(height: 10),
                primaryButton(
                  onPressed: () => _sendLocationToContacts(),
                  title: "SEND ALERT",
                ),
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
