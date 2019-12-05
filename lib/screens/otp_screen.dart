import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'dart:async';
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/edit_profile.dart';
import 'package:flash_chat/provider/auth.dart';
import 'package:provider/provider.dart';


bool veriFailedBool = false;

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




  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
//      smsCodeDialog(context).then((value) {
////
////        print('Signed in');
////      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      veriFailedBool = false;
      print('verified');
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
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }





  
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 6;

  bool hasError = false;
  String errorMessage;


  @override
  void initState() {
    verifyPhone();
    super.initState();
  }

  handleLogin() async{
    this.boolOTP = await Provider.of<Auth>(context, listen: false).logIn(
        this.smsCode, this.verificationId, widget.phoneNumber,
    );
    print('this.boolOTP in handleLogin method has the value : ${this.boolOTP}' );
    if(boolOTP == false && hasError == false){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> EditProfile(phoneNumber: widget.phoneNumber,)));
    }
    if(boolOTP == false){
      hasError = false;
    }
    else if(this.boolOTP == true){
      setState(() {
        this.errorMessage = 'There was some error signing you in. Either try re-entering the OTP carefully or re-run the app and enter your phone number again';
        this.hasError = true;
      });
    }
    else if(this.smsCode == null){
      this.errorMessage = 'Please enter the complete OTP code sent to your number';
      setState(() {
        this.hasError = true;
      });
    }
    else{
      this.errorMessage = 'unknown error has occured. Please try again later.';
      setState(() {
        this.hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  handleLogin();
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
                padding: EdgeInsets.all(35),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text("Verify", style: TextStyle(fontFamily: 'Montserrat',fontSize: 20),),
                  onPressed: () {
                   handleLogin();
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

