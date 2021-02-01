import '../elements/RestaurantsWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cuisine.dart';

// ignore: must_be_immutable
class CuisinesCarouselItemWidget extends StatelessWidget {
  double marginLeft;
  Cuisine cuisine;

  CuisinesCarouselItemWidget({Key key, this.marginLeft, this.cuisine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: cuisine.name,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              CachedNetworkImage(
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                imageUrl: cuisine.image.icon,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Positioned(
                bottom: 3,
                left: 3,
                child: Container(
                  width: 140,
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                  child: Text(
                    cuisine.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(RestaurantOfCuisineModal(cuisine));
          },
        ),
      ),
    );
  }
}
