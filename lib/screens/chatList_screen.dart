import 'dart:core';
import 'package:flash_chat/progress.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'contacts_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/provider/auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flash_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';

String loggedInUserID;
User loggedInUser;
final DateTime timestamp = DateTime.now();
final activeUsersRef = Firestore.instance.collection('activeUsers');
bool gotAsyncInfo = false;
bool gotContactsInfo = false;
bool isUserNameActuallyNumber;
 Iterable<Contact> contacts;
 List<Contact> contactsList;
 String phoneNumberAtIndex;
 String userName;




bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

class ChatListScreen extends StatefulWidget {
  static const id = 'chatScreen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {




  handleContactsButton(BuildContext context) async {
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(permissionStatus.toString() == 'PermissionStatus.granted'){
      Navigator.pushNamed(context, ContactsScreen.id);
    }
    else{
      await PermissionHandler().requestPermissions([PermissionGroup.contacts]); //ask for permission
      Navigator.pushNamed(context, ContactsScreen.id);
    }

  }

void setLoggedInUserID() async{
// final prefs = await SharedPreferences.getInstance();
//     loggedInUserID = prefs.getString("uid");

 await Future.delayed(Duration.zero, (){
   loggedInUserID = Provider.of<Auth>(context, listen: false).uidSharedPref;
 });
 
 setState(() {
   gotAsyncInfo = true;
 });
}

getContacts() async{
PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(permissionStatus.toString() != 'PermissionStatus.granted'){
       await PermissionHandler().requestPermissions([PermissionGroup.contacts]); //ask for permission   
    }
  
   contacts = await ContactsService.getContacts(withThumbnails: false);
   contactsList = contacts.toList(); 
   setState(() {
   gotContactsInfo = true;
 });
}


@override
  void initState() {
    super.initState();
    getContacts();
   setLoggedInUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('FlashChat'),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.038),
          child: Icon(Icons.search,color: Colors.white,),
        ),
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleContactsButton(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.message),
      ),
     body: (gotAsyncInfo == true && gotContactsInfo == true) ? Column(
       children: <Widget>[
         ChatList(),
       ],
     ) : Container(),
    );
  }
}

openChatScreen(String name, String phoneNumber, String userID, BuildContext context){
Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(receiverName: name, receiverPhoneNumber: phoneNumber, receiverUserID: userID)));
}

class MessagedContactsWidget extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final String userID;

  MessagedContactsWidget({this.contactName = 'defaultName', this.phoneNumber, this.userID});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: ()=> openChatScreen(contactName, phoneNumber, userID, context),
          child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(),
            title: 
            (contactName == 'defaultName') ? Text(phoneNumber, style: TextStyle(fontSize: 20),) : Text(contactName, style: TextStyle(fontSize: 20),),
          ),
          Container(
            width: MediaQuery.of(context).size.width*0.9,
            child: Divider(
              height: 13,
              thickness: 0.4,
              indent: MediaQuery.of(context).size.width*0.14,
            ),
          ),
        ],
      ),
    );
  }
}


class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: activeUsersRef.document(loggedInUserID).collection('messagedUsers').orderBy('timestamp', descending:false).snapshots(),
      builder: (context, snapshot){
        print(loggedInUserID);
        if(!snapshot.hasData){
          return Container();
        }
        
        
        final messagedUsers = snapshot.data.documents;
        List<MessagedContactsWidget> listOfMessagedContactsWidget = [];
          for(var users in messagedUsers){
          final String userPhoneNumber = users.data['phoneNumber'];
          final String receiverID = users.data['receiverID'];
          for(int index = 0; index < contactsList.length; index++){
            phoneNumberAtIndex = (contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value;
            String trimmedPhoneNumber = phoneNumberAtIndex.split(" ").join("");
            if(userPhoneNumber == trimmedPhoneNumber){
              userName = contactsList[index].displayName;
              break;
            }
            else{
              userName = userPhoneNumber;
            }
          }
          
        isUserNameActuallyNumber = isNumeric(userName);
           var messagedContact;
         if(isUserNameActuallyNumber == true){
            messagedContact = MessagedContactsWidget(phoneNumber: userPhoneNumber, userID: receiverID,);
         }
         else{
            messagedContact = MessagedContactsWidget(contactName: userName, phoneNumber: userPhoneNumber, userID: receiverID);
         }

          
     
      listOfMessagedContactsWidget.add(messagedContact);
      }
      
      return Expanded(
              child: SingleChildScrollView(
                child: Column(
          children: listOfMessagedContactsWidget,
        ),
              ),
      );
        
      },      

    );
  }
}