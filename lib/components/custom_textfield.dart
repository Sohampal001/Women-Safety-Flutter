import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validate;
  final Function(String?)? onsave;
  final int? maxlines;
  final bool isPassword;
  final bool enable;
  final bool? check;
  final TextInputType? Keyboardtype;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;

  CustomTextfield({this.enable=true,this.check,this.Keyboardtype,this.controller,this.focusNode,this.hintText,
  this.isPassword=false,this.maxlines,this.onsave,this.prefix,this.suffix,this.textInputAction,this.validate});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        enabled: enable == true ? true : enable,
        maxLines: maxlines == null ? 1 : maxlines,
        onSaved: onsave ,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: Keyboardtype==null?TextInputType.name:Keyboardtype,
        controller: controller,
        validator: validate,
        obscureText: isPassword==false?false:isPassword,
        decoration: InputDecoration(
          prefixIcon: prefix,
          suffixIcon: suffix,
          labelText: hintText??"hint text..",
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color:  const Color.fromARGB(255, 135, 30, 233),
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Color.fromARGB(255, 212, 56, 188)
            
          )),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: const Color.fromARGB(255, 163, 59, 255),
            )
            ),
            errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Colors.red,
            )
            ),
            
          ),
          
        
    );
  }
}