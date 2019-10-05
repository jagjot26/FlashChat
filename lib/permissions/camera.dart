import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class Camera extends StatelessWidget {

  reqCameraPerm() async{
    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
  }

  checkCameraPerm() async{
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    print(permission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: reqCameraPerm,
            child: Text('Request camera permission'),
          ),
          SizedBox(
            height: 40,
          ),
          RaisedButton(
            onPressed: checkCameraPerm,
            child: Text('Check camera permission'),
          ),
        ],
      ),
    );
  }
}


//# Android
//var permissions = await Permission.getPermissionsStatus([PermissionName.Calendar, PermissionName.Camera]);
//
//var permissionNames = await Permission.requestPermissions([PermissionName.Calendar, PermissionName.Camera]);
//
//# iOS
//var permissionStatus = await Permission.getSinglePermissionStatus(PermissionName.Calendar);
//
//var permissionStatus = await Permission.requestSinglePermission(PermissionName.Calendar);