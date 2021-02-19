import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/favorite.dart';
import '../repository/food_repository.dart';

class FavoriteController extends ControllerMVC {

  List<Favorite> favorites = <Favorite>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = true;


  FavoriteController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFavorites();
  }

  void listenForFavorites({String message}) async {
    setState(() => loading = true);
    final Stream<Favorite> stream = await getFavorites();
    stream.listen((Favorite _favorite) {
      setState(() {
        loading = false;
        favorites.add(_favorite);
      });
    }, onError: (a) {
      setState(() => loading = false);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      setState(() => loading = false);
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshFavorites() async {
    favorites.clear();
    listenForFavorites(message: S.of(context).favorites_refreshed_successfuly);
  }


}
