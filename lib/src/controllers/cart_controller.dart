import 'package:Gourmet2Go/src/helpers/app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {

  List<CartItem> carts = <CartItem>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;
  Restaurant restaurant;
  bool loading = true;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message, VoidCallback callback}) async {
    setState(() { loading = true; });
    carts.clear();
    final Stream<CartItem> stream = await getCart();
    stream.listen((CartItem _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          loading = false;
          settingRepo.coupon = _cart.food.applyCoupon(settingRepo.coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      setState(() { loading = false; });
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {

      setState(() { loading = false; });

      if (carts.isNotEmpty) {
        restaurant = carts[0].food.restaurant;
        calculateSubtotal();
      }

      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }

      onLoadingCartDone();
      setState((){});

      callback?.call();

    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context).carts_refreshed_successfuly);
  }

  void removeFromCart(CartItem _cart) async {
    setState(() {
      this.carts.remove(_cart);
      if(this.carts.isEmpty) {
        appData.clear();
      }
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_food_was_removed_from_your_cart(_cart.food.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.food.price;
      cart.extras.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });

    /*if (Helper.canDeliver(carts[0].food.restaurant, cartItems: carts)) {
      deliveryFee = carts[0].food.restaurant.deliveryFee;
    }*/

    deliveryFee = appData.orderType == 'Delivery' ? carts[0].food.restaurant.deliveryFee : 0;

    taxAmount = (subTotal + deliveryFee) * carts[0].food.restaurant.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    settingRepo.coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      settingRepo.coupon = _coupon;
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
//      saveCoupon(currentCoupon).then((value) => {
//          });
    });
  }

  incrementQuantity(CartItem cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(CartItem cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      if (carts[0].food.restaurant.closed) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_restaurant_is_closed_),
        ));
      } else {
        Navigator.of(context).pushNamed('/DeliveryPickup');
      }
    }
  }

  Color getCouponIconColor() {
    //print(coupon.toMap());
    if (settingRepo.coupon?.valid == true) {
      return Colors.green;
    } else if (settingRepo.coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context).focusColor.withOpacity(0.7);
  }

}
