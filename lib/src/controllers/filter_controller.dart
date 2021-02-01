import 'dart:convert';

import '../../src/models/category.dart';
import '../../src/repository/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/cuisine.dart';
import '../models/filter.dart';
import '../repository/cuisine_repository.dart';

class FilterController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Cuisine> cuisines = [];
  List<Category> foodCategories = [];
  Filter filter;
  CartItem cart;

  FilterController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.initialize();
  }

  void initialize() async {
    await listenForFilter();
    listenForCuisines();
    listenForFoodCategories();
  }

  Future<void> listenForFilter() async {
    var prefs = await SharedPreferences.getInstance();
    var filterString = prefs.getString('filter');
    filter = Filter.fromJSON(json.decode(filterString ?? '{}'));
  }

  Future<void> saveFilter() async {
    filter.selectedCuisines = cuisines.skip(1).where((c) => c.selected).toList();
    filter.selectedFoodCategories = foodCategories.skip(1).where((fc) => fc.selected).toList();
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('filter', json.encode(filter.toMap()));
  }

  void listenForCuisines() async {
    var streamOfCuisines = await getCuisines();
    cuisines.add(Cuisine.from(id: '0', name: 'All', selected: true));
    streamOfCuisines.listen((c) => cuisines.add(c), onDone: () {
      for(var c in cuisines.skip(1)) {
        c.selected = filter.selectedCuisines.firstWhere((sc) => sc.id == c.id, orElse: () => null) != null;
        c.selected && (cuisines[0].selected = false);
      }
      setState(() {});
    });

  }

  void listenForFoodCategories() async {
    var streamOfCategories = await getCategories();
    foodCategories.add(Category.from(id: '0', name: 'All', selected: true));
    streamOfCategories.listen((fc) => foodCategories.add(fc), onDone: () {
      for(var fc in foodCategories.skip(1)) {
        fc.selected = filter.selectedFoodCategories.firstWhere((sfc) => sfc.id == fc.id, orElse: () => null) != null;
        fc.selected && (foodCategories[0].selected = false);
      }
      setState(() {});
    });
  }

  Future<void> refreshCuisinesPlusCategories() async {

  }

  void clearFilter() {
    resetCuisines();
    resetFoodCategories();
    setState((){});
  }

  void resetCuisines() {
    filter.selectedCuisines.clear();
    cuisines.forEach((c) => c.selected = false);
    cuisines[0].selected = true;
  }

  void resetFoodCategories() {
    filter.selectedFoodCategories.clear();
    foodCategories.forEach((fc) => fc.selected = false);
    foodCategories[0].selected = true;
  }

  void onChangeCuisinesFilter(int index) {
    cuisines[index].selected = !cuisines[index].selected;

    if(cuisines[index].selected) {
      if(index == 0) cuisines.skip(1).forEach((c) => c.selected = false);
      else cuisines[0].selected = false;
    }
    else {
      if(index != 0) {
        var totalSelected = cuisines.skip(1).where((c) => c.selected).length;
        cuisines[0].selected = (totalSelected == 0);
      }
    }

    setState((){});

  }

  void onChangeFoodCategoriesFilter(int index) {
    foodCategories[index].selected = !foodCategories[index].selected;

    if(foodCategories[index].selected) {
      if(index == 0) foodCategories.skip(1).forEach((fc) => fc.selected = false);
      else foodCategories[0].selected = false;
    }
    else {
      if(index != 0) {
        var totalSelected = foodCategories.skip(1).where((fc) => fc.selected).length;
        foodCategories[0].selected = (totalSelected == 0);
      }
    }

    setState((){});
  }

}
