import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';

class SimpleContact {
  final String name;
  final String phone;
  final String label;
  final Uint8List? photo;

  SimpleContact({
    required this.name,
    required this.phone,
    required this.label,
    this.photo,
  });
}

class ContactsService {
  Future<List<SimpleContact>> getContacts() async {
    final permission = await FlutterContacts.requestPermission();
    if (!permission) {
      throw Exception('Permission not granted');
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    final simpleContacts = <SimpleContact>[];

    for (final contact in contacts) {
      final fullContact = await FlutterContacts.getContact(contact.id);
      if (fullContact == null || fullContact.phones.isEmpty) continue;

      // Create a SimpleContact for each phone number
      for (final phone in fullContact.phones) {
        simpleContacts.add(
          SimpleContact(
            name: contact.displayName,
            phone: phone.number,
            label: phone.label.name,
            photo: contact.photo,
          ),
        );
      }
    }

    return simpleContacts;
  }
}
