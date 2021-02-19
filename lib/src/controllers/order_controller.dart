import 'dart:async';

import 'package:Gourmet2Go/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {

  List<Order> orders = <Order>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  StreamSubscription onMessageSubscription, onResumeSubscription, onLaunchSubscription;
  bool loading = true;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.setupFirebaseMessageListeners();
    listenForOrders();
  }

  setupFirebaseMessageListeners() {
    onMessageSubscription = firebaseMessagingStreams.onMessageStream.listen(onReceiveFirebaseMessage);
    onResumeSubscription = firebaseMessagingStreams.onResumeStream.listen(onReceiveFirebaseMessage);
    onLaunchSubscription = firebaseMessagingStreams.onLaunchStream.listen(onReceiveFirebaseMessage);
  }

  onReceiveFirebaseMessage(Map<String, dynamic> message) {
    orders = [];
    listenForOrders(message :'Refreshing orders');
  }

  void listenForOrders({String message}) async {
    setState(() { loading = true; });
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        print('hello darling');
        orders.add(_order);
        loading = false;
      });
    }, onError: (e) {
      setState(() { loading = false; });
      print(e);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      setState(() { loading = false; });
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void doCancelOrder(Order order) {
    cancelOrder(order).then((value) {
      setState(() {
        order.active = false;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      //refreshOrders();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).orderThisorderidHasBeenCanceled(order.id)),
      ));
    });
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.of(context).order_refreshed_successfuly);
  }

  @override
  void dispose() {
    onMessageSubscription.cancel();
    onResumeSubscription.cancel();
    onLaunchSubscription.cancel();
    super.dispose();
  }

}
