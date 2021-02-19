import 'package:Gourmet2Go/src/repository/settings_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';

class FoodController extends ControllerMVC {

  Food food;
  double quantity = 1;
  double total = 0;
  List<CartItem> cartItems = [];
  Favorite favorite;
  bool loadCart = false;
  bool loadFood = true;
  GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForFood({String foodId, String message}) async {

    setState(() => loadFood = true);

    final Stream<Food> stream = await getFood(foodId);
    stream.listen((Food _food) {
      setState(() {
        loadFood = false;
        food = _food;
      });
    }, onError: (a) {
      setState(() => loadFood = false);
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      setState(() => loadFood = false);
      calculateTotal();
      if (message != null) {
        scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFavorite({String foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      print(a);
    });
  }

  void listenForCart() async {
    setState(() { this.loadCart = true; });
    final cartStream = await getCart();
    cartStream.listen((cartItem) => cartItems.add(cartItem), onDone: () => setState(() { this.loadCart = false; }));
  }

  bool isSameRestaurants(Food food) {
    if (cartItems.isNotEmpty) {
      return cartItems[0].food?.restaurant?.id == food.restaurant?.id;
    }
    return true;
  }

  void addToCart(Food food, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });

    var newCartItem = new CartItem();
    newCartItem.food = food;
    newCartItem.extras = food.extras.where((element) => element.checked).toList();
    newCartItem.quantity = this.quantity;

    var oldCartItem = fetchOldItem(newCartItem);

    if (oldCartItem != null) {
      oldCartItem.quantity += quantity;
      await updateCart(oldCartItem);
    } else {
      var addedItem = await addCart(newCartItem, reset);
      newCartItem.id = addedItem.id;
      cartItems.add(newCartItem);
    }

    setState(() {
      this.loadCart = false;
    });
    scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Added to cart successfully')));
  }

  CartItem fetchOldItem(CartItem cartItem) {
    return cartItems.firstWhere((CartItem oldCartItem) => oldCartItem.isEqualTo(cartItem), orElse: () => null);
  }

  void addToFavorite(Food food) async {
    var _favorite = new Favorite();
    _favorite.food = food;
    _favorite.extras = food.extras.where((Extra _extra) {
      return _extra.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisFoodWasAddedToFavorite),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisFoodWasRemovedFromFavorites),
      ));
    });
  }

  Future<void> refreshFood() async {
    var _id = food.id;
    food = new Food();
    listenForFavorite(foodId: _id);
    listenForFood(foodId: _id, message: S.of(context).foodRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = food?.price ?? 0;
    food?.extras?.forEach((extra) {
      total += extra.checked ? extra.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity > 1) {
      --this.quantity;
      calculateTotal();
    }
  }


}
