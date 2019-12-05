import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:core';
import 'package:flash_chat/progress.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'chat_screen.dart';
import 'package:flash_chat/provider/auth.dart';
import 'package:flash_chat/models/user.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';


final usersRef = Firestore.instance.collection('users');
QuerySnapshot qs;
bool boolGetQSDocuments = false;
bool boolGetPhoneNumber = false;
String loggedInUserPhoneNumber;

class ContactsScreen extends StatefulWidget {
  static const id = 'contacts_screen';

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  String _numberOfContacts = '';
  static Iterable<Contact> _contacts;
  bool _iteratorHasData = false;
  String _newTempNumber = '';
  int counter = 0;
 

 setLoggedInUserPhoneNumber() async{
   boolGetPhoneNumber = false;
   final prefs = await SharedPreferences.getInstance();
   loggedInUserPhoneNumber = prefs.getString("loggedInUserPhoneNumber");
   setState(() {
     boolGetPhoneNumber = true;
   });
   
}

  fetchContacts() async{
    Iterable<Contact> cnt = await ContactsService.getContacts(withThumbnails: false);
    _newTempNumber = '${cnt.length.toString()} contacts';
  }


fetchUsersRef() async{
    boolGetQSDocuments = false;  
    qs =  await usersRef.getDocuments();
    setState(() {
      boolGetQSDocuments = true;
    });
    
  }

  @override
  void initState() {
    setLoggedInUserPhoneNumber();
    fetchUsersRef();
    super.initState(); 

  }




  Widget handleContacts(BuildContext context){
    return FutureBuilder(
      future: ContactsService.getContacts(withThumbnails: false),
      builder: (BuildContext context, AsyncSnapshot snapshot){
           switch(snapshot.connectionState){
             case ConnectionState.waiting :
               return shimmerEffect();  
             default:
               if(boolGetQSDocuments == false || boolGetPhoneNumber == false)
                 return Center(child: shimmerEffect());
               else if(snapshot.hasError)
                 return Text('Error ${snapshot.error}');
               else
                 return createListView(context, snapshot);
           }
      }
    ); 
  }

bool displayContact = false;
// User user = Provider.of<Auth>(context, listen: false).presentUser;

onContactTap(BuildContext context,String name, String receiverUserID, String receiverPhoneNumber, String downloadUrl, String bio){  
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ChatScreen(receiverName: name, receiverUserID: receiverUserID, receiverPhoneNumber: receiverPhoneNumber, imageDownloadUrl: downloadUrl, receiverBio: bio,)));
}

  Widget createListView(BuildContext context, AsyncSnapshot snapshot){
    counter = 0;
    _contacts = snapshot.data;
    List<Contact> contactsList = _contacts.toList(); 
      
       return ListView.builder(
      itemCount: contactsList.length,
        itemBuilder: (BuildContext context, int index){
        String downloadUrl = 'd';  
        String bio = 'b';
        Map<String,String> getUserIDs = {'randomName' : 'we23e232'};
        Map<String,String> getUserPhoneNumbers = {'few' : 'wewe'};
        String phoneNumberAtIndex = (contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value;
        this.displayContact = false;
        var listOfDocuments = qs.documents;
    listOfDocuments?.forEach((doc){
     if((doc["phoneNumber"] == phoneNumberAtIndex.split(" ").join("") && doc["phoneNumber"] != loggedInUserPhoneNumber.split(" ").join("")) 
       ||  (doc["phoneNumber"].substring(3) == phoneNumberAtIndex.split(" ").join("") && doc["phoneNumber"].substring(3) != loggedInUserPhoneNumber.split(" ").join("")))
     {
       this.displayContact = true;
       getUserIDs[contactsList[index].displayName] = doc["id"]; 
       getUserPhoneNumbers[contactsList[index].displayName] = doc['phoneNumber'];
       downloadUrl = doc['imageDownloadUrl'];
       bio = doc['bio'];
     }
     counter++;
    });
        
        if(displayContact==true){
         return GestureDetector(
           onTap: () => onContactTap(context, contactsList[index].displayName, getUserIDs[contactsList[index].displayName], getUserPhoneNumbers[contactsList[index].displayName], downloadUrl, bio),
            child: ListTile(
            leading: (downloadUrl==null) ? CircleAvatar(radius: 21, child: Image.asset('images/blah.png'),) : CircleAvatar( backgroundColor: Colors.transparent ,radius: 21, child: ClipOval(
  child: FadeInImage.assetNetwork(
            fadeInDuration: Duration(milliseconds: 150),
            fadeOutDuration: Duration(milliseconds: 150),
            placeholder: 'gifs/ld9.gif',
            image: downloadUrl,
            fit: BoxFit.fill,
          ),
),) ,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(contactsList[index].displayName, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500),),
                Text((contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value.split(" ").join("")),
     
              ],
            ),
        ),
         );
        }else{
          return Container();
        }
        },);
  }


  onContactsRefresh(BuildContext context){
    
    setState(() {
      _iteratorHasData = true;
    });
    setState(() {
      _numberOfContacts = _newTempNumber;
    });
  }

//  Widget alreadyRenderedListOfContacts(BuildContext context){
//    List<Contact> contactsList = contacts.toList();
//    return ListView.builder(
//      itemCount: contactsList.length,
//      itemBuilder: (BuildContext context, int index){
//        return ListTile(
//          leading: CircleAvatar(child: Image.asset('images/logo.png'),),
//          title: Column(
//            children: <Widget>[
//              Text(contactsList[index].displayName),
//            ],
//          ),
//        );
//      },);
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Select contact', textAlign: TextAlign.center,),
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
        child: (boolGetQSDocuments == false || boolGetPhoneNumber == false) ? Center(child: shimmerEffect()) : handleContacts(context),
      ),
    );
  }
}


// Column emptyContacts(BuildContext context){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: <Widget>[
//       SizedBox(
//         height: MediaQuery.of(context).size.height*0.07,
//       ),
//       Text('So lonely!', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),),
//       SizedBox(
//         height: MediaQuery.of(context).size.height*0.05,
//       ),
//       Image.asset('images/empty.png'),
//       SizedBox(
//         height: MediaQuery.of(context).size.height*0.04,
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 25),
//           child: Text("Looks like this is your first time using the app. Press the '⟳' button to update your contacts list",
//             textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w400,
//           ),),),
//     ],
//   );
// }
