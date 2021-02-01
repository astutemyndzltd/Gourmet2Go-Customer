import 'package:flutter/material.dart';

import 'CuisinesCarouselItemWidget.dart';
import 'CircularLoadingWidget.dart';
import '../models/cuisine.dart';

// ignore: must_be_immutable
class CuisinesCarouselWidget extends StatelessWidget {
  List<Cuisine> cuisines;

  CuisinesCarouselWidget({Key key, this.cuisines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.cuisines.isEmpty
        ? CircularLoadingWidget(height: 150)
        : Container(
            height: 150,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 25),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              itemCount: this.cuisines.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (c, i) => SizedBox(width: 10),
              itemBuilder: (context, index) {
                return CuisinesCarouselItemWidget(
                  key: UniqueKey(),
                  cuisine: this.cuisines.elementAt(index),
                );
              },
            ),
          );
  }
}
