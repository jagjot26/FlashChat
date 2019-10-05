import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';

class Contacts with ChangeNotifier {
  Iterable<Contact> contacts;

   getContacts() async{
    contacts = await ContactsService.getContacts();
  }



}