import 'package:flutter/material.dart';
import 'package:women_safety/utils/quotes.dart';

class CustomAppbar extends StatelessWidget {
  final Function oneTap;
  final int quoteIndex;

  CustomAppbar({required this.oneTap, required this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        oneTap();
      },
      child: Container(
child: Container(
  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 90),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 250, 129, 240), Color.fromARGB(255, 250, 125, 240)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(4, 4),
      ),
    ],
  ),

        child: Text(
    "Surakhsha",
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat', // You can customize the font family
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: Colors.black45,
          offset: Offset(3, 3),
        ),
      ],
      letterSpacing: 2.0, // To add spacing between letters
    ),
    textAlign: TextAlign.center, // Align the text in the center
  ),
),
      ),
    );
  }
}
