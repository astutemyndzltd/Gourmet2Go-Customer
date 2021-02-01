import 'dart:async';

import '../../src/models/address.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../src/repository/settings_repository.dart';
import '../../src/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LocationChoiceController extends ControllerMVC {

  Future pickLocationAutomatically(BuildContext context) async {
    var loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    var address = await pickAndSetLocationAutomatically();
    deliveryAddress.value = address;
    loader.remove();
  }

  Future pickLocationManually(BuildContext bc) async {

    var locationResult = await showLocationPicker(
      bc,
      setting.value.googleMapsKey,
      initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0, deliveryAddress.value?.longitude ?? 0),
      myLocationButtonEnabled: true,
    );

    if (locationResult != null) {
      deliveryAddress.value = await setLocationManually(locationResult);
    }

  }

}
