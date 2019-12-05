import 'package:flash_chat/progress.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



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

final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
QuerySnapshot qs;
String newDownloadUrl=" ";
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
        "imageDownloadUrl" : downloadUrl
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
        hintText: 'Type your message',
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
         if(isTextFieldEmpty == false && newBio.length>0){
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
 
 bool isImageDownloading;
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
                      image: AssetImage('images/scenery1.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                    width: double.infinity,
                    color: Color(0xffe6fff5),
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
                 CircleAvatar( backgroundColor: Colors.transparent ,radius: MediaQuery.of(context).size.width*0.18, child: ClipOval(
  child: FadeInImage.assetNetwork(
              fadeInDuration: Duration(milliseconds: 200),
              fadeOutDuration: Duration(milliseconds: 200),
              placeholder: 'gifs/496.gif',
              image: newDownloadUrl,
              fit: BoxFit.fill,
            ),
),
)
                 :  (widget.profileImageUrl == 'NoImage' || widget.profileImageUrl == null) ? CircleAvatar(child: Image.asset('images/blah.png'), radius: MediaQuery.of(context).size.width*0.18,) :  CircleAvatar( backgroundColor: Colors.transparent ,radius: MediaQuery.of(context).size.width*0.18, child: ClipOval(
  child: FadeInImage.assetNetwork(
              fadeInDuration: Duration(milliseconds: 200),
              fadeOutDuration: Duration(milliseconds: 200),
              placeholder: 'gifs/ld9.gif',
              image: this.widget.profileImageUrl,
              fit: BoxFit.fill,
            ),
),
),
               ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.014,
               ),
               Text(widget.userName, style: TextStyle(
                 fontFamily: 'Pacifico',
                 fontSize: 34,
                 fontWeight: FontWeight.w500,
                 color: Color(0xff008080),
               ),
               ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.04,
               ),
               Card(
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.teal[400],
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
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.info,
                    color:Colors.teal[400],
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
                    child: GestureDetector(onTap: ()=> handleEditBio(context) , child: Icon(Icons.edit, color: Colors.cyan[400],)),
                  ),
                )),
              ],
            ),
           Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height*0.45,
              ),
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.53),
                child: RawMaterialButton(
                  onPressed: ()=>handleSelectImage(context),
                 child: Icon(Icons.edit, color: Colors.white,),
                 constraints: BoxConstraints.tightFor(width: 36, height: 36),
                 shape: CircleBorder(),
                 fillColor: Color(0xff008080),
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



