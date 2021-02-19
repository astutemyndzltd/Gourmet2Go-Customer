import 'package:Gourmet2Go/src/helpers/app_data.dart';

import '../../src/controllers/delivery_pickup_controller.dart';

import '../repository/settings_repository.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

class CartBottomDetailsWidget extends StatelessWidget {

  CartBottomDetailsWidget({Key key, @required CartController con}): _con = con, super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: 160,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: '0')
                    ],
                  ),
                  SizedBox(height: 1),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(
                        _con.deliveryFee,
                        context,
                        style: Theme.of(context).textTheme.subtitle1,
                        zeroPlaceholder: '-',
                      )
                    ],
                  ),
                  /*Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Tax (${_con.carts[0].food.restaurant.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),*/
                  SizedBox(height: 10),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: FlatButton(
                          onPressed: () {

                            if (!_con.restaurant.isCurrentlyOpen() && !_con.restaurant.isAvailableForPreorder()) {
                              _con.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("The restaurant is neither open nor available for pre-order")));
                              //Helper.showSnackbar(context, "The restaurant is neither open nor available for pre-order");
                              return;
                            }

                            if (_con is DeliveryPickupController) {
                              var con = _con as DeliveryPickupController;

                              if (con.getSelectedMethod() == null) {
                                _con.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Please select delivery or pickup')));
                                //Helper.showSnackbar(context, "Please select delivery or pickup");
                                return;
                              }

                              if (con.radioState == 'later' && appData.preorderData == null) {
                                //Helper.showSnackbar(context, "Please select ${orderType.toLowerCase()} time");
                                _con.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please select ${appData.orderType.toLowerCase()} time")));
                                return;
                              }

                            }

                            for (int i = 0; i < _con.carts.length; i++) {
                              var food = _con.carts[i].food;

                              if (food.outOfStock) {
                                _con.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("We're sorry, one or more food items in your cart are currently sold out")));
                                //Helper.showSnackbar(context, "We're sorry, one or more food items in your cart are currently sold out");
                                return;
                              }

                            }

                            if (_con.subTotal < _con.restaurant.minOrderAmount) {
                              //Helper.showSnackbar(context, 'Minimum amount to place order with this restaurant is ${setting.value?.defaultCurrency}${_con.restaurant.minOrderAmount}. Your current order total is ${setting.value?.defaultCurrency}${_con.subTotal}');
                              _con.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Minimum amount to place order with this restaurant is ${setting.value?.defaultCurrency}${_con.restaurant.minOrderAmount}. Your current order total is ${setting.value?.defaultCurrency}${_con.subTotal}')));
                            } else {
                              _con.goCheckout(context);
                            }
                          },
                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          color: !_con.carts[0].food.restaurant.closed ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Text(
                            S.of(context).checkout,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)), zeroPlaceholder: 'Free'),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
