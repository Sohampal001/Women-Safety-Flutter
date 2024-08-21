import 'package:flutter/material.dart';

class safehome extends StatelessWidget {
  const safehome({super.key});
  showModelsafeHome(BuildContext context){
    showModalBottomSheet(context: context, 
    builder:(context){
      return Container(
        height: MediaQuery.of(context).size.height/1.4,
        // color: Color.fromARGB(255, 220, 63, 237),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 148, 176, 218),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30)
          )
        ),
        );
    },
    
    );
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelsafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width*0.7,
          decoration: BoxDecoration(
      
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(children: [
                ListTile(
                  title: Text('Send Location'),
                  subtitle: Text("share Location"),
                )
              ],)),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/images/location.png"))
            ],),
        ),
      ),
    );
  }
}