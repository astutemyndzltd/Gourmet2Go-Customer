import '../../src/repository/restaurant_repository.dart';

import '../repository/settings_repository.dart';
import '../models/restaurant.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RestaurantResultController extends ControllerMVC {
  List<Restaurant> foundRestaurants = <Restaurant>[];
  String typeId;

  RestaurantResultController(this.typeId) {
    listenForRestaurants(typeId);
  }

  void listenForRestaurants(String typeId) async {
    final stream =
        await getRestaurantsOfCuisineType(typeId, deliveryAddress.value);

    stream.listen((Restaurant _restaurant) {
      setState(() => foundRestaurants.add(_restaurant));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }
}
