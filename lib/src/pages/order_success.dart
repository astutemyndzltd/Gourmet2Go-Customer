import 'package:Gourmet2Go/src/helpers/app_data.dart';

import '../../src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';


class OrderSuccessWidget extends StatelessWidget {

  final Map<String, dynamic> orderDetails;

  OrderSuccessWidget({Key key, this.orderDetails}) : super(key: key);

  Widget build(BuildContext context) {

    appData.clear();

    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/Pages', arguments: 2);
              },
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).hintColor,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              S.of(context).confirmation,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            ),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional.center,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                                Colors.green.withOpacity(1),
                                Colors.green.withOpacity(0.2),
                              ])),
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 90,
                          ),
                        ),
                        Positioned(
                          right: -30,
                          bottom: -50,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          top: -50,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        S.of(context).your_order_has_been_successfully_submitted,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                      ),
                    ),
                  ],
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
                        // subtotal
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                S.of(context).subtotal,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Helper.getPrice(orderDetails['subtotal'], context, style: Theme.of(context).textTheme.subtitle1)
                          ],
                        ),
                        SizedBox(height: 3),
                        // delivery fee
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                S.of(context).delivery_fee,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Helper.getPrice(orderDetails['delivery_fee'], context, style: Theme.of(context).textTheme.subtitle1)
                          ],
                        ),
                        SizedBox(height: 3),
                        // tax
                        /*Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "${S.of(context).tax} (${orderDetails['tax']}%)",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Helper.getPrice(orderDetails['tax_amount'], context, style: Theme.of(context).textTheme.subtitle1)
                          ],
                        ),*/
                        Divider(height: 20),
                        // total
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                S.of(context).total,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Helper.getPrice(orderDetails['total'], context, style: Theme.of(context).textTheme.headline6)
                          ],
                        ),
                        SizedBox(height: 20),
                        // my orders
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/Pages', arguments: 3);
                            },
                            padding: EdgeInsets.symmetric(vertical: 14),
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child: Text(
                              S.of(context).my_orders,
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
              )
            ],
          )),
    );

  }

}
