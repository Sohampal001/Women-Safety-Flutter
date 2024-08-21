import 'package:flutter/material.dart';

class BusstationCard extends StatelessWidget {
  final Function(String)? onMapFunction;
  const BusstationCard({Key? key, this.onMapFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onMapFunction?.call("bus stations near me");
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    'assets/images/bus-stop.png',
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text("Bus Stops")
        ],
      ),
    );
  }
}
