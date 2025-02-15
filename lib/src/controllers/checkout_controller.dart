import 'package:Gourmet2Go/src/helpers/app_config.dart';
import 'package:Gourmet2Go/src/helpers/app_data.dart';

import '../../src/helpers/helper.dart';
import '../../src/repository/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart' as stripe;
import 'package:stripe_payment/stripe_payment.dart';
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart' as guru;
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment payment;
  guru.CreditCard creditCard;
  bool processingOrder = false;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.payment = new Payment('Credit Card');
    this.listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  void addOrder(PaymentMethod paymentMethod, VoidCallback onAuthenticationFailed, VoidCallback onSuccess, VoidCallback onError, VoidCallback onRestaurantNotAvailable, VoidCallback onUnavailableForDelivery, VoidCallback onFoodOutOfStock, VoidCallback onValidationError) async {

    var order = Order();
    order.orderType = appData.orderType;
    order.note = appData.orderNote ?? '';
    order.foodOrders = List<FoodOrder>();
    order.tax = carts[0].food.restaurant.defaultTax;
    order.deliveryFee = order.orderType == 'Pickup' ? 0 : carts[0].food.restaurant.deliveryFee;

    var orderStatus = new OrderStatus();
    orderStatus.id = '1';
    order.orderStatus = orderStatus;
    order.deliveryAddress = settingRepo.deliveryAddress.value;

    for (var cartItem in carts) {
      var foodOrder = new FoodOrder();
      foodOrder.quantity = cartItem.quantity;
      foodOrder.price = cartItem.food.price;
      foodOrder.food = cartItem.food;
      foodOrder.extras = cartItem.extras;
      order.foodOrders.add(foodOrder);
    }

    /// validation ====================================================================================

    for (var item in carts) {
      if (item.food.outOfStock) {
        onFoodOutOfStock?.call();
        return;
      }
    }

    //////////////////////////////////////////////////////////////

    bool isPreOrder = appData.preorderData != null;

    if (isPreOrder) {
      var preorderData = appData.preorderData;
      order.preorderInfo = preorderData.info;
      if (!restaurant.isAvailableForOrderOn(preorderData.day, preorderData.time)) {
        onRestaurantNotAvailable?.call();
        return;
      }
    } else {
      order.preorderInfo = '';
      if (!restaurant.isCurrentlyOpen()) {
        onRestaurantNotAvailable?.call();
        return;
      }
    }

    ////////////////////////////////////////////////////////////

    bool isDelivery = appData.orderType == 'Delivery';

    if (isDelivery) {
      if (!restaurant.availableForDelivery) {
        onUnavailableForDelivery?.call();
        return;
      }
    }

    var response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentMethodId: paymentMethod.id, cardBrand: paymentMethod.card.brand.capitalize());

    if (response['message'] == 'validation error') {
      onValidationError?.call();
    }

    if (response['message'] == 'requires action') {
      var clientSecret = response['data']['client_secret'].toString();

      try {
        var paymentIntent = await stripe.StripePayment.authenticatePaymentIntent(clientSecret: clientSecret);
        if (paymentIntent.status == 'succeeded') {
          response = await orderRepo.addOrder(order: order, payment: this.payment, price: this.total, paymentIntentId: paymentIntent.paymentIntentId, cardBrand: paymentMethod.card.brand.capitalize());
        }
      } catch (e) {
        onAuthenticationFailed?.call();
      }
    }

    if (response['message'] == 'succeeded') {
      settingRepo.coupon = Coupon.fromJSON({});
      onSuccess?.call();
    }

    if (response['message'] == 'invalid status') {
      onError?.call();
    }
  }

  void updateCreditCard(guru.CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }

}
