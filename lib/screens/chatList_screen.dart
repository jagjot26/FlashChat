import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as prefix0;
import 'package:flash_chat/progress.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'contacts_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/provider/auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flash_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flash_chat/Drawer screens/profile_edit.dart';
import 'package:flash_chat/Drawer screens/privacypolicy.dart';
import 'package:flash_chat/Drawer screens/about.dart';
import 'package:flash_chat/Drawer screens/reach_us.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String loggedInUserID;
User loggedInUser;
final DateTime timestamp = DateTime.now();
final activeUsersRef = Firestore.instance.collection('activeUsers');
bool gotAsyncInfo = false;
bool gotContactsInfo = false;
bool isUserNameActuallyNumber;
 Iterable<Contact> contacts = [];
 List<Contact> contactsList = [];
 String phoneNumberAtIndex;
 String userName;
 bool getSharedPrefInfo = false;




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



FirebaseMessaging firemessage = prefix0.FirebaseMessaging();
String loggedInUserPhoneNumber;
String loggedInUserImgUrl;
bool getLoggedInUserIDBool= false;
String loggedInUserName;
String loggedInUserBio;

setLoggedInUserInfo() async{
//   String firstTime = prefs.getString("firstTime");

// if(firstTime == "no"){
//     Fluttertoast.showToast(msg: "Welcome to FlashChat! If you had any old chats, they will be restored on the next app launch",  textColor: Colors.white, backgroundColor: Colors.black54);
//     prefs.setString("firstTime", "yes");
//   }
   final prefs = await SharedPreferences.getInstance();
   loggedInUserPhoneNumber = prefs.getString("loggedInUserPhoneNumber");
   loggedInUserImgUrl = prefs.getString("loggedInUserImage");
   loggedInUserName = prefs.getString("loggedInUserName");
   loggedInUserBio = prefs.getString("loggedInUserBio");
   loggedInUserID = prefs.getString("uid");
   setState(() {
      getSharedPrefInfo = true;
     gotAsyncInfo = true;
   });  
   
}


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

firebaseMessageConfigure(){
firemessage.configure(
     onLaunch: (Map<String,dynamic> msg) async{
       print("On Launch called");
     },
     onResume: (Map<String,dynamic> msg) async{
       print("On Resume called");
     },
     onMessage: (Map<String,dynamic> msg) async{
       print("On Message called");
     },
   );
}
String loggedInUid;
updateLastSeen() async{
  
if(loggedInUserID==null){
  final prefs = await SharedPreferences.getInstance();
  loggedInUserID = prefs.getString("uid");
}
if(loggedInUserID!=null){
Firestore.instance.collection('users').document(loggedInUserID).updateData({"lastSeen": DateTime.now()});
}
}

recurringFunction(){
  const oneSec = const Duration(seconds:7);
  new Timer.periodic(oneSec, (Timer t) => updateLastSeen());
  
}


@override
  void initState() {
    super.initState();
    setLoggedInUserInfo();
    getContacts();
   firebaseMessageConfigure();
   recurringFunction();
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
  accountName: loggedInUserName==null ? Text(" ") :Text(loggedInUserName),
  decoration: BoxDecoration(
    color: Theme.of(context).accentColor,
  ),
  accountEmail: loggedInUserPhoneNumber==null ? Text(" ") : Text(loggedInUserPhoneNumber),
  currentAccountPicture: (isImageDownloading == true) 
  ? CircleAvatar(
   backgroundColor: Theme.of(context).accentColor,
   radius: 23,
   child: ClipOval(
    child: CachedNetworkImage(
        fadeInCurve: Curves.easeIn,
        fadeOutCurve: Curves.easeOut,
        imageUrl: newDownloadUrl,
        placeholder: (context, url) => spinkit(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 )
  : (loggedInUserImgUrl == 'NoImage' || loggedInUserImgUrl == null) 
  ? CircleAvatar(child: Image.asset('images/blah.png'), radius:23) 
  : CircleAvatar(
   backgroundColor: Theme.of(context).accentColor,
   radius: 23,
   child: ClipOval(
    child: CachedNetworkImage(
        fadeInCurve: Curves.easeIn,
        fadeOutCurve: Curves.easeOut,
        imageUrl: this.loggedInUserImgUrl,
        placeholder: (context, url) => spinkit(),
        errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ),   
    ),
        ListTile(
      leading: Icon(Icons.person,color: Colors.blueGrey),
      title: Text('Edit Profile'),
      onTap: (){
       if(newBioUpdated == true){
           Navigator.of(context).pop();
           Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileEdit(profileImageUrl: loggedInUserImgUrl, userName: loggedInUserName, about: newBio, phoneNumber: loggedInUserPhoneNumber,)));
       }else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileEdit(profileImageUrl: loggedInUserImgUrl, userName: loggedInUserName, about: loggedInUserBio, phoneNumber: loggedInUserPhoneNumber,)));
        
      }
      },
        ),
        ListTile(
      leading: Icon(Icons.contacts, color: Colors.blueGrey),
      title: Text('Contacts'),
      onTap: (){
        Navigator.of(context).pop();
        handleContactsButton(context);
      },
        ),
        ListTile(
      leading: Icon(Icons.insert_drive_file, color: Colors.blueGrey),
      title: Text('Privacy Policy'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyPolicy()));
      },
        ),
        ListTile(
      leading: Icon(Icons.people, color: Colors.blueGrey,),
      title: Text('Reach Us'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ReachUs()));
      },
        ),
        ListTile(
      leading: Icon(Icons.info, color: Colors.blueGrey,),
      title: Text('About'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutPage()));
      },
        ),
        ],
      ),
        ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text('FlashChat'),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.038),
          child: GestureDetector(
            child: Icon(Icons.search,color: Colors.white,),
            onTap: (){
              print(contactedUserNames);
              // print(userInfoForSearch[contactedUserNames[0]][1]);
              showSearch(context: context, delegate: SearchUsers());
            },
            ),
        ),
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleContactsButton(context),
        backgroundColor: Theme.of(context).accentColor,
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

