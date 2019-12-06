import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chatList_screen.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:provider/provider.dart';
import 'provider/auth.dart';
import 'main.dart';
import 'progress.dart';
import 'screens/splash-screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';

String downloadUrl;
String displayName;
bool isLoading = false;
bool isImageLoading = false;
class EditProfile extends StatefulWidget {
  static const id = 'edit_profile';

  final String phoneNumber;
  final FirebaseUser user;

  EditProfile({this.phoneNumber, this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File image;


uploadImageAndGetDownloadUrl() async{
  StorageReference ref = FirebaseStorage.instance.ref().child(widget.phoneNumber);
  StorageUploadTask uploadTask = ref.putFile(this.image);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  downloadUrl = await taskSnapshot.ref.getDownloadURL();
  setState(() {
   isImageLoading = false; 
  });
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
    this.image = image;
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
    setState(() {
       isImageLoading = true;
    }); 
    this.image = result;
      
    await uploadImageAndGetDownloadUrl();
    // setState(() {
    //   this.image = image;
    // });
  }


  handleNext(BuildContext context) async{
    setState(() {
      isLoading = true;
    });

    await Provider.of<Auth>(context, listen: false).createUserInFireStore(
      widget.user, widget.phoneNumber, displayName, downloadUrl
    );
     Navigator.pushReplacementNamed(context, ChatListScreen.id);  //check this without await as it doesn't seem like it's reqd here
  }




  @override
  Widget build(BuildContext context) {
    return isLoading ? specialCircularProgress() : SafeArea(
      child: WillPopScope(
        onWillPop: ()async => false,
              child: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 70, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Profile Info', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                ),),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('Please provide your name and an optional profile picture.',textAlign: TextAlign.center,style: TextStyle(fontSize: 16,fontWeight:FontWeight.w600 ,color: Colors.blueGrey),)),
                SizedBox(height: MediaQuery.of(context).size.height*0.045,),
                ListTile(
                  leading: GestureDetector(
                    onTap: () => handleSelectImage(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffd4d7dd),
                        borderRadius: BorderRadius.all(Radius.circular(10),),
                      ),
                      width: MediaQuery.of(context).size.width*0.1466,
                      height: MediaQuery.of(context).size.height*0.1466,
                      child: (image==null) ? Icon(FontAwesomeIcons.camera): 
                        isImageLoading==true ? circularProgress() : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10),),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(downloadUrl),
                            )
                        ),
                      ),),
                  ),
                  title: TextField(
                    onChanged: (val){
                      displayName = val;
                    },
                    onSubmitted: (val)=>handleNext(context),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2.3),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent,width: 2.3),
                      ),
                    ),
                    cursorColor: Colors.blueAccent,
                    showCursor: true,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.044,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: ()=>handleNext(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
