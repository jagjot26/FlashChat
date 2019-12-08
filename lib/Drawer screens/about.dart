import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "images/companion.jpg"), // <-- BACKGROUND IMAGE
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.36),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      "FlashChat",
                      style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Source-Sans-Pro', fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "version 1.0",
                      style: TextStyle(fontSize: 17, color: Colors.white60),
                    ),
                    SizedBox(
                     height: 10,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: MediaQuery.of(context).size.width*0.107,
                      child: ClipOval(
                        child: Image.asset("images/icon-image.png"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
