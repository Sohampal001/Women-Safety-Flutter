import 'package:flutter/material.dart';
import 'package:women_safety/widgets/emergencies/AmbulanceEmergency.dart';
import 'package:women_safety/widgets/emergencies/firebridgateemergency.dart';
import 'package:women_safety/widgets/emergencies/policeemergency.dart';
import 'package:women_safety/widgets/emergencies/womenhelpline.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          womenhelpline(),
          AmbulanceEmergency(),
          firebridgateemergency(),

        ],
      ),
    );
  }
}