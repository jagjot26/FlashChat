import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple),
      ));
}

Scaffold specialCircularProgress(){
  return Scaffold(
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Initializing...',
                textAlign: TextAlign.center,
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                color: Colors.blue,
              ),),
              SizedBox(
                height: 7,
              ),
              Text('Please wait a moment',textAlign:TextAlign.center, style: TextStyle(fontSize: 18,fontWeight:FontWeight.w600 ,color: Colors.blueGrey),),
              SizedBox(
                height: 70,
              ),
              Image.asset('images/chat-features-crop_1x.png'),
              SizedBox(
                height: 70,
              ),
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
