import 'package:pay_app/models/place.dart';
import 'package:pay_app/state/places/places.dart';

List<Place> selectFilteredPlaces(PlacesState state) =>
    List<Place>.from(state.places)
        .where((place) =>
            place.name.toLowerCase().contains(state.searchQuery.toLowerCase()))
        .toList();
