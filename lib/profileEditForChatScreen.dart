import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/progress.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/fullsize_image.dart';

class ProfileEditForChatScreen extends StatefulWidget {

  final String profileImageUrl;
  final String userName;
  final String about;
  final String phoneNumber;

  ProfileEditForChatScreen({this.profileImageUrl,this.userName,this.about, this.phoneNumber});



  @override
  _ProfileEditForChatScreenState createState() => _ProfileEditForChatScreenState();
}

class _ProfileEditForChatScreenState extends State<ProfileEditForChatScreen> {

fullScreenImage(BuildContext context){
  if(widget.profileImageUrl!=null){
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(downloadUrl: widget.profileImageUrl,)));
}
else{
  Scaffold.of(context).showSnackBar(SnackBar(action: SnackBarAction(label: 'OK', onPressed: (){},) ,content: Text("This user hasn't uploaded any profile picture"
  )));
}
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
                child:(widget.profileImageUrl == 'NoImage' || widget.profileImageUrl==null) 
                ? GestureDetector(onTap: ()=>fullScreenImage(context), child:CircleAvatar(child: Image.asset('images/blah.png'), radius: MediaQuery.of(context).size.width*0.18,),) 
                :  GestureDetector(onTap: ()=>fullScreenImage(context), child: CircleAvatar(
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
 ), ),
               ),
               SizedBox(
                 height: MediaQuery.of(context).size.height*0.014,
               ),
               Text(widget.userName, style: TextStyle(
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
                    color:Color(0xFf4d7dff),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child:  Text(
                      widget.about,
                      style: TextStyle(
                        fontFamily: 'Source Sans Pro',
                        fontSize: 20.0,
                        color: Color(0xff595959),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// CircleAvatar( backgroundColor: Colors.transparent ,radius: MediaQuery.of(context).size.width*0.18, child: ClipOval(
//   child: FadeInImage.assetNetwork(
//               fadeInDuration: Duration(milliseconds: 200),
//               fadeOutDuration: Duration(milliseconds: 200),
//               placeholder: 'gifs/ld9.gif',
//               image: this.widget.profileImageUrl,
//               fit: BoxFit.fill,
//             ),
// ),
// ),