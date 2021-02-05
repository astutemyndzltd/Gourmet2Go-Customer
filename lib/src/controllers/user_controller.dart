import '../../src/models/address.dart';
import '../../src/repository/settings_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {

  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging firebaseMessaging;
  OverlayEntry loader;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  bool isValidEmail(String email) {
    var regex = RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(email);
  }

  Future<Address> addAddress(Address address) async {
    return await repository.addAddress(address);
  }

  void login() async {
    FocusScope.of(context).unfocus();

    if (!await isConnectedToInternet()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Verify your internet connection')));
      return;
    }

    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) async {
        if (value != null && value.apiToken != null) {
          if (deliveryAddress.value != null) {
            var address = await this.addAddress(deliveryAddress.value);
            await changeLocation(address);
            deliveryAddress.value = address;
          }

          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {

    FocusScope.of(context).unfocus();

    if (!await isConnectedToInternet()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Verify your internet connection')));
      return;
    }

    if (loginFormKey.currentState.validate()) {

      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);

      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
          });
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('Registration successful'),
          ));
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader?.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void resetPassword() async {
    bool succeeded = false;

    FocusScope.of(context).unfocus();

    if (!await isConnectedToInternet()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Verify your internet connection')));
      return;
    }

    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          succeeded = true;
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
        if (!succeeded) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('Email not registered'),
          ));
        }
      });
    }
  }


}
