import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'country.dart';
import 'package:country_icons/country_icons.dart';
import 'dart:core';
import 'newCountryList.dart';
import 'dart:async';
import 'screens/otp_screen.dart';


var result;
String phoneNumCountryCode = '91';
String twoLetterCountryCode = 'in';
bool veriFailedBool = false;

class CreateAccount extends StatefulWidget {
  static updateUI(var result) {
    phoneNumCountryCode = country[result];
    twoLetterCountryCode = result;
  }

  static const String id = 'mobileAuthScreen';

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  updatephoneNo() {
    phoneNo = '+$phoneNumCountryCode$phoneNo';
  }

  String phoneNo;
  String smsCode;
  String verificationId;

  TextEditingController mobile = new TextEditingController();
  TextEditingController otp = new TextEditingController();

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
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }


//  Future<bool> smsCodeDialog(BuildContext context) {
//    return showDialog(
//        context: context,
//        barrierDismissible: false,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text('Enter the 6-digit code'),
//            content: TextField(
//              keyboardType: TextInputType.number,
//              onChanged: (value) {
//                this.smsCode = value;
//              },
//            ),
//            contentPadding: EdgeInsets.all(10.0),
//            actions: <Widget>[
//              new FlatButton(
//                child: Text('Done'),
//                onPressed: () {
//                  FirebaseAuth.instance.currentUser().then((user) {
//                      if (user != null) {
//                        pushToProfilePage(context);  //NEEDS SOME ALTERING
//                      }else{
//                        pushToProfilePage(context);
//                   }
//
//                  });
//                },
//              ),
//            ],
//          );
//        });
//  }


//  pushToProfilePage(ctx) async{
//    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>EditProfile(smsCode: smsCode, phoneNumber: phoneNo, verificationId: verificationId,),),);
//  }

  pushToOTPScreen(ctx) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>OTPScreen(phoneNumber: this.phoneNo),),);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Flash Chat will send an SMS message to verify your phone number. Enter your country code and phone number.",
                      style: TextStyle(
                        fontSize: 18.5,
                        letterSpacing: 0.55,
                        fontFamily: 'Monserrat',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: new SelectionGDetector(),
                        ),
                        SizedBox(
                          width: 10.5,
                        ),
                        Expanded(
                          child: Text(
                            '+$phoneNumCountryCode',
                            style: TextStyle(
                              fontSize: 17.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 17.5,
                            ),
                            keyboardType: TextInputType.phone,
                            controller: mobile,
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.black, width: 2.5),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Enter mobile number"),
                            onChanged: (s) {
                              print(s);
                              phoneNo = s;
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 5,
                      child: SizedBox(),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Text(
                            'By continuing, you may receive an SMS for verification. Message and data rates may apply.',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RawMaterialButton(
                            onPressed: () {
                              updatephoneNo();
                              pushToOTPScreen(ctx);
                            },
                            //RawMaterialButton widget class is used for building buttons from scratch
                            child: Icon(
                              FontAwesomeIcons.arrowRight,
                              color: Colors.white,
                            ), //Icon widget requires an either Icons.someicon or FontAwesomeIcons.someicon value
                            constraints:
                            BoxConstraints.tightFor(width: 56, height: 56),
                            shape: CircleBorder(),
                            fillColor: Color(0xFF4C4F5E),
                            elevation: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      );
  }
}

class SelectionGDetector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateAndDisplaySelection(context);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              child: Image.asset(
                'icons/flags/png/${twoLetterCountryCode.toLowerCase()}.png',
                package: 'country_icons',
                height: 20,
                width: 30,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            width: 7,
          ),
          Expanded(
            child: Icon(
              FontAwesomeIcons.chevronDown,
              size: 8,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewCountryList()),
    );
    CreateAccount.updateUI(result);
  }
}














//SafeArea(
//child: Center(
//child: Padding(
//padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
//child: Column(
//mainAxisAlignment: MainAxisAlignment.start,
//children: <Widget>[
//Text(
//"Flash Chat will send an SMS message to verify your phone number. Enter your country code and phone number.",
//style: TextStyle(
//fontSize: 18.5,
//letterSpacing: 0.55,
//fontFamily: 'Monserrat',
//fontWeight: FontWeight.normal,
//),
//),
//SizedBox(
//height: 20,
//),
//Row(
//mainAxisAlignment: MainAxisAlignment.start,
//children: <Widget>[
//Expanded(
//child: new SelectionGDetector(),
//),
//SizedBox(
//width: 10.5,
//),
//Expanded(
//child: Text(
//'+$phoneNumCountryCode',
//style: TextStyle(
//fontSize: 17.5,
//),
//),
//),
//Expanded(
//flex: 4,
//child: TextField(
//style: TextStyle(
//fontSize: 17.5,
//),
//keyboardType: TextInputType.phone,
//controller: mobile,
//decoration: InputDecoration(
//enabledBorder: UnderlineInputBorder(
//borderSide:
//BorderSide(color: Colors.black, width: 2.5),
//),
//focusedBorder: UnderlineInputBorder(
//borderSide: BorderSide(color: Colors.black54),
//),
//contentPadding: EdgeInsets.symmetric(
//vertical: 10.0, horizontal: 10.0),
//hintText: "Enter mobile number"),
//onChanged: (s) {
//print(s);
//phoneNo = s;
//},
//),
//),
//],
//),
//Expanded(
//flex: 5,
//child: SizedBox(),
//),
//Row(
//children: <Widget>[
//Expanded(
//flex: 4,
//child: Text(
//'By continuing, you may receive an SMS for verification. Message and data rates may apply.',
//style: TextStyle(
//fontSize: 13,
//),
//),
//),
//Expanded(
//child: RawMaterialButton(
//onPressed: () {
//scaffoldContext = context;
//updatephoneNo();
//verifyPhone();
//},
////RawMaterialButton widget class is used for building buttons from scratch
//child: Icon(
//FontAwesomeIcons.arrowRight,
//color: Colors.white,
//), //Icon widget requires an either Icons.someicon or FontAwesomeIcons.someicon value
//constraints:
//BoxConstraints.tightFor(width: 56, height: 56),
//shape: CircleBorder(),
//fillColor: Color(0xFF4C4F5E),
//elevation: 0.0,
//),
//),
//],
//),
//],
//),
//),
//),
//),