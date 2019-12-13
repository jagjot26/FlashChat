import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/edit_profile.dart';
import 'package:flash_chat/progress.dart';
import 'package:flash_chat/screens/chatList_screen.dart';
import 'package:flash_chat/screens/fullsize_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flash_chat/provider/auth.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';
import 'dart:math';
import 'fullsize_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flash_chat/profileEditForChatScreen.dart';

String loggedInUserID;
String loggedInUserPhoneNumber;
User loggedInUser;
String receivUserID;
DateTime timestamp;
final activeUsersRef = Firestore.instance.collection('activeUsers');

int indexFirestore;
bool boolGetPhoneNumber = false;
bool boolGetLoggedInUserID = false;
String loggedInUserImage;


class ChatScreen extends StatefulWidget {
final String receiverName;
final receiverUserID;
final String receiverPhoneNumber;
final String imageDownloadUrl;
final String receiverBio;
final String receiverToken;
ChatScreen({this.receiverName, this.receiverUserID, this.receiverPhoneNumber, this.imageDownloadUrl, this.receiverBio, this.receiverToken});


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
   loggedInUserImage = prefs.getString("loggedInUserImage");
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


fullScreenImage(BuildContext context){
  if(widget.imageDownloadUrl!=null){
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(downloadUrl: widget.imageDownloadUrl,)));
}
else{
  Scaffold.of(context).showSnackBar(SnackBar(action: SnackBarAction(label: 'OK', onPressed: (){},) ,content: Text("This user hasn't uploaded any profile picture"
  )));
}
  }




@override
  void initState() {
   
    setLoggedInUserPhoneNumber();
    setLoggedInUserID();
    super.initState();
  }

File image;
String downloadUrl;
bool downloadUrlBool = false;
uploadImageAndGetDownloadUrl() async{
  var random = Random.secure();
  var value = random.nextInt(1000000000);
  StorageReference ref = FirebaseStorage.instance.ref().child(value.toString());
  StorageUploadTask uploadTask = ref.putFile(this.image);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  downloadUrl = await taskSnapshot.ref.getDownloadURL();
  setState(() {
   downloadUrlBool = true;
  });
  handleDownloadUrl(downloadUrl);
}

handleSelectImage(BuildContext parentContext){
return showDialog(context: parentContext, builder: (context){
      return SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0),),
        ),
        title: Text('Choose an Image'),
        children: <Widget>[
          SimpleDialogOption(
            child: Text('Photo from Camera'),
            onPressed: handleImageFromCamera,
          ),
          Divider(),
          SimpleDialogOption(
            child: Text('Choose from Gallery'),
            onPressed: handleImageFromGallery,
          ),
          Divider(),
          SimpleDialogOption(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    });
}


  handleImageFromCamera() async{
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
    );

   var result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, croppedFile.path,
        quality: 68,
      );
   
    this.image = result;
    // setState(() {
    //   this.image = image;
    // });
    await uploadImageAndGetDownloadUrl();
  }

  handleImageFromGallery() async{
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
    );

   var result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, croppedFile.path,
        quality: 68,
      );
   
    this.image = result;
      
    await uploadImageAndGetDownloadUrl();
    // setState(() {
    //   this.image = image;
    // });
  }


handleDownloadUrl(String downUrl){
   timestamp =  DateTime.now();
                            // indexFirestore += 1;  
                                                      
                              var data = {
                                'time' : formatDate(timestamp, [HH, ':', nn, ':', ss, ' ', am]).toString(),
                                'receiverID' : widget.receiverUserID,
                                'phoneNumber' : widget.receiverPhoneNumber,
                                'image' : (widget.imageDownloadUrl == null) ? 'NoImage' : widget.imageDownloadUrl,
                                'mostRecentMessage' : 'Image'
                              };

                              var data2 = {
                                'timestamp' : formatDate(timestamp, [HH, ':', nn, ':', ss, ' ', am]).toString(),
                                'receiverID' : loggedInUserID,
                                'phoneNumber' : loggedInUserPhoneNumber,
                                'image' : (loggedInUserImage == null) ? 'NoImage' : loggedInUserImage,
                                'mostRecentMessage' : 'Image'
                                 
                              };
                             
                             var messageData = {
                               'timestamp' : timestamp,
                               'senderID' : loggedInUserID,
                               'message' : downUrl,
                               'exactTime' : timestamp,
                               'type' : 'image',
                               'receiverToken' : widget.receiverToken
                              //  'index' : indexFirestore
                             };

                            //  var indexData = {
                            //    'index' : indexFirestore
                            //  };
                              
                              activeUsersRef.document(loggedInUserID).collection('messagedUsers').document(widget.receiverUserID).setData(data);
                              activeUsersRef.document(widget.receiverUserID).collection('messagedUsers').document(loggedInUserID).setData(data2);
                              activeUsersRef.document(loggedInUserID).collection('messagedUsers').document(widget.receiverUserID).collection('messages').add(messageData);
                              activeUsersRef.document(widget.receiverUserID).collection('messagedUsers').document(loggedInUserID).collection('messages').add(messageData);
                                    


                            
                            
                            downloadUrlBool = false;
                            
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: Builder(
          builder: (BuildContext context){
          return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileEditForChatScreen(profileImageUrl: widget.imageDownloadUrl, userName: widget.receiverName, about: widget.receiverBio, phoneNumber: widget.receiverPhoneNumber,)));
                      },
                      child: AppBar(
                        backgroundColor: Theme.of(context).accentColor,
            leading: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.0086),
              child : (widget.imageDownloadUrl == null) 
              ? CircleAvatar(child: Image.asset('images/blah.png'),) 
              : CircleAvatar(
   backgroundColor: Colors.blue,
   radius: 23,
   child: ClipOval(
    child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: widget.imageDownloadUrl,
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ), 
            ),
            title: (widget.receiverName == 'defaultName') 
            ? Text(widget.receiverPhoneNumber, textAlign: TextAlign.left)
             : Text(widget.receiverName, textAlign: TextAlign.left),
        ),
          );
        }
        ),
      ),
      
      
    body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(

            image: DecorationImage(
                      image: AssetImage('images/blue.jpg'),
                      fit: BoxFit.fill,
                    ),
    //                   gradient: LinearGradient(
    //   begin: Alignment.topCenter,
    //   end: Alignment.bottomCenter, 
    //   colors: [  Color(0xfff08ebf), Color(0xffb3b3ff), Color(0xffb3ecff)], 
    //   tileMode: TileMode.repeated, // repeats the gradient over the canvas
    // ),
                    ),
          width: double.infinity,
          
        ),
        Column(
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
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            hintText: 'Type your message',
                            suffixIcon: GestureDetector(
                              onTap: ()=>handleSelectImage(context),
                              child:Icon(Icons.insert_photo, color: Colors.black45,)
                              ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(32),),
                            borderSide: BorderSide(color: Colors.grey[400]),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32),),
                              borderSide: BorderSide(color: Colors.grey[400]),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32),),            
                              borderSide: BorderSide(color: Colors.grey[400]),           
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
                                    'phoneNumber' : widget.receiverPhoneNumber,
                                    'image' : (widget.imageDownloadUrl == null) ? 'NoImage' : widget.imageDownloadUrl,
                                    'mostRecentMessage' : message,
                                  };

                                  var data2 = {
                                    'timestamp' : formatDate(timestamp, [HH, ':', nn, ':', ss, ' ', am]).toString(),
                                    'receiverID' : loggedInUserID,
                                    'phoneNumber' : loggedInUserPhoneNumber,
                                    'image' : (loggedInUserImage == null) ? 'NoImage' : loggedInUserImage,
                                    'mostRecentMessage' : message,
                                  };
                                 
                                 var messageData = {
                                   'timestamp' : timestamp,
                                   'senderID' : loggedInUserID,
                                   'message' : message,
                                   'exactTime' : timestamp,
                                   'type' : 'text-message',
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
                                
                                downloadUrlBool = false;
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
             SizedBox(
               height: 4,
             ),
            ],
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
          final timestamp = message.data['timestamp'];
          var dt = DateTime.parse(timestamp.toDate().toString());
          String time = formatDate(dt, [h, ':', n, am]).toString();
          String date = calculateDate(dt);
          String string = time;
          var start = ':';
          int startIndex = string.indexOf(':');
          int endIndex;
           endIndex = string.indexOf('M')-1;
          if(string.substring(startIndex + start.length, endIndex).length == 1)
          {
         string = string.substring(0,startIndex+1) + "0" + string.substring(startIndex+1, string.length);
         time = string;
          }
          String dateAndTime = "$date, $time"; 
          final String type = message.data['type'];
          final messageBubble = MessageBubble(
            senderID: messageSenderID,
            message: messageText,
            isMe: messageSenderID == loggedInUserID ? true : false,
            timestamp: dateAndTime,
            type: type,
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


String calculateDate(DateTime tm) {
      DateTime today = new DateTime.now();
      Duration oneDay = new Duration(days: 1);
      Duration twoDay = new Duration(days: 2);
      Duration oneWeek = new Duration(days: 7);
      String month;
      switch (tm.month) {
        case 1:
          month = "January";
          break;
        case 2:
          month = "February";
          break;
        case 3:
          month = "March";
          break;
        case 4:
          month = "April";
          break;
        case 5:
          month = "May";
          break;
        case 6:
          month = "June";
          break;
        case 7:
          month = "July";
          break;
        case 8:
          month = "August";
          break;
        case 9:
          month = "September";
          break;
        case 10:
          month = "October";
          break;
        case 11:
          month = "November";
          break;
        case 12:
          month = "December";
          break;
      }

      Duration difference = today.difference(tm);

      if (tm.day == today.day) {
        return "Today";
      } else if (tm.day == today.day - 1) {
        return "Yesterday";
      } else if (difference.compareTo(oneWeek) < 1) {
        switch (tm.weekday) {
          case 1:
            return "Monday";
          case 2:
            return "Tuesday";
          case 3:
            return "Wednesday";
          case 4:
            return "Thurdsday";
          case 5:
            return "Friday";
          case 6:
            return "Saturday";
          case 7:
            return "Sunday";
        }
      } else if (tm.year == today.year) {
        return '${tm.day} $month';
      } else {
        return '${tm.day} $month ${tm.year}';
      }
      return "";
    }

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderID;
  final bool isMe;
  final String timestamp;
  final String type;
  MessageBubble({this.message, this.senderID, this.isMe, this.timestamp, this.type});


  fullScreenImageAttachment(BuildContext context, String downloadLink){
    if(downloadLink!=null){
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(downloadUrl: downloadLink,)));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
             Material(
            elevation: 1,
            borderRadius: isMe == true
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
            color: isMe == true ? Color(0xffCEDEFE) : Color(0xff578DBE),
            child:  (type == 'image') 
                  ? Container(
                    padding: EdgeInsets.symmetric(vertical: 6.4, horizontal: 6.4),
                    width: 169,
                    height: 169,
                    child: GestureDetector(
                      onTap: ()=>fullScreenImageAttachment(context, message),
                      child:ClipRRect(
             borderRadius: new BorderRadius.circular(22.0),
             child:  FadeInImage.assetNetwork(
               fadeInDuration: Duration(milliseconds: 200),
               fadeOutDuration: Duration(milliseconds: 200),
               placeholder: 'gifs/go-top.gif',
              image: message,
               fit: BoxFit.fill,
            ),
            ),
            ),
            )
            : Wrap(
              alignment: WrapAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 9, top: 13, bottom: 12),
                  child: isMe ? Text(
                      message, style: TextStyle(fontSize: 15, color: Color(0xff293d3d),)) : Text(
                      message, style: TextStyle(fontSize: 15, color: Colors.white),),
                ),
                Padding(
                  padding: (message.length>=40) ? EdgeInsets.symmetric(horizontal:10.0, vertical: 10) : EdgeInsets.only(left:10.0, right:10, top: 19) ,
                  child: isMe ? 
                  Text(this.timestamp, style: TextStyle(fontSize: 11, color: Colors.black54),)
                   : Text(this.timestamp, style: TextStyle(fontSize: 11, color: Colors.white60),),
                ),
              ],
            ), 
          ),
        ],
      ),
    );
  }
}











      // Stack(
      //       children: <Widget>[
      //         Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: RichText(
      //             text: TextSpan(
      //               children: <TextSpan>[

      //             //real message
      //             TextSpan(
      //               text: message + "    ",
      //               style: TextStyle(
      //                 fontSize: 15,
      //                 color: Colors.white
      //               ),
      //             ),

      //             //fake additionalInfo as placeholder
      //             TextSpan(
      //                 text: "",
      //                 style: TextStyle(
      //                     color: Color.fromRGBO(255, 255, 255, 1)
      //                 )
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),

      //     //real additionalInfo
      //     Positioned(
      //       child: Text(
      //         this.timestamp,
      //         style: TextStyle(
      //           color: Colors.white60,
      //           fontSize: 11.0,
      //         ),
      //       ),
      //       right: 8.0,
      //       bottom: 4.0,
      //     )
      //   ],
      // ),






      // Wrap(
      //         alignment: WrapAlignment.end,
      //         children: <Widget>[
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Text(
      //                 "Text message in multi-lines and it looks similar to what's in the picture "),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Text("10:0 PM"),
      //           ),
      //         ],
      //       ),




//       CircleAvatar( backgroundColor: Colors.transparent ,radius: 2, child: ClipOval(
//   child: FadeInImage.assetNetwork(
//                 placeholder: 'gifs/760.gif',
//                 image: widget.imageDownloadUrl,
//                 fit: BoxFit.fill,
//               ),
// ),
// ),