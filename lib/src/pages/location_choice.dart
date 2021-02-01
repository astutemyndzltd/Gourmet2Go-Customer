import '../../src/controllers/location_controller.dart';
import '../../src/helpers/helper.dart';
import '../../src/models/address.dart';
import '../../src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationChoiceWidget extends StatelessWidget {
  final String topHeading = 'Find food near you';
  final String bottomCaption = 'We only access your location while you are using the app to improve your experience';
  final String locationSetText = 'Set your location to start exploring restaurants around you';
  final String currentLocationText = 'Use current location';
  final String manualLocationText = 'Set your location manually';

  final LocationChoiceController controller = new LocationChoiceController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topHeading,
                  style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 30, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/location-search.png',
                        width: 230,
                        height: 230,
                      ),
                      SizedBox(height: 40),
                      Text(
                        locationSetText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: 30),
                      TextButton(
                        child: Text(currentLocationText),
                        style: TextButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Theme.of(context).accentColor,
                          primary: Theme.of(context).primaryColor,
                          textStyle: Theme.of(context).textTheme.headline4,
                        ),
                        onPressed: () async {
                          await controller.pickLocationAutomatically(context);
                          if (deliveryAddress.value != null && deliveryAddress.value.isValid()) {
                            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                          } else {
                            scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Address could not be set')));
                          }
                        },
                      ),
                      TextButton(
                        child: Text(manualLocationText),
                        style: TextButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          primary: Theme.of(context).accentColor,
                          textStyle: Theme.of(context).textTheme.headline4,
                        ),
                        onPressed: () async {
                          await controller.pickLocationManually(context);

                          if (deliveryAddress.value != null && deliveryAddress.value.isValid()) {
                            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                          } else {
                            scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Address could not be set')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    bottomCaption,
                    style: Theme.of(context).textTheme.caption.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
