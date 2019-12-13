import 'package:flash_chat/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/chatList_screen.dart';
import 'package:flash_chat/create_account.dart';
import 'newCountryList.dart';
import 'package:provider/provider.dart';
import 'provider/auth.dart';
import 'dart:async';
import 'screens/splash-screen.dart';
import 'edit_profile.dart';
import 'screens/contacts_screen.dart';
import 'models/contacts_list.dart';
import 'screens/otp_screen.dart';
import 'screens/tempScreen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'Drawer screens/profile_edit.dart';
import 'Drawer screens/about.dart';


// handle invalid verification code error
//handle image upload to Firestore along with other items as a document after compression and conversion to string
//handle back phone's button press on screens
//add loading widget when OTP alert is not displayed for a few seconds
//can't resolve GradleException error in app level build.gradle
//divide login stuff and adding user stuff. add login stuff back to create account or something


//on CONTACT's SCREEN, PHONE NUMBERS W/O +91 SHOULD ALSO BE DISPLAYED

//CHECK IF USER IS ONLINE AND DISPLAY 'online' BELOW THEIR NAME
//NEXT BUTTON NOT VISIBLE WHEN KEYBOARD IS UP
void main(){ 
  WidgetsFlutterBinding.ensureInitialized(); 
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, DeviceOrientation.portraitDown
    ]);
   
  runApp(FlashChat());
  }

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Contacts(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flash Chat',
          theme: ThemeData(
            primaryColor: Colors.blue,
            accentColor: Colors.blue,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
                ? ChatListScreen()
               : FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, authResultSnapshot) =>
                authResultSnapshot.connectionState ==
                ConnectionState.waiting
               ? SplashScreen()
                : CreateAccount(),
                ),


    routes: {
            OTPScreen.id:(context) => OTPScreen(),
            CreateAccount.id: (context) => CreateAccount(),
            ChatListScreen.id: (context) => ChatListScreen(),
           NewCountryList.id: (context) => NewCountryList(),
           EditProfile.id : (context)=>EditProfile(),
           ContactsScreen.id: (context)=>ContactsScreen(),
},
        ),
      ),
    );
  }
}



//return MultiProvider(
//providers: [
//ChangeNotifierProvider.value(
//value: Auth(),
//),
//ChangeNotifierProxyProvider<Auth, Products>(
//builder: (ctx, auth, previousProducts) => Products(
//auth.token,
//auth.userId,
//previousProducts == null ? [] : previousProducts.items,
//),
//),
//ChangeNotifierProvider.value(
//value: Cart(),
//),
//ChangeNotifierProxyProvider<Auth, Orders>(
//builder: (ctx, auth, previousOrders) => Orders(
//auth.token,
//auth.userId,
//previousOrders == null ? [] : previousOrders.orders,
//),
//),
//],
//child: Consumer<Auth>(
//builder: (ctx, auth, _) => MaterialApp(
//title: 'MyShop',
//theme: ThemeData(
//primarySwatch: Colors.purple,
//accentColor: Colors.deepOrange,
//fontFamily: 'Lato',
//),
//home: auth.isAuth
//? ProductsOverviewScreen()
//    : FutureBuilder(
//future: auth.tryAutoLogin(),
//builder: (ctx, authResultSnapshot) =>
//authResultSnapshot.connectionState ==
//ConnectionState.waiting
//? SplashScreen()
//    : AuthScreen(),
//),
//routes: {
//ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
//CartScreen.routeName: (ctx) => CartScreen(),
//OrdersScreen.routeName: (ctx) => OrdersScreen(),
//UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
//EditProductScreen.routeName: (ctx) => EditProductScreen(),
//},
//),
//),
//);
//
//MaterialApp(
//initialRoute: HomeScreen.id,
//routes: {
//WelcomeScreen.id: (context) => WelcomeScreen(),
//CreateAccount.id: (context) => CreateAccount(),
//LoginScreen.id: (context) => LoginScreen(),
//RegistrationScreen.id: (context) => RegistrationScreen(),
//ChatScreen.id: (context) => ChatScreen(),
//NewCountryList.id: (context) => NewCountryList(),
//HomeScreen.id: (context) => HomeScreen(),
////},
//);


// auth.isAuth
//                 ? ChatListScreen()
//                : FutureBuilder(
//                 future: auth.tryAutoLogin(),
//                 builder: (ctx, authResultSnapshot) =>
//                 authResultSnapshot.connectionState ==
//                 ConnectionState.waiting
//                ? SplashScreen()
//                 : CreateAccount(),
//                 ),

// auth.isAuth
//                 ? ChatListScreen()
//                : FutureBuilder(
//                 future: auth.tryAutoLogin(),
//                 builder: (ctx, authResultSnapshot) =>
//                 authResultSnapshot.connectionState ==
//                 ConnectionState.waiting
//                ? SplashScreen()
//                 : CreateAccount(),
//                 ),


// auth.isAuth
//                 ? ChatListScreen()
//                : FutureBuilder(
//                 future: auth.tryAutoLogin(),
//                 builder: (ctx, authResultSnapshot) =>
//                 authResultSnapshot.connectionState ==
//                 ConnectionState.waiting
//                ? SplashScreen()
//                 : CreateAccount(),
//                 ),