import 'package:flutter/material.dart';

class FullSizeImage extends StatelessWidget {
 final String downloadUrl;

 FullSizeImage({this.downloadUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: FadeInImage.assetNetwork(
              placeholder: 'gifs/496.gif',
              image: this.downloadUrl,
              fit: BoxFit.fill,
            ),
        ),
      ),
    );
  }
}