import 'dart:async';

import '../../src/models/dispatchmethod.dart';

import '../models/cuisine.dart';
import '../repository/cuisine_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {

  OverlayEntry overlayLoader;

  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Restaurant> showableRestaurants = null;
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  List<Cuisine> cuisines = <Cuisine>[];
  List<Restaurant> nearbyRestaurants = null;
  List<Restaurant> popularRestaurantsNearby = <Restaurant>[];

  bool listeningForNearbyRestaurants = false;
  bool listeningForPopularRestaurants = false;

  HomeController() {
    loadData();
  }

  loadData() {
    bool f1Done = false, f2Done = false, f3Done = false/*, f4Done = false*/;

    VoidCallback refreshState = () {
      bool allDone = f1Done && f2Done && f3Done /*&& f4Done*/;

      if (allDone) {
        overlayLoader.remove();
        setState(() {});
      }

    };

    var future1 = listenForNearbyRestaurants();
    var future2 = listenForCuisines();
    var future3 = listenForPopularRestaurants();
    //var future4 = listenForRecentReviews();

    future1.whenComplete(() {
      f1Done = true;
      refreshState();
    });
    future2.whenComplete(() {
      f2Done = true;
      refreshState();
    });
    future3.whenComplete(() {
      f3Done = true;
      refreshState();
    });
    /*future4.whenComplete(() {
      f4Done = true;
      refreshState();
    });*/
  }

  Future<void> refreshHome() async {
    bool f1Done = false, f2Done = false, f3Done = false/*, f4Done = false*/;

    overlayLoader = Helper.overlayLoader(context);
    Overlay.of(context).insert(overlayLoader);

    VoidCallback removeLoader = () {
      bool allDone = f1Done && f2Done && f3Done /*&& f4Done*/;

      if (allDone) {
        overlayLoader.remove();
        setState(() {});
      }
    };

    var future1 = listenForNearbyRestaurants();
    var future2 = listenForCuisines();
    var future3 = listenForPopularRestaurants();
    //var future4 = listenForRecentReviews();

    future1.whenComplete(() {
      f1Done = true;
      removeLoader();
    });

    future2.whenComplete(() {
      f2Done = true;
      removeLoader();
    });

    future3.whenComplete(() {
      f3Done = true;
      removeLoader();
    });

    /*future4.whenComplete(() {
      f4Done = true;
      removeLoader();
    });*/

  }

  Future<void> listenForNearbyRestaurants() async {
    listeningForNearbyRestaurants = true;
    nearbyRestaurants = await getNearbyRestaurants();
    showableRestaurants = [];

    for (var restaurant in nearbyRestaurants) {
      if (settingsRepo.appData.dispatchMethod == DispatchMethod.delivery && !restaurant.isAvailableForDelivery()) continue;
      if (settingsRepo.appData.dispatchMethod == DispatchMethod.pickup && !restaurant.isAvailableForPickup()) continue;
      if (settingsRepo.appData.dispatchMethod == DispatchMethod.preorder && !restaurant.isClosedAndAvailableForPreorder()) continue;
      if (settingsRepo.appData.dispatchMethod == DispatchMethod.none && !restaurant.isCurrentlyOpen() && !restaurant.openingLaterToday()) continue;
      showableRestaurants.add(restaurant);
    }

    listeningForNearbyRestaurants = false;

    if (!listeningForNearbyRestaurants && !listeningForPopularRestaurants) loadPopularRestaurants();
  }

  Future<void> listenForCuisines() async {
    cuisines = await getCuisinesNew();
  }

  Future<void> listenForPopularRestaurants() async {
    listeningForPopularRestaurants = true;
    popularRestaurants = await getNearbyPopularRestaurants();
    listeningForPopularRestaurants = false;
    if (!listeningForNearbyRestaurants && !listeningForPopularRestaurants) loadPopularRestaurants();
  }

  void loadPopularRestaurants() {
    popularRestaurantsNearby.clear();
    var map = Map<String, Restaurant>();
    nearbyRestaurants.forEach((r) => map[r.id] = r);

    for (var p in popularRestaurants) {
      if (map[p.id] != null) {
        popularRestaurantsNearby.add(p);
      }
    }
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    recentReviews.clear();
    stream.listen((r) => recentReviews.add(r));
  }

  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopRestaurants() async {
    final Stream<Restaurant> stream = await getNearRestaurants(settingsRepo.deliveryAddress.value, settingsRepo.deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => showableRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingFoods() async {
    final Stream<Food> stream = await getTrendingFoods(settingsRepo.deliveryAddress.value);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    settingsRepo.setCurrentLocation().then((_address) async {
      settingsRepo.deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }


}
