import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:core';
import 'package:flash_chat/progress.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';



final usersRef = Firestore.instance.collection('users');
bool initialBool = false;
bool refreshBool = false;
bool boolIsLoading = false;
QuerySnapshot snapshot;
Iterable<Contact> contactIterable;

class TempScreen extends StatefulWidget {
  @override
  _TempScreenState createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {


  fetchContacts() async{
contactIterable =  await ContactsService.getContacts(withThumbnails: false);
  }
  fetchUsersRef() async{
    snapshot =  await usersRef.getDocuments();
  }

onContactsRefresh(BuildContext context){
  setState(() {
   initialBool = true; 
   boolIsLoading = true;
  });
  futuresHandlerMethod(context);
}

Widget futuresHandlerMethod(BuildContext context){

//  QuerySnapshot snapshot =  await usersRef.getDocuments();
//  Iterable<Contact> contactIterable =  await ContactsService.getContacts(withThumbnails: false);
  List<Contact> contactsList = contactIterable.toList(); 

    setState(() {
    boolIsLoading = false;
 });
 return ListView.builder(
      itemCount: contactsList.length,
        itemBuilder: (BuildContext context, int index){
     
        String phoneNumberAtIndex = (contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value;
        
    //     var list = querySnapshot.documents;
    // list.forEach((doc){
    //  if(doc["phoneNumber"] == phoneNumberAtIndex){this.displayContact = true;}
    // });
        
        return ListTile(
          leading: CircleAvatar(child: Image.asset('images/blah.png'),),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(contactsList[index].displayName, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500),),
              Text((contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value),
            ],
          ),
        );
        },);
        


}


@override
  void initState() {
    fetchContacts();
    fetchUsersRef();
    super.initState();

  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Select contact', textAlign: TextAlign.left,),
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: ()=> onContactsRefresh(context),
            child: Padding(
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.038),
              child: Icon(Icons.refresh,color: Colors.white,),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: (initialBool == false) ? emptyContacts(context) : (boolIsLoading == true) ? circularProgress() : futuresHandlerMethod(context) ,
      ),
    );
  }
}

Column emptyContacts(BuildContext context){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(
        height: MediaQuery.of(context).size.height*0.07,
      ),
      Text('So lonely!', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),),
      SizedBox(
        height: MediaQuery.of(context).size.height*0.05,
      ),
      Image.asset('images/empty.png'),
      SizedBox(
        height: MediaQuery.of(context).size.height*0.04,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
          child: Text("Looks like this is your first time using the app. Press the '⟳' button to update your contacts list",
            textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),),),
    ],
  );
}
