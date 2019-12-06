import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'dart:async';
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/edit_profile.dart';
import 'package:flash_chat/provider/auth.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


bool veriFailedBool = false;
final _scaffoldKey = GlobalKey<ScaffoldState>();

class OTPScreen extends StatefulWidget {

 final String phoneNumber;

  OTPScreen({this.phoneNumber});


  static final id = 'otp_screen';
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool boolOTP;
  String verificationId;
  String smsCode;




  Future<void> verifyPhone(BuildContext context) async {
    

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) async{
      this.verificationId = verId;
//      smsCodeDialog(context).then((value) {
////
////        print('Signed in');
////      });
    };
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    // final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
    //   veriFailedBool = false;
    
    //   _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   duration: Duration(seconds: 6),
    //   content: Text("OTP code sent. If you don't receive it, try again later")
    // ),);
    // };

final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      FirebaseAuth.instance
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          print(value.user.phoneNumber);
           prefs.setString('uid', value.user.uid);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> EditProfile(phoneNumber: widget.phoneNumber,user: value.user,)));
        } else {
          Fluttertoast.showToast(msg: "Error validating OTP, try again",  textColor: Colors.red);
        }
      }).catchError((error) {
        Fluttertoast.showToast(msg: "Try again in some time",  textColor: Colors.red);
      });
    };


    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      veriFailedBool = true;
         
      print('${exception.message}');
      print('veriFailed called');
    };



    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.widget.phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 30),
        verificationCompleted: verificationCompleted,
        verificationFailed: veriFailed);
  }





  
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 6;

  bool hasError = false;
  String errorMessage;
  var prefs;
getSharedPref() async{
  prefs = await SharedPreferences.getInstance();
}

  @override
  void initState() {
    getSharedPref();
   new Future.delayed(Duration.zero,() {
      verifyPhone(context);
    });
    super.initState();
  }

 var currentUserUid;
void onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: this.verificationId, smsCode: this.smsCode);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        // Handle loogged in state
        print(value.user.phoneNumber);
        print(value.user.uid);
        this.currentUserUid = value.user.uid;
        prefs.setString('uid', value.user.uid);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> EditProfile(phoneNumber: widget.phoneNumber, user: value.user,)));
      } else {
        Fluttertoast.showToast(msg: "Error validating OTP, try again",  textColor: Colors.red);
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Something went wrong",  textColor: Colors.red);
    });
   
     
     
 }
  // handleLogin() async{
  //   this.boolOTP = await Provider.of<Auth>(context, listen: false).logIn(
  //       this.smsCode, this.verificationId, widget.phoneNumber,
  //   );
  //   print('this.boolOTP in handleLogin method has the value : ${this.boolOTP}' );
  //   if(boolOTP == false && hasError == false){
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> EditProfile(phoneNumber: widget.phoneNumber,)));
  //   }
  //   if(boolOTP == false){
  //     hasError = false;
  //   }
  //   else if(this.boolOTP == true){
  //     setState(() {
  //       this.errorMessage = 'An unexpected error has occured';
  //       this.hasError = true;
        
  //     });
  //   }
  //   else if(this.smsCode == null){
  //     this.errorMessage = 'Please enter the complete OTP code sent to your number';
  //     setState(() {
  //       this.hasError = true;
  //     });
  //   }
  //   else{
  //     this.errorMessage = 'unknown error has occured. Please try again later.';
  //     setState(() {
  //       this.hasError = true;
  //     });
  //   }
  // }



 bool smsCodeEntered = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Text(thisText, style: Theme.of(context).textTheme.title),
              ),
              Text('Verify your mobile',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33),),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.08,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
                child: Text('Enter the 6-digit code sent to your mobile number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontFamily: 'Manjari',
                  fontSize: 20,
                    color: Color(0xff738598),

                ),),
              ),
              PinCodeTextField(
                autofocus: false,
                controller: controller,
                hideCharacter: false,
                highlight: true,
                highlightColor: Colors.blue,
                defaultBorderColor: Colors.black,
                hasTextBorderColor: Colors.green,
                maxLength: pinLength,
                hasError: hasError,
                maskCharacter: "😎",

                onTextChanged: (text) {
                  this.smsCode=text;
                  setState(() {
                    hasError = false;
                  });
                },
                onDone: (text){
                  print("DONE $text");
                  onFormSubmitted();
                  print('this.boolOTP has the value : ${this.boolOTP}' );
            

                },
                pinCodeTextFieldLayoutType: PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
                wrapAlignment: WrapAlignment.start,
                pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                pinTextStyle: TextStyle(fontSize: 30.0),
                pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
              ),
              Visibility(
                child: Text(
                  (errorMessage==null)?'An unknown error has occured. Please try again later.' : this.errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                visible: hasError,
              ),
              Padding(
                padding: EdgeInsets.all(41),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text("Verify", style: TextStyle(fontFamily: 'Montserrat',fontSize: 20),),
                  onPressed: () {
                   onFormSubmitted();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

