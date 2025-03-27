import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/state/contacts/contacts.dart';

List<SimpleContact> selectFilteredContacts(ContactsState state) =>
    List<SimpleContact>.from(state.contacts)
        .where((contact) => contact.name
            .toLowerCase()
            .contains(state.searchQuery.toLowerCase()))
        .toList();
