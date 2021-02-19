import 'package:flutter/material.dart';

import '../elements/CircularLoadingWidget.dart';
import '../elements/ReviewItemWidget.dart';
import '../models/review.dart';

// ignore: must_be_immutable
class ReviewsListWidget extends StatelessWidget {
  List<Review> reviewsList;
  bool loading = false;

  ReviewsListWidget({Key key, this.reviewsList, this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularLoadingWidget(height: 200)
        : reviewsList.isEmpty
            ? Container(
                height: 100,
                width: double.infinity,
                child: SizedBox.shrink(),
              )
            : ListView.separated(
                padding: EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return ReviewItemWidget(
                    review: reviewsList.elementAt(index),
                    key: UniqueKey(),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 20);
                },
                itemCount: reviewsList.length,
                primary: false,
                shrinkWrap: true,
              );
  }
}
