import 'package:pay_app/models/place.dart';
import 'package:pay_app/state/places/places.dart';

List<Place> selectFilteredPlaces(PlacesState state) => state.searchQuery.isEmpty
    ? List<Place>.from(state.places)
    : List<Place>.from(state.places)
        .where((place) =>
            place.name.toLowerCase().contains(state.searchQuery.toLowerCase()))
        .toList();
