import 'package:flutter/material.dart';
import 'package:flash_chat/progress.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: circularProgress(),
      ),
    );
  }
}