openChatScreen(String name, String phoneNumber, String userID, BuildContext context, String downloadUrl, String bio, String token){
Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(receiverName: name, receiverPhoneNumber: phoneNumber, receiverUserID: userID, imageDownloadUrl: downloadUrl, receiverBio: bio, receiverToken: token,)));
}

openChatScreenFromSearch(String name, String phoneNumber, String userID, BuildContext context, String downloadUrl, String bio, String token){
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatScreen(receiverName: name, receiverPhoneNumber: phoneNumber, receiverUserID: userID, imageDownloadUrl: downloadUrl, receiverBio: bio, receiverToken: token,)));
}

String downloadUrlFinal;
String bioOfUser;
String receiverToken;
class MessagedContactsWidget extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final String userID;
  final String downloadUrl;
  final String mostRecentMessage;
  final String bio;
  final String token;

  MessagedContactsWidget({this.contactName = 'defaultName', this.phoneNumber, this.userID, this.downloadUrl, this.mostRecentMessage, this.bio, this.token});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: ()=> openChatScreen(contactName, phoneNumber, userID, context, this.downloadUrl, this.bio, this.token),
          child: Column(
        children: <Widget>[
          ListTile(
            leading: (this.downloadUrl == 'NoImage' || this.downloadUrl == null) 
            ? CircleAvatar(child: Image.asset('images/blah.png'), radius: 23,)
             :   CircleAvatar(
   backgroundColor: Theme.of(context).accentColor,
   radius: 23,
   child: ClipOval(
    child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: this.downloadUrl,
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ),   

                      title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[  
                (contactName == 'defaultName') ? Text(phoneNumber, style: TextStyle(fontSize: 20), textAlign: TextAlign.start,) : Text(contactName, style: TextStyle(fontSize: 20),),
                SizedBox(
                  height: 3,
                ),
                Text(mostRecentMessage, 
                     style: TextStyle(fontSize: 15, color: Colors.black54,),
                     textAlign: TextAlign.start,
                     ),
              ],
            ),
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

final contactedUserNames = [];
Map<String,List<String>> userInfoForSearch = {};
int counter=0;
class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: activeUsersRef.document(loggedInUserID).collection('messagedUsers').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot){

        if(!snapshot.hasData || gotAsyncInfo == false || gotContactsInfo == false || getSharedPrefInfo == false){
          return Container();
        }
           
           return StreamBuilder(
             stream: Firestore.instance.collection('users').snapshots(),
             builder: (context, snapshot2){
               if(!snapshot2.hasData || gotAsyncInfo == false || gotContactsInfo == false || getSharedPrefInfo == false){
              return Container(
                color: Colors.transparent,
              );
                }

               final messagedUsers = snapshot.data.documents;
        List<MessagedContactsWidget> listOfMessagedContactsWidget = [];
          for(var users in messagedUsers){
          final String userPhoneNumber = users.data['phoneNumber'];
          var listOfDocuments = snapshot2.data.documents;
              for(var dc in listOfDocuments){
             if(dc["phoneNumber"]==userPhoneNumber)
               {
               downloadUrlFinal = dc["imageDownloadUrl"];  
               bioOfUser = dc["bio"];
               receiverToken = dc['token'];
               }     
              }
          final String receiverID = users.data['receiverID'];
          
          String mostRecentText = users.data['mostRecentMessage'];
          if(mostRecentText.length>42){
            mostRecentText = mostRecentText.substring(0,42);
          }
          for(int index = 0; index < contactsList.length; index++){
            phoneNumberAtIndex = (contactsList[index].phones.isEmpty) ? ' ' : contactsList[index].phones.firstWhere((anElement) => anElement.value != null).value;
            String trimmedPhoneNumber = phoneNumberAtIndex.split(" ").join("");
            trimmedPhoneNumber = trimmedPhoneNumber.split("-").join("");
            if(userPhoneNumber == trimmedPhoneNumber || userPhoneNumber.substring(3) == trimmedPhoneNumber){
              userName = contactsList[index].displayName;
               if(contactedUserNames.length!=0){
                 counter = 0;
                for(int i=0;i<contactedUserNames.length;i++){
                 if(contactedUserNames[i]==userName){
                   counter++;
                  break;
                 }               
                }
                if(counter==0){
                 contactedUserNames.add(userName);
                 userInfoForSearch[userName] = [trimmedPhoneNumber.toString(), downloadUrlFinal, receiverID, mostRecentText, bioOfUser, receiverToken];
                }
             }
             else{
              contactedUserNames.add(userName);
              userInfoForSearch[userName] = [trimmedPhoneNumber.toString(), downloadUrlFinal, receiverID, mostRecentText, bioOfUser, receiverToken];
             }
              break;
            }
            else{
              userName = userPhoneNumber;
            }
          }
          
        isUserNameActuallyNumber = isNumeric(userName);
           var messagedContact;
         if(isUserNameActuallyNumber == true){
            messagedContact = MessagedContactsWidget(phoneNumber: userPhoneNumber, userID: receiverID, downloadUrl: downloadUrlFinal,mostRecentMessage: mostRecentText, bio: bioOfUser, token: receiverToken,);
         }
         else{
            messagedContact = MessagedContactsWidget(contactName: userName, phoneNumber: userPhoneNumber, userID: receiverID, downloadUrl: downloadUrlFinal, mostRecentMessage: mostRecentText, bio: bioOfUser, token: receiverToken,);
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
        
        
        
      },      

    );
  }
}


class SearchUsers extends SearchDelegate<String>{
  @override
 List<Widget> buildActions(BuildContext context){
   return [IconButton(
     icon: Icon(Icons.clear),
     onPressed: (){query = "";},
     )];
 }

 @override
 Widget buildLeading(BuildContext context){
   return IconButton(
     icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation,),
     onPressed: (){
       close(context, null);
     },
   );
 }

 @override 
 Widget buildResults(BuildContext context){
   return null;
 }

 @override 
 Widget buildSuggestions(BuildContext context){
    if(query.isEmpty){
   return Container(
     alignment: Alignment.topCenter,
     padding: EdgeInsets.symmetric(vertical: 50, horizontal: 60),
     child: Text('Start typing a name to continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),),
     );
    }
  else{
    
   final suggestionsList = contactedUserNames.where((p) => (p.toLowerCase()).startsWith(query.toLowerCase())).toList();

   return ListView.builder(
     itemCount: suggestionsList.length,
     itemBuilder: (context,index) => ListTile(
       onTap: ()=> openChatScreenFromSearch(suggestionsList[index], userInfoForSearch[suggestionsList[index]][0], userInfoForSearch[suggestionsList[index]][2], context, userInfoForSearch[suggestionsList[index]][1], userInfoForSearch[suggestionsList[index]][4], userInfoForSearch[suggestionsList[index]][5])  ,
       leading: (userInfoForSearch[suggestionsList[index]][1] == 'NoImage' || userInfoForSearch[suggestionsList[index]][1]==null)
        ? CircleAvatar(child: Image.asset('images/blah.png'), radius: 23,)
        :  CircleAvatar(
   backgroundColor: Theme.of(context).primaryColor,
   radius: 23,
   child: ClipOval(
    child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: userInfoForSearch[suggestionsList[index]][1],
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ),   
       title: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[
           RichText(
             text: TextSpan(
               text: suggestionsList[index].substring(0,query.length),
               style: TextStyle(
                 color: Colors.black, fontWeight: FontWeight.bold,
                 fontSize: 20,
                 ),
                 children: [
                   TextSpan(
                    text: suggestionsList[index].substring(query.length),
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                   ),
                 ]),  
           ),
           SizedBox(
             height: 3,
           ),
           Text(userInfoForSearch[suggestionsList[index]][3], 
                     style: TextStyle(fontSize: 15, color: Colors.black54,),
                     textAlign: TextAlign.start,
                     ),
         ],
       ),
     ),
   );
   
  }
 }
}
        

          
// CircleAvatar( backgroundColor: Colors.transparent ,radius: 23, child: ClipOval(
//   child: FadeInImage.assetNetwork(
//               fadeInDuration: Duration(milliseconds: 200),
//               fadeOutDuration: Duration(milliseconds: 200),
//               placeholder: 'gifs/ld9.gif',
//               image: this.downloadUrl,
//               fit: BoxFit.fill,
//             ),
// ),
// ),
   
//  CircleAvatar(
//    backgroundColor: Colors.transparent,
//    radius: 23,
//    child: ClipOval(
//     child: CachedNetworkImage(
//       fadeInCurve: Curves.easeIn,
//       fadeOutCurve: Curves.easeOut,
//       imageUrl: this.downloadUrl,
//       placeholder: spinkit(context, d),
//       errorWidget: new Icon(Icons.error),
//     ),
//    ),
//  ),   






