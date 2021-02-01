import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class CartItem {

  String id;
  Food food;
  double quantity;
  List<Extra> extras;
  String userId;

  CartItem();

  CartItem.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      quantity = jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0;
      food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food.fromJSON({});
      extras = jsonMap['extras'] != null ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList() : [];
    } catch (e) {
      id = '';
      quantity = 0.0;
      food = Food.fromJSON({});
      extras = [];
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["quantity"] = quantity;
    map["food_id"] = food.id;
    map["user_id"] = userId;
    map["extras"] = extras.map((element) => element.id).toList();
    return map;
  }

  double getFoodPrice() {
    double result = food.price;
    if (extras.isNotEmpty) {
      extras.forEach((Extra extra) {
        result += extra.price != null ? extra.price : 0;
      });
    }
    return result;
  }

  bool isSame(CartItem cart) {
    bool _same = true;
    _same &= this.food == cart.food;
    _same &= this.extras.length == cart.extras.length;
    if (_same) {
      this.extras.forEach((Extra _extra) {
        _same &= cart.extras.contains(_extra);
      });
    }
    return _same;
  }

  bool isEqualTo(CartItem cartItem) {
    if(this.food.id != cartItem.food.id) return false;
    if(this.extras.length != cartItem.extras.length) return false;

    for(var e in this.extras) {
      bool found = cartItem.extras.firstWhere((ex) => e.id == ex.id, orElse: () => null) != null;
      if(!found) return false;
    }

    return true;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
