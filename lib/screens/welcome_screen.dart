import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/create_account.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcomeScreen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

//SingleTickerProviderMixin is very important for the initialising
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  //an animation needs an animation controller, a ticker and an animation value

  Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //controller can have a lot of properties like upperBound to change it from 1 to anything else
    controller = AnimationController(
      duration: Duration(seconds: 1, milliseconds: 400),
      vsync:
          this, //this is the WelcomeScreen object, and it acts as the t i c k e r, here.
    );

    animation =
        ColorTween(begin: Colors.purpleAccent[100], end: Colors.cyan[200])
            .animate(controller);
    //for other types
    //of animations like the Curved animations, refer to screenshots and flutter documentation

    controller
        .forward(); //we can also use reverse() here, which will take a from, as in a 'from what duration' value

    controller.addListener(() {
      setState(
          () {}); //controller.value is set to be between 0 and 1 by default
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation
          .value, //use withOpacity with controller.value for Spotify looking animation
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),
                ),
                Text(
                  'Flash Chat',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              buttonText: 'Log In',
              onPress: () {
                Navigator.pushNamed(context, CreateAccount.id);
              },
            ),
            RoundedButton(
              color: Colors.blueAccent,
              buttonText: 'Register',
              onPress: () {
               
              },
            ),
          ],
        ),
      ),
    );
  }
}
