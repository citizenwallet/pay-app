import 'package:pay_app/services/contacts/contacts.dart';
import 'package:pay_app/state/contacts/contacts.dart';

List<SimpleContact> selectFilteredContacts(ContactsState state) =>
    state.searchQuery.isEmpty
        ? List<SimpleContact>.from(state.contacts)
        : List<SimpleContact>.from(state.contacts)
            .where((contact) => contact.name
                .toLowerCase()
                .contains(state.searchQuery.toLowerCase()))
            .toList();

SimpleContact? selectCustomContact(ContactsState state) =>
    state.customContactProfile != null &&
            state.customContact != null &&
            state.customContactProfile!.name.isNotEmpty
        ? SimpleContact(
            name:
                '${state.customContactProfile?.name} (@${state.customContactProfile?.username})',
            phone: state.customContact!.phone,
            imageUrl: state.customContactProfile!.imageSmall,
          )
        : state.customContact;
