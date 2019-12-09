import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../progress.dart';

class FullSizeImage extends StatelessWidget {
 final String downloadUrl;

 FullSizeImage({this.downloadUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: CachedNetworkImage(
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,
      imageUrl: this.downloadUrl,
      placeholder: (context, url) => spinkit(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    ),
        ),
      ),
    );
  }
}