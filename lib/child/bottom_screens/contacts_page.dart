import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety/db/db_services.dart';
import 'package:women_safety/model/contactsm.dart';
import 'package:women_safety/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts=[];
  List<Contact> contactsFiltered=[];
  DatabaseHelper _databaseHelper=DatabaseHelper();
  TextEditingController searchController=TextEditingController();
  @override
  void initState(){
    super.initState();
    askPermission();
  }
  String flatternPhoneNumber(String phonestr){
    return phonestr.replaceAllMapped(RegExp(r'^(\+)|\D'),(Match m){
        return m[0]=="+" ? "+" : "";
    });
  }

  filterContact() {
  List<Contact> _contacts = [];
  _contacts.addAll(contacts);
  if (searchController.text.isNotEmpty) {
    _contacts.retainWhere((element) {
      String searchTerm = searchController.text.toLowerCase();
      String searchTermFlattren = flatternPhoneNumber(searchTerm);
      String contactName = element.displayName?.toLowerCase() ?? '';
      bool nameMatch = contactName.contains(searchTerm);

      if (nameMatch) {
        return true;
      }

      if (searchTermFlattren.isEmpty) {
        return false;
      }

      if (element.phones != null && element.phones!.isNotEmpty) {
        var phone = element.phones!.firstWhere(
          (p) {
            String phnFlattered = flatternPhoneNumber(p.value ?? '');
            return phnFlattered.contains(searchTermFlattren);
          },
          orElse: () => Item(label: '', value: null),
        );
        return phone.value != null;
      }

      return false;
    });
  }
  setState(() {
    contactsFiltered = _contacts;
  });
}


  Future<void> askPermission()async{
    PermissionStatus permissionStatus=await getContactsPermissions();
    if (permissionStatus==PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener((){
        filterContact();
      });
    } else {
      handInvalidpermissions(permissionStatus);
    }
  }

  handInvalidpermissions(PermissionStatus permissionStatus){
    if (permissionStatus==PermissionStatus.denied) {
      dialogBox(context, 'Access to the contacts denied by the user');
    } else if (permissionStatus==PermissionStatus.permanentlyDenied){
      dialogBox(context, 'May contact doesnot exist in this device');
    }
  }

  Future<PermissionStatus> getContactsPermissions()async{
    PermissionStatus permission =await Permission.contacts.status;
    if (permission!=PermissionStatus.granted && 
    permission!=PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus= await Permission.contacts.request();
      return permissionStatus;
      
    } else {
      return permission;
    }
  }

  getAllContacts()async{
    List<Contact> _contacts=await ContactsService.getContacts(
      withThumbnails:  false
    );
    setState(() {
      contacts=_contacts;
    });

  }

  @override
  Widget build(BuildContext context) {
    bool isSearching=searchController.text.isNotEmpty;
    bool listItemExit=(contactsFiltered.length >0 || contacts.length >0);
    return Scaffold(
      body:contacts.length==0?
      Center(child: CircularProgressIndicator()):
      
       SafeArea(
         child: Column(
           children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "search contact",
                  prefixIcon: Icon(Icons.search)
                ),
              ),
            ),
            listItemExit==true?
             Expanded(
               child: ListView.builder(
                itemCount:isSearching==true?contactsFiltered.length :   contacts.length,
                itemBuilder: (BuildContext context, int index){
                Contact contact=isSearching==true?contactsFiltered[index] :contacts[index];
                return  ListTile(
                    title: Text(contact.displayName ?? 'No Name'),
                    leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                    ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.avatar!),
                    )
                    : CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 115, 176, 246),
                    child: Text(contact.initials() ),
                       ),
                       onTap: (){
                        if (contact.phones!.length>0) {
                          final String phoneNum = contact.phones!.elementAt(0).value!;
                          final String name = contact.displayName!;
                          _addContact(Tcontact(phoneNum, name));

                        } else {
                        Fluttertoast.showToast(msg: "Oops! phone number of this contact doesn't exists");
                          
                        }
                       },
                      );

              // subtitle: Text(contact.phones != null && contact.phones!.isNotEmpty
                //      ? contact.phones!.first.value ?? 'No Number'
                //      : 'No Number'),
               
                     },),
             ):Container(
              child: Text("Searching"),
             )
           ],
         ),
       )
    );
  }
  void _addContact(Tcontact newContact) async{
    int result =  await _databaseHelper.insertContact(newContact);
    if (result!=0) {
      Fluttertoast.showToast(msg: 'Contact Added Successfully');
    }
    else{
      Fluttertoast.showToast(msg: 'failed to add contact');

    }
    Navigator.of(context).pop(true);
  }
}