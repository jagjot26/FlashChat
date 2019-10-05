import 'package:flash_chat/progress.dart';
import 'package:flash_chat/screens/chatList_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flash_chat/provider/auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';
import 'dart:math';

String loggedInUserID;
String loggedInUserPhoneNumber;
User loggedInUser;
String receivUserID;
DateTime timestamp;
final activeUsersRef = Firestore.instance.collection('activeUsers');
final indexRef = Firestore.instance.collection('index');
int indexFirestore;
bool boolGetPhoneNumber = false;
bool boolGetLoggedInUserID = false;


class ChatScreen extends StatefulWidget {
final String receiverName;
final receiverUserID;
final String receiverPhoneNumber;

ChatScreen({this.receiverName, this.receiverUserID, this.receiverPhoneNumber});


  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final tcontroller = TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
bool isTextFieldEmpty = true;
String message;




setLoggedInUserPhoneNumber() async{
   boolGetPhoneNumber = false;
   final prefs = await SharedPreferences.getInstance();
   loggedInUserPhoneNumber = prefs.getString("loggedInUserPhoneNumber");
   setState(() {
     boolGetPhoneNumber = true;
   });
   
}

setLoggedInUserID() async{ 
  boolGetLoggedInUserID = false;
  receivUserID = widget.receiverUserID;
 await Future.delayed(Duration.zero, (){
   loggedInUserID = Provider.of<Auth>(context, listen: false).uidSharedPref;
 });
 setState(() {
   boolGetLoggedInUserID = true;
 });
 
}



@override
  void initState() {
   
    setLoggedInUserPhoneNumber();
    setLoggedInUserID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.5),
          child: CircleAvatar(child: Image.asset('images/blah.png'),),
        ),
        title: (widget.receiverName == 'defaultName') ? Text(widget.receiverPhoneNumber, textAlign: TextAlign.left) : Text(widget.receiverName, textAlign: TextAlign.left),
        actions: <Widget>[
          Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.038),
          child: Icon(Icons.more_vert,color: Colors.white,),
        ),
        ],
      ),
    body: Column(
        children: <Widget>[
         (boolGetLoggedInUserID == true && boolGetPhoneNumber == true ) ? Expanded(child: MessagesStream()) : Expanded(child: circularProgress()),
         Container(
           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
           child: Row(
             children: <Widget>[
                  Expanded(
                      child: TextField(
                      onChanged: (val){
                        setState(() {
                          message = val;
                          if(val.length==0){
                            isTextFieldEmpty = true;
                          }
                           if(val.length>0){
                              isTextFieldEmpty = false; 
                           }                       
                                                  
                        });
                      },
                      controller: tcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        hintText: 'Type your message',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(32),),),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32),),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32),),                       
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.0090,
                  ),
                  RawMaterialButton(
                            onPressed: () {
                              timestamp =  DateTime.now();
                            // indexFirestore += 1;  
                            if(tcontroller.text.length>0){
                              setState(() {
                                 tcontroller.clear();
                                 isTextFieldEmpty = true;
                              });                             
                              var data = {
                                'timestamp' : formatDate(timestamp, [HH, ':', nn, ':', ss, ' ', am]).toString(),
                                'receiverID' : widget.receiverUserID,
                                'phoneNumber' : widget.receiverPhoneNumber
                              };

                              var data2 = {
                                'timestamp' : formatDate(timestamp, [HH, ':', nn, ':', ss, ' ', am]).toString(),
                                'receiverID' : loggedInUserID,
                                'phoneNumber' : loggedInUserPhoneNumber,
                                 
                              };
                             
                             var messageData = {
                               'timestamp' : formatDate(timestamp, [HH, ':', nn, ' ', am]).toString(),
                               'senderID' : loggedInUserID,
                               'message' : message,
                               'exactTime' : timestamp,
                              //  'index' : indexFirestore
                             };

                            //  var indexData = {
                            //    'index' : indexFirestore
                            //  };
                              
                              activeUsersRef.document(loggedInUserID).collection('messagedUsers').document(widget.receiverUserID).setData(data);
                              activeUsersRef.document(widget.receiverUserID).collection('messagedUsers').document(loggedInUserID).setData(data2);
                              activeUsersRef.document(loggedInUserID).collection('messagedUsers').document(widget.receiverUserID).collection('messages').add(messageData);
                              activeUsersRef.document(widget.receiverUserID).collection('messagedUsers').document(loggedInUserID).collection('messages').add(messageData);
                                    


                            }  
                            
                            },
                            //RawMaterialButton widget class is used for building buttons from scratch
                            child: Icon(
                              Icons.send,
                              color: (isTextFieldEmpty == false) ? Colors.blueAccent : Colors.grey,
                            ), //Icon widget requires an either Icons.someicon or FontAwesomeIcons.someicon value
                            constraints:
                            BoxConstraints.tightFor(width: 43.5, height: 43.5),
                            shape: CircleBorder(),
                            fillColor: Colors.black,
                            elevation: 0.0,
                          ),
                ],
           ),
         ),
        ],
      ), 
       );
  }
}

// SafeArea(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
            
//             Row(
//               children: <Widget>[
//                 TextField(
//                   decoration: InputDecoration(
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.blueAccent, width: 2.3),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.blueAccent,width: 2.3),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: null,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),


// class MessagesStream extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: ,
//       builder: (context, snapshot){
//         if(!snapshot.hasData){
//           return circularProgress();
//         }
//         else{

//         }
//       },
//     );
//   }
// }


class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: activeUsersRef.document(loggedInUserID).collection('messagedUsers').document(receivUserID).collection('messages').orderBy('exactTime', descending: true).snapshots(),
      builder: (context, snapshot) {
        //this snapshot is different from the snapShot variable we used above
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final messages = snapshot.data.documents;
        //gives u a list of map of messages which are reversed
        List<MessageBubble> messageBubbles = []; //list of Text widgets
        for (var message in messages) {
          final messageText = message.data[
              'message']; //getting text value from the map by using 'text' key
          final messageSenderID = message.data[
              'senderID']; //getting sender value from the map by using 'sender' key
          final String timestamp = message.data['timestamp'];
          final messageBubble = MessageBubble(
            senderID: messageSenderID,
            message: messageText,
            isMe: messageSenderID == loggedInUserID ? true : false,
            timestamp: timestamp,
          );
          messageBubbles.add(messageBubble); //adds the Text widget to the list

        }
        return ListView(
          reverse: true, //bottom of the listView will always be visible
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: messageBubbles,
        );
        //used a semi-colon here because we're in a method(i.e builder of StreamBuilder)
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderID;
  final bool isMe;
  final String timestamp;
  MessageBubble({this.message, this.senderID, this.isMe, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
             Material(
            elevation: 6,
            borderRadius: isMe == true
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe == true ? Colors.cyan[400] : Colors.purpleAccent[200],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: 
                  Text(
                    //assigning a newly made Text widget to the messageWidget
                    '$message   $timestamp',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}