import '../../src/models/category.dart';

import '../helpers/custom_trace.dart';
import '../models/cuisine.dart';

class Filter {
  //bool delivery;
  //bool open;
  List<Cuisine> selectedCuisines;
  List<Category> selectedFoodCategories;

  Filter();

  Filter.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      //open = jsonMap['open'] ?? false;
      //delivery = jsonMap['delivery'] ?? false;
      selectedCuisines = jsonMap['cuisines'] != null && (jsonMap['cuisines'] as List).length > 0
          ? List.from(jsonMap['cuisines']).map((element) => Cuisine.fromJSON(element)).toList()
          : [];
      selectedFoodCategories = jsonMap['food_categories'] != null && (jsonMap['food_categories'] as List).length > 0
          ? List.from(jsonMap['food_categories']).map((element) => Category.fromJSON(element)).toList()
          : [];
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['cuisines'] = selectedCuisines.map((element) => element.toMap()).toList();
    map['food_categories'] = selectedFoodCategories.map((element) => element.toMap()).toList();
    return map;
  }

  @override
  String toString() {
    String filter = "";
    /*if (delivery) {
      if (open) {
        filter = "search=available_for_delivery:1;closed:0&searchFields=available_for_delivery:=;closed:=&searchJoin=and";
      } else {
        filter = "search=available_for_delivery:1&searchFields=available_for_delivery:=";
      }
    } else if (open) {
      filter = "search=closed:${open ? 0 : 1}&searchFields=closed:=";
    }*/
    return filter;
  }

  Map<String, dynamic> toQuery() {
    Map<String, dynamic> query = {};

    if (selectedCuisines != null && selectedCuisines.isNotEmpty) {
      query['cuisines[]'] = selectedCuisines.map((element) => element.id).toList();
    }

    if(selectedFoodCategories != null && selectedFoodCategories.isNotEmpty) {
      query['categories[]'] = selectedFoodCategories.map((element) => element.id).toList();
    }

    return query;

  }
}
