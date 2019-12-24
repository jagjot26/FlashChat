import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/progress.dart';
import 'package:flash_chat/screens/fullsize_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool isImageDownloading;
String newDownloadUrl=" ";

class ProfileEdit extends StatefulWidget {

  final String profileImageUrl;
  final String userName;
  final String about;
  final String phoneNumber;
  

  ProfileEdit({this.profileImageUrl,this.userName,this.about, this.phoneNumber});
  @override
  _ProfileEditState createState() => _ProfileEditState();
}



class _ProfileEditState extends State<ProfileEdit> {


var fcmToken;
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
QuerySnapshot qs;

String newBio="";
bool isTextFieldEmpty=true;
bool newBioUpdated = false;

searchForUidViaPhoneNumberAndUpdateProfilePic(String downloadUrl) async{
  qs =  await usersRef.getDocuments();
    var listOfDocuments = qs.documents;
    for(var dc in listOfDocuments){
     if(dc["displayName"] == widget.userName || dc["phoneNumber"]==widget.phoneNumber)
     {
       String uid = dc["id"];
       usersRef.document(uid).setData({
        "id": uid,
        "displayName": widget.userName,
        "bio": (newBio == "") ? widget.about : newBio ,
        "phoneNumber": widget.phoneNumber,
        "timestamp": timestamp,
        "imageDownloadUrl" : downloadUrl,
        "fcmToken" : this.fcmToken
      });    
     }     
    }
}

TextEditingController tcontroller;

handleBioChangerButton() async{
 qs =  await usersRef.getDocuments();
    var listOfDocuments = qs.documents;
    for(var dc in listOfDocuments){
     if(dc["displayName"] == widget.userName || dc["phoneNumber"]==widget.phoneNumber)
     {
       String uid = dc["id"];
       usersRef.document(uid).setData({
        "id": uid,
        "displayName": widget.userName,
        "bio": newBio,
        "phoneNumber": widget.phoneNumber,
        "timestamp": timestamp,
        "imageDownloadUrl" : (newDownloadUrl==" ") ? widget.profileImageUrl : newDownloadUrl,
        "fcmToken" : this.fcmToken
      });    
     }     
    }
    setState(() {
      newBioUpdated = true;
    });    
    print(newBio);
    final prefs2 = await SharedPreferences.getInstance();
    prefs2.setString("loggedInUserBio",newBio);
}

handleEditBio(BuildContext ctx){
 showModalBottomSheet(isScrollControlled: true,context: ctx, builder: (context){
  return Padding(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisSize: MainAxisSize.max,
  children: <Widget>[
    Expanded(
      flex: 6,
            child: Padding(
          padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
          child: TextField(
          autofocus: true,
          onChanged: (val){
          setState(() {
            newBio = val;
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
        hintText: 'Type your new bio',
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
    ),
    SizedBox(
    width: MediaQuery.of(context).size.width*0.06,
    ),
    Expanded(
      flex: 2,
            child: Padding(
              padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
              child: RawMaterialButton(
        onPressed: (){
          if(newBio.length>70)
          {
            Fluttertoast.showToast(msg: "Bio too long, your bio can only be upto 70 characters long",  textColor: Colors.white, backgroundColor: Colors.black54);
          }
         if(isTextFieldEmpty == false && newBio.length>0 && newBio.length<=70){
           handleBioChangerButton();
           Navigator.pop(context);
         }             

        },
       child: Icon(Icons.send, color:Colors.green),
       constraints: BoxConstraints.tightFor(width: 40, height: 40),
       shape: CircleBorder(),
       fillColor: Colors.black,
       elevation: 0.0,
      ),
            ),
    ),
  ],
    ),
    );
 });
}
 
 
 String downloadUrl;
 File image;

  uploadImageAndGetDownloadUrl() async{
  StorageReference ref = FirebaseStorage.instance.ref().child(widget.phoneNumber);
  StorageUploadTask uploadTask = ref.putFile(this.image);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  downloadUrl = await taskSnapshot.ref.getDownloadURL();
  newDownloadUrl = downloadUrl;
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("loggedInUserImage",downloadUrl);
  setState(() {
   isImageDownloading = true; 
  });
  searchForUidViaPhoneNumberAndUpdateProfilePic(downloadUrl);
}


  handleSelectImage(BuildContext parentContext){
    return showDialog(context: parentContext, builder: (context){
      return SimpleDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0),),
        ),
        title: Text('Select Profile Picture'),
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
    Fluttertoast.showToast(msg: "Updating profile picture...",  textColor: Colors.white, backgroundColor: Colors.black54);
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
    Fluttertoast.showToast(msg: "Updating profile picture...",  textColor: Colors.white, backgroundColor: Colors.black54);
    await uploadImageAndGetDownloadUrl();
    // setState(() {
    //   this.image = image;
    // });
  }


fullScreenImage(BuildContext context){
  if(isImageDownloading == true || newDownloadUrl != " "){
     Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(downloadUrl: newDownloadUrl,)));
  }
  else if(widget.profileImageUrl!=null && newDownloadUrl == " "){
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(downloadUrl: widget.profileImageUrl,)));
}
else{
  Scaffold.of(context).showSnackBar(SnackBar(action: SnackBarAction(label: 'OK', onPressed: (){},) ,content: Text("This user hasn't uploaded any profile picture"
  )));
}
  }


getToken() async{
final prefs = await SharedPreferences.getInstance();
  this.fcmToken = prefs.getString("fcmToken");
}


@override
  void initState() {
    getToken();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        resizeToAvoidBottomPadding: false,    
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.415,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/edit.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter, 
      colors: [const Color(0xff8e54cc), const Color(0xFf32cdfb)], 
      tileMode: TileMode.repeated, // repeats the gradient over the canvas
    ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.29,
                ),
                 Container(
                alignment: Alignment.topCenter,
                child: (isImageDownloading==true) ? 
                 GestureDetector(onTap:()=>fullScreenImage(context), child: CircleAvatar(
   backgroundColor: Colors.blue,
   radius: MediaQuery.of(context).size.width*0.18,
   child: ClipOval(
    child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: newDownloadUrl,
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ),
 )
                 :  (widget.profileImageUrl == 'NoImage' || widget.profileImageUrl == null) 
                 ? GestureDetector(onTap: ()=>fullScreenImage(context), child:CircleAvatar(child: Image.asset('images/blah.png'), radius: MediaQuery.of(context).size.width*0.18,)) 
                 :  GestureDetector(onTap: ()=> fullScreenImage(context),child:CircleAvatar(
   backgroundColor: Colors.blue,
   radius: MediaQuery.of(context).size.width*0.18,
   child: ClipOval(
    child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: widget.profileImageUrl,
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
   ),
 ),),
               ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.016,
               ),
               AutoSizeText(widget.userName, style: TextStyle(
                 fontFamily: 'Nunito',
                 fontSize: (widget.userName.length>8) ? 32 : 36,
                 fontWeight: FontWeight.w500,
                 color: Color(0xffb3ecff),
               ),
               ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.04,
               ),
               Card(
                 shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                 color: Color(0xffd4e4ff),
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Color(0xFf4d7dff),
                  ),
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 20.0,
                        color: Color(0xff595959),
                      ),
                    ),
                  ),
                )),
                SizedBox(
                 height: MediaQuery.of(context).size.height*0.002,
               ),
                 Card(
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                   color: Color(0xffd4e4ff),
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.info,
                    color:Color(0xff4d7dff),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: (newBioUpdated == true)
                    ? Text(newBio, style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 20.0,
                        color: Color(0xff595959),
                      ),) 
                    : Text(
                      widget.about,
                      style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 20.0,
                        color: Color(0xff595959),
                      ),
                    ),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 30, left: 5, bottom: 5),
                    child: GestureDetector(onTap: ()=> handleEditBio(context) , child: Icon(Icons.edit, color: Color(0xff628cff),)),
                  ),
                )),
              ],
            ),
           Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height*0.44,
              ),
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.53),
                child: RawMaterialButton(
                  onPressed: ()=>handleSelectImage(context),
                 child: Icon(Icons.edit, color: Colors.white,),
                 constraints: BoxConstraints.tightFor(width: 36, height: 36),
                 shape: CircleBorder(),
                 fillColor: Color(0xff0043fb),
                 elevation: 0.0,
                ),
              ),
            ],
           ),
          ],
        ),
      ),
    );
  }
}



