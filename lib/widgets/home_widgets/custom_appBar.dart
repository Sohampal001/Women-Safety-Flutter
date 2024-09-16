import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  CustomAppbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 250, 129, 240),
            Color.fromARGB(255, 250, 125, 240),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Surakhsha",
            style: TextStyle(
              fontSize: 24, // Reduced font size
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat', // Customize the font family
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 3.0,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
              letterSpacing: 1.5, // Adjusted letter spacing
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
