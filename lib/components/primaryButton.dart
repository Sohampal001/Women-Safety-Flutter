import 'package:flutter/material.dart';

class primaryButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final bool loading;
  primaryButton({
     this.loading = false,
    required this.onPressed,
    required this.title,
  });

  

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
        onPressed();
      },
      child: Text(title,
      style:TextStyle(fontSize: 18) ,),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 227, 143, 193),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
        )
      ),
      ),
    );
  }
}