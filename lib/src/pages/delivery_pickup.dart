import 'dart:async';
import 'dart:ui';

import 'package:Gourmet2Go/src/elements/CircularLoadingWidget.dart';
import 'package:Gourmet2Go/src/helpers/app_data.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  bool isCurrentlyOpen = false, isAvailableForOrders = false, isAvailableForPreorders = false, isAvailableForDelivery = false;
  int tabLength = 0, totalSlotsLength = 0;
  Map<String, List<String>> timesForWeek = null;
  Iterable<MapEntry<String, List<String>>> daysWithSlots = null;
  String today = null, tomorrow = null;
  int selectedSlotTabIndex = null, selectedSlotCellIndex = null;
  ScrollController scrollController = new ScrollController();
  Completer<TabController> tabControllerCompleter = new Completer();

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
  }

  @override
  void initState() {
    () async {
      if (appData.preorderData != null) {
        selectedSlotTabIndex = appData.preorderData.selectedSlotTabIndex;
        selectedSlotCellIndex = appData.preorderData.selectedSlotCellIndex;
        _con.radioState = 'later';
        (await tabControllerCompleter.future).animateTo(selectedSlotTabIndex);
      }
    }.call();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var restaurant = _con.restaurant;

    if (restaurant != null) {
      timesForWeek = restaurant.generateTimesForWeek();
      daysWithSlots = timesForWeek.entries.where((e) => e.value.length > 0);
      today = timesForWeek.keys.elementAt(0);
      tomorrow = timesForWeek.keys.elementAt(1);
      totalSlotsLength = daysWithSlots.length > 0 ? daysWithSlots.map((e) => e.value.length).reduce((v, e) => v += e) : 0;
      tabLength = daysWithSlots.length;
      isCurrentlyOpen = restaurant.isCurrentlyOpen();
      isAvailableForPreorders = restaurant.availableForPreorder && totalSlotsLength > 0;
      isAvailableForOrders = isCurrentlyOpen || isAvailableForPreorders;
      isAvailableForDelivery = isAvailableForOrders && restaurant.availableForDelivery;
      if (!isCurrentlyOpen) _con.radioState = 'later';
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
              //ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
            ],
          ),
          body: _con.restaurant == null
              ? CircularLoadingWidget(height: 400)
              : SingleChildScrollView(
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
                          },
                        ),
                      // delivery method option
                      if (isAvailableForDelivery && Helper.canDeliver(_con.restaurant, cartItems: _con.carts))
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
                                subtitle:  _con.carts.isNotEmpty && Helper.canDeliver(_con.carts[0].food.restaurant, cartItems: _con.carts)
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
                      if (isAvailableForPreorders)
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
                              padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 25),
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
                                              appData.preorderData = null;
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
                                        if (isCurrentlyOpen)
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
                                      child: Builder(builder: (BuildContext c) {
                                        final tabController = DefaultTabController.of(c);

                                        if (!tabControllerCompleter.isCompleted) {
                                          tabControllerCompleter.complete(tabController);
                                          tabController.addListener(() => setState(() {}));
                                        }

                                        return Column(
                                          children: [
                                            TabBar(
                                              isScrollable: true,
                                              tabs: [
                                                for (int i = 0; i < daysWithSlots.length; i++)
                                                  Tab(
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Text(
                                                        daysWithSlots.elementAt(i).key == today
                                                            ? 'Today'
                                                            : daysWithSlots.elementAt(i).key == tomorrow
                                                                ? 'Tomorrow'
                                                                : daysWithSlots.elementAt(i).key.substring(0, 1).toUpperCase() + daysWithSlots.elementAt(i).key.substring(1),
                                                        style: tabController.index == i ? Theme.of(context).textTheme.headline4.copyWith(fontSize: 16, fontWeight: FontWeight.bold) : Theme.of(context).textTheme.headline4.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Container(
                                              height: 110,
                                              //color: Colors.green,
                                              child: TabBarView(
                                                physics: NeverScrollableScrollPhysics(),
                                                children: [
                                                  //time slots
                                                  for (int i = 0; i < daysWithSlots.length; i++)
                                                    Center(
                                                      child: Container(
                                                        height: 35,
                                                        child: ListView.separated(
                                                          scrollDirection: Axis.horizontal,
                                                          itemBuilder: (context, index) {
                                                            return TextButton(
                                                              child: Text(daysWithSlots.elementAt(i).value[index]),
                                                              style: TextButton.styleFrom(
                                                                minimumSize: Size(105, 0),
                                                                backgroundColor: (selectedSlotTabIndex == i && selectedSlotCellIndex == index) ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.1),
                                                                primary: (selectedSlotTabIndex == i && selectedSlotCellIndex == index) ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                                                textStyle: Theme.of(context).textTheme.headline4.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                                                              ),
                                                              onPressed: () {
                                                                selectedSlotTabIndex = tabController.index;
                                                                selectedSlotCellIndex = index;

                                                                var entry = daysWithSlots.elementAt(i);
                                                                var day = entry.key;
                                                                var time = entry.value[index];
                                                                var dateTime = DateTime.now();
                                                                var daysToAdd = timesForWeek.keys.toList().indexOf(day);
                                                                var date = DateFormat('yyyy-MM-dd').format(dateTime.add(Duration(days: daysToAdd)));
                                                                var info = (day != today ? '${date}, ' : '') + time;

                                                                appData.preorderData = PreorderData(selectedSlotTabIndex, selectedSlotCellIndex, day, time, info);
                                                                setState(() {});
                                                              },
                                                            );
                                                          },
                                                          separatorBuilder: (c, i) => SizedBox(width: 15),
                                                          itemCount: daysWithSlots.elementAt(i).value.length,
                                                        ),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
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
