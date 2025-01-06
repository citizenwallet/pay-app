


import 'package:pay_app/models/interaction.dart';
import 'package:pay_app/state/interactions/interactions.dart';

 List<Interaction> sortByUnreadAndDate(InteractionState state) {
  return List<Interaction>.from(state.interactions)..sort((a, b) {
    // First, sort by unread status
    if (a.hasUnreadMessages != b.hasUnreadMessages) {
      return a.hasUnreadMessages ? -1 : 1; // Unread messages go first
    }
    
    // If both have same unread status, sort by date (most recent first)
    if (a.lastMessageAt == null || b.lastMessageAt == null) {
      return 0; // Handle null dates if they exist
    }
    return b.lastMessageAt!.compareTo(a.lastMessageAt!);
  });
}