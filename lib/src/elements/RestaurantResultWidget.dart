import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../models/cuisine.dart';
import '../controllers/restaurantresult_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CardWidget.dart';
import '../models/route_argument.dart';

class RestaurantResultWidget extends StatefulWidget {
  final Cuisine cuisine;

  RestaurantResultWidget(final this.cuisine);

  @override
  _RestaurantResultWidgetState createState() {
    // TODO: implement createState
    return new _RestaurantResultWidgetState(cuisine);
  }
}

class _RestaurantResultWidgetState extends StateMVC<RestaurantResultWidget> {
  final Cuisine cuisine;
  RestaurantResultController _con;

  _RestaurantResultWidgetState(final this.cuisine)
      : super(new RestaurantResultController(cuisine.id)) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 0),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              trailing: IconButton(
                icon: Icon(Icons.close),
                color: Theme.of(context).hintColor,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                "${cuisine.name} Cuisines",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          /****************************beakar******************/
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: Text(
                "Restaurant Results",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: Text("Ordered by nearby first",
                  style: Theme.of(context).textTheme.caption),
            ),
          ),
          _con.foundRestaurants.isEmpty
              ? CircularLoadingWidget(height: 288)
              : Expanded(
                  child: ListView(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.foundRestaurants.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Details',
                                  arguments: RouteArgument(
                                    id: '0',
                                    param: _con.foundRestaurants
                                        .elementAt(index)
                                        .id,
                                    heroTag: widget.cuisine.name,
                                  ));
                            },
                            child: CardWidget(
                                restaurant:
                                    _con.foundRestaurants.elementAt(index),
                                heroTag: widget.cuisine.name),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ]));
  }
}
