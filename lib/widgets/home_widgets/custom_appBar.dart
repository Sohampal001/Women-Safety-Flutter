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
        child: Text(
          sweetSayings[quoteIndex],
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
