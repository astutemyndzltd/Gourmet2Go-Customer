import 'dart:ui';

import '../../src/repository/settings_repository.dart';
import 'package:collapsible/collapsible.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  DeliveryPickupWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController _con;

  ScrollController scrollController = new ScrollController();
  int tabIndex = 0, buttonIndex = null;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
    preorderInfo = '';
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentlyOpen = _con.restaurant != null && _con.restaurant.isCurrentlyOpen();
    bool isAvailableForOrders = _con.restaurant != null && (isCurrentlyOpen || _con.restaurant.isAvailableForPreorder());
    bool isAvailableForPreorders = _con.restaurant != null && _con.restaurant.isAvailableForPreorder();
    bool isAvailableForDelivery = isAvailableForOrders && _con.restaurant.availableForDelivery;
    List<String> timesForToday = [], timesForTomorrow = [];
    int tabLength = 0, totalSlotsLength = 0;

    if (_con.restaurant != null) {
      timesForToday = _con.restaurant.generateTimesForToday();
      timesForTomorrow = _con.restaurant.generateTimesForTomorrow();
      if (timesForToday.length > 0) tabLength++;
      if (timesForTomorrow.length > 0) tabLength++;
      totalSlotsLength = timesForToday.length + timesForTomorrow.length;
      if(!isCurrentlyOpen) _con.radioState = 'later';
    }

    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
    }

    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        body: Scaffold(
          bottomNavigationBar: CartBottomDetailsWidget(con: _con),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).hintColor,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              S.of(context).delivery_or_pickup,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            ),
            actions: <Widget>[
              ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // pickup food from restaurant heading
                if (isAvailableForOrders)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.domain,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).pickup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context).pickup_your_food_from_the_restaurant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                // click to select pickup
                if (isAvailableForOrders)
                  PickUpMethodItem(
                      paymentMethod: _con.getPickUpMethod(),
                      checkedFromStart: isAvailableForOrders && !isAvailableForDelivery,
                      onPressed: (paymentMethod) {
                        _con.togglePickUp();
                      }),
                // delivery method option
                if (isAvailableForDelivery)
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.map,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            S.of(context).delivery,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          subtitle: _con.carts.isNotEmpty && Helper.canDeliver(_con.carts[0].food.restaurant, cartItems: _con.carts)
                              ? Text(
                            S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          )
                              : Text(
                            S.of(context).deliveryMethodNotAllowed,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                      _con.carts.isNotEmpty && Helper.canDeliver(_con.carts[0].food.restaurant, cartItems: _con.carts)
                          ? DeliveryAddressesItemWidget(
                        paymentMethod: _con.getDeliveryMethod(),
                        address: _con.deliveryAddress,
                        onPressed: (Address _address) {
                          if (_con.deliveryAddress.id == null || _con.deliveryAddress.id == 'null') {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.addAddress(_address);
                              },
                            );
                          } else {
                            _con.toggleDelivery();
                          }
                        },
                        onLongPress: (Address _address) {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (Address _address) {
                              _con.updateAddress(_address);
                            },
                          );
                        },
                      )
                          : NotDeliverableAddressesItemWidget()
                    ],
                  ),
                // preorder section
                if (isAvailableForPreorders && totalSlotsLength > 0)
                  Column(
                    children: <Widget>[
                      // get it by heading
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.local_shipping,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            'Get it by',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          subtitle: Text(
                            'Select your preferred time',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                      // preorder rows and tab
                      Container(
                        padding: EdgeInsets.only(left: 20, right:20, top: 15, bottom: 25),
                        decoration: BoxDecoration(
                          //color: Colors.tealAccent,
                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // now row
                            if (isCurrentlyOpen)
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                                height: 55,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.timer),
                                    SizedBox(width: 13),
                                    Text(
                                      'Now',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Radio(
                                      value: 'now',
                                      groupValue: _con.radioState,
                                      activeColor: Theme.of(context).accentColor,
                                      focusColor: Theme.of(context).accentColor,
                                      onChanged: (v) {
                                        setState(() => _con.radioState = v);
                                        preorderInfo = '';
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            // later row
                            Container(
                              padding: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                              height: 55,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(Icons.timer),
                                  SizedBox(width: 13),
                                  Text(
                                    'Later',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.w500, fontSize: 17),
                                  ),
                                  Expanded(child: SizedBox()),
                                  if(isCurrentlyOpen)
                                    Radio(
                                      value: 'later',
                                      groupValue: _con.radioState,
                                      activeColor: Theme.of(context).accentColor,
                                      focusColor: Theme.of(context).accentColor,
                                      onChanged: (v) {
                                        setState(() => _con.radioState = v);
                                        Future.delayed(Duration(milliseconds: 500), () {
                                          scrollController.animateTo(
                                            scrollController.position.maxScrollExtent,
                                            duration: Duration(milliseconds: 1500),
                                            curve: Curves.easeOut,
                                          );
                                        });
                                      },
                                    )
                                ],
                              ),
                            ),
                            // timeslots
                            Collapsible(
                              collapsed: _con.radioState == 'now',
                              axis: CollapsibleAxis.vertical,
                              child: DefaultTabController(
                                length: tabLength,
                                child: Column(
                                  children: [
                                    TabBar(
                                      tabs: [
                                        if (timesForToday.length > 0)
                                          Tab(
                                            child: Text(
                                              'Today',
                                              style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        if (timesForTomorrow.length > 0)
                                          Tab(
                                            child: Text(
                                              'Tomorrow',
                                              style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Container(
                                      height: 110,
                                      //color: Colors.green,
                                      child: TabBarView(
                                        children: [
                                          // today time slots
                                          if (timesForToday.length > 0)
                                            Center(
                                              child: Container(
                                                height: 35,
                                                child: ListView.separated(
                                                    scrollDirection: Axis.horizontal,
                                                    itemBuilder: (context, index) {
                                                      return TextButton(
                                                        child: Text(timesForToday[index]),
                                                        style: TextButton.styleFrom(
                                                          minimumSize: Size(105, 0),
                                                          backgroundColor: (tabIndex == 0 && buttonIndex == index) ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.1),
                                                          primary: (tabIndex == 0 && buttonIndex == index) ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                                          textStyle: Theme.of(context).textTheme.headline4.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                                                        ),
                                                        onPressed: () {
                                                          // yet to be implemented
                                                          setState(() {
                                                            buttonIndex = index;
                                                            tabIndex = 0;
                                                          });
                                                          preorderInfo = timesForToday[index];
                                                        },
                                                      );
                                                    },
                                                    separatorBuilder: (c, i) => SizedBox(width: 15),
                                                    itemCount: timesForToday.length),
                                              ),
                                            ),
                                          // tomorrow time slots
                                          if (timesForTomorrow.length > 0)
                                            Center(
                                              child: Container(
                                                height: 35,
                                                child: ListView.separated(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index) {
                                                    return TextButton(
                                                      child: Text(timesForTomorrow[index]),
                                                      style: TextButton.styleFrom(
                                                        minimumSize: Size(105, 0),
                                                        backgroundColor: (tabIndex == 1 && buttonIndex == index) ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.1),
                                                        primary: (tabIndex == 1 && buttonIndex == index) ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                                        textStyle: Theme.of(context).textTheme.headline4.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                                                      ),
                                                      onPressed: () {
                                                        // yet to be implemented
                                                        setState(() {
                                                          buttonIndex = index;
                                                          tabIndex = 1;
                                                        });
                                                        var tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
                                                        preorderInfo = '${tomorrow}, ${timesForTomorrow[index]}';
                                                      },
                                                    );
                                                  },
                                                  separatorBuilder: (c, i) => SizedBox(width: 15),
                                                  itemCount: timesForTomorrow.length,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
