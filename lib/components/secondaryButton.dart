import 'package:flutter/material.dart';

class secondaryButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  const secondaryButton({Key? key,required this.title,required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: TextButton(onPressed: () {
        onPressed();
      } , child: Text(title,
      style: TextStyle(fontSize: 20,
      fontWeight: FontWeight.bold),),),
    );
  }
}