import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/state/interactions/interactions.dart';

List<Interaction> sortByUnreadAndDate(InteractionState state) {
  return List<Interaction>.from(state.interactions)
      .where((interaction) => interaction.name
          .toLowerCase()
          .contains(state.searchQuery.toLowerCase()))
      .toList();
}
