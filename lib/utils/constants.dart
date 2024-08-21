import 'package:flutter/material.dart';

void goTo(BuildContext context,Widget nextScreen){
  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => nextScreen));
}
progressIndicator(BuildContext context){
  showDialog(
      barrierDismissible: false,
      context: context, builder: (context) => Center(child: CircularProgressIndicator(
        backgroundColor: Color.fromARGB(255, 148, 183, 216),
        color: const Color.fromARGB(255, 90, 157, 212),
        strokeWidth: 4,
      )));
}
dialogBox(BuildContext context,String text){
  showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(text),
      ));
}