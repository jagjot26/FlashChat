import 'package:flash_chat/country.dart';
import 'package:flutter/material.dart';
import 'package:country_icons/country_icons.dart';
import 'dart:core';

bool imp = true;
var ctx;

List<Widget> listViewItems = [];

class NewCountryList extends StatefulWidget {
  static const id = 'newCountryList';
  @override
  _NewCountryListState createState() => _NewCountryListState();
}

loop(BuildContext context) {
  if (imp == false) {
    ctx = context;
  }

  for (String countryCode in country.keys) {
    //looping through the map
    String countryCodeLowerCase = countryCode.toLowerCase();
    String phoneCode = country[countryCode];
    var item = Padding(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 13),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(ctx,
              countryCode); //tried playing context and this worked, somehow.
        },
        child: Row(
          children: <Widget>[
            Container(
              child: Image.asset(
                'icons/flags/png/$countryCodeLowerCase.png',
                package: 'country_icons',
                height: 20,
                width: 30,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              '$countryCode (+$phoneCode)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    listViewItems.add(item);
  }
}

class _NewCountryListState extends State<NewCountryList> {
  ListView listViewLoopMethod(context) {
    if (imp == true) {
      ctx = context;
      imp = false;
    }
    //to be used in a ListView

    loop(context);

    return ListView(
      children: listViewItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
          child: Scaffold(
        body: SafeArea(
          child: listViewLoopMethod(this.context),
        ),
      ),
    );
  }
}
