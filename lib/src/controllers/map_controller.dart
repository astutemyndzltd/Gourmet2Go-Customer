import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as sett;

class MapController extends ControllerMVC {
  Restaurant currentRestaurant;
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  Address currentAddress;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  MapsUtil mapsUtil = new MapsUtil();
  Completer<GoogleMapController> mapController = Completer();
  VoidCallback onRestaurantFetchCompleted;

  // fetches nearby restaurant from api
  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    var restaurants = await getNearbyRestaurants();

    for (var res in restaurants) {
      if (res.isCurrentlyOpen() || res.isClosedAndAvailableForPreorder() || res.openingLaterToday()) {
        topRestaurants.add(res);
        setState(() {});
        if (currentRestaurant != null) continue;
        var marker = await Helper.getMarker(res.toMap());
        allMarkers.add(marker);
        setState(() {});
      }
    }

    onRestaurantFetchCompleted?.call();
  }

  // set camera focus to current location and sets a marker at current location
  void getCurrentLocation() async {
    try {
      currentAddress = sett.deliveryAddress.value;
      setState(() {
        if (!currentAddress.isValid()) {
          cameraPosition = CameraPosition(
            target: LatLng(40, 3),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress.latitude, currentAddress.longitude),
            zoom: 14.4746,
          );
        }
      });

      if (currentAddress.isValid()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  // set camera focus to clicked restaurant's address and sets a marker at current location
  void getRestaurantLocation() async {
    try {
      currentAddress = await sett.getCurrentLocation();

      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(currentRestaurant.latitude), double.parse(currentRestaurant.longitude)),
          zoom: 14.4746,
        );
      });

      if (currentAddress.isValid()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }

      Helper.getMarker(currentRestaurant.toMap()).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((_currentAddress) {
      setState(() {
        sett.deliveryAddress.value = _currentAddress;
        currentAddress = _currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
        zoom: 14.4746,
      )));
    });
  }

  void getRestaurantsOfArea() async {
    setState(() {
      topRestaurants = <Restaurant>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearRestaurants(currentAddress, areaAddress);
      } else {
        listenForNearRestaurants(currentAddress, currentAddress);
      }
    });
  }

  void getDirectionSteps() async {
    currentAddress = await sett.getCurrentLocation();

    if (currentAddress.isValid()) {
      mapsUtil.get("origin=" + currentAddress.latitude.toString() + "," + currentAddress.longitude.toString() + "&destination=" + currentRestaurant.latitude + "," + currentRestaurant.longitude + "&key=${sett.setting.value?.googleMapsKey}").then((dynamic res) {
        if (res != null) {
          var latLng = res as List<LatLng>;
          latLng?.insert(0, LatLng(currentAddress.latitude, currentAddress.longitude));

          setState(() {
            polylines.add(
              Polyline(
                  visible: true,
                  polylineId: new PolylineId(currentAddress.hashCode.toString()),
                  points: latLng,
                  color: Colors.green,
                  width: 3
              ),
            );
          });
        }
      });
    }
  }

  void addDirectionForRestaurant(Restaurant restaurant) async {
    currentAddress = await sett.getCurrentLocation();

    if (currentAddress.isValid()) {
      mapsUtil.get("origin=" + currentAddress.latitude.toString() + "," + currentAddress.longitude.toString() + "&destination=" + restaurant.latitude + "," + restaurant.longitude + "&key=${sett.setting.value?.googleMapsKey}").then((dynamic res) {
        if (res != null) {
          var latLng = res as List<LatLng>;
          latLng?.insert(0, LatLng(currentAddress.latitude, currentAddress.longitude));

          setState(() {
            polylines.add(
              Polyline(
                visible: true,
                polylineId: new PolylineId(restaurant.hashCode.toString()),
                points: latLng,
                color: Colors.green,
                width: 3,
              ),
            );
          });
        }
      });
    }
  }

  Future refreshMap() async {
    setState(() {
      topRestaurants = <Restaurant>[];
    });
    listenForNearRestaurants(currentAddress, currentAddress);
  }

  void showNearbyRestaurantsRoutes() async {
    for (var res in topRestaurants) await addDirectionForRestaurant(res);
    onRestaurantFetchCompleted = null;
  }
}
