// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:women_safety/child/bottom_screens/contacts_page.dart';
import 'package:women_safety/components/primaryButton.dart';
import 'package:women_safety/db/db_services.dart';
import 'package:women_safety/model/contactsm.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  DatabaseHelper databaseHelper= DatabaseHelper();
  List<Tcontact>? contactList;
  int count=0;
  void showList(){
      Future<Database> dbFuture=databaseHelper.initializeDatabase();
      dbFuture.then((database){
      Future<List<Tcontact>> contactListFuture=  databaseHelper.getContactList();
        contactListFuture.then((value){
          setState(() {
            this.contactList=value;
            this.count=value.length;
          });
        });
      });
  }

  void deleteContact(Tcontact contact)async{
    int result= await databaseHelper.deleteContact(contact.id);
    if (result!=0) {
      Fluttertoast.showToast(msg: "Contact removed Succesfully");
      showList();
    }
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
    showList();

    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    if (contactList==null) {
      contactList=[];
    }
    return SafeArea(
      child: Container(
      padding: EdgeInsets.all(12),
        child: Column(
          children: [
            primaryButton(onPressed: ()async{
              bool result= await Navigator.push(context,
               MaterialPageRoute(builder: (context)=>ContactsPage(),
               ));
               if (result==true) {
                 showList();
               }
            }, title: 'Add trusted contacts'),
            Expanded(
              child: ListView.builder(
                // shrinkWrap: true,
                itemCount: count,
                itemBuilder: (BuildContext context,int index){
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(contactList![index].name),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [IconButton(onPressed: ()async{
                                await FlutterPhoneDirectCaller.callNumber(contactList![index].number);
                              },icon: Icon(Icons.call),
                              color: Colors.red,),
                              IconButton(onPressed: (){
                                deleteContact(contactList![index]);
                              },icon: Icon(Icons.delete),
                              color: Colors.red,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}