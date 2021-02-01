import '../../src/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:stripe_payment/stripe_payment.dart';

import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;

class CheckoutWidget extends StatefulWidget {
  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  CheckoutController _con;

  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
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
            S.of(context).checkout,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: _con.carts.isEmpty
            ? CircularLoadingWidget(height: 400)
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 255),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              leading: Icon(
                                Icons.payment,
                                color: Theme.of(context).hintColor,
                              ),
                              title: Text(
                                S.of(context).payment_mode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              subtitle: Text(
                                S.of(context).select_your_preferred_payment_mode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          new CreditCardsWidget(
                              creditCard: _con.creditCard,
                              onChanged: (creditCard) {
                                _con.updateCreditCard(creditCard);
                              }),
                          SizedBox(height: 40),
                          setting.value.payPalEnabled
                              ? Text(
                                  S.of(context).or_checkout_with,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          SizedBox(height: 40),
                          setting.value.payPalEnabled
                              ? SizedBox(
                                  width: 320,
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacementNamed('/PayPal');
                                    },
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    color: Theme.of(context).focusColor.withOpacity(0.2),
                                    shape: StadiumBorder(),
                                    child: Image.asset(
                                      'assets/img/paypal2.png',
                                      height: 28,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 210,
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
                                Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1)
                              ],
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).delivery_fee,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Helper.getPrice(_con.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                              ],
                            ),
                            SizedBox(height: 3),
                            /*Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "${S.of(context).tax} (${_con.carts[0].food.restaurant.defaultTax}%)",
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                              ],
                            ),*/
                            Divider(height: 20),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).total,
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline6)
                              ],
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: FlatButton(
                                onPressed: () async {
                                  if (_con.creditCard.validated()) {
                                    try {
                                      var cardInfo = _con.creditCard;

                                      var card = CreditCard(
                                        number: cardInfo.number,
                                        expMonth: int.parse(cardInfo.expMonth),
                                        expYear: int.parse(cardInfo.expYear),
                                        cvc: cardInfo.cvc,
                                      );

                                      StripePayment.setOptions(StripeOptions(publishableKey: settingRepo.setting.value.stripeKey));

                                      var paymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: card));

                                      var onSuccess = ()  {

                                        var details = {
                                          'subtotal' : _con.subTotal,
                                          'delivery_fee' : _con.deliveryFee,
                                          'tax' : _con.carts[0].food.restaurant.defaultTax,
                                          'tax_amount' : _con.taxAmount,
                                          'total' : _con.total
                                        };

                                        Navigator.of(context).pushNamed('/OrderSuccess', arguments: details);

                                      };

                                      var onError = () => _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Please try with a different card')));
                                      var onAuthenticationFailed = () => _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Authentication failed')));
                                      var onRestaurantNotAvailable = () => _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('The restaurant is neither open nor available for pre-order')));
                                      var onUnavailableForDelivery = () => _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('The restaurant is not available for delivery')));
                                      var onFoodOutOfStock = () => _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('One or more food items is currently out of stock')));

                                      _con.addOrder(paymentMethod, onAuthenticationFailed, onSuccess, onError, onRestaurantNotAvailable, onUnavailableForDelivery, onFoodOutOfStock);

                                    }
                                    on PlatformException catch (e) {
                                      _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text(e.message)));
                                    }
                                    on Exception catch (e) {
                                      print(e.toString());
                                      _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Some error occurred. Try again')));
                                    }
                                  }
                                  else {
                                    _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Enter all card details')));
                                  }
                                },
                                padding: EdgeInsets.symmetric(vertical: 14),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text(
                                  S.of(context).confirm_payment,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
