import '../../src/elements/EmptyNotificationsWidget.dart';
import '../../src/helpers/helper.dart';
import '../../src/models/dispatchmethod.dart';

import '../elements/CuisinesCarouselWidget.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {

  HomeController _con;
  List<String> homeSections = [];

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ts) {
      _con.overlayLoader = Helper.overlayLoader(context);
      Overlay.of(context).insert(_con.overlayLoader);
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_con.nearbyRestaurants == null) {
      homeSections = [];
    } else if (_con.nearbyRestaurants.isEmpty) {
      homeSections = ['search', 'top_restaurants_heading', 'no_restaurants_to_show'];
    } else {
      homeSections = settingsRepo.setting.value.homeSections;
    }

    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName ?? S.of(context).home,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(homeSections.length, (index) {
              String _homeSection = homeSections.elementAt(index);

              switch (_homeSection) {
                case 'no_restaurants_to_show':
                  return Container(
                    //color: Colors.red,
                    width: double.infinity,
                    height: 500,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 60),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                                Theme.of(context).focusColor.withOpacity(0.7),
                                Theme.of(context).focusColor.withOpacity(0.05),
                              ])),
                          child: Icon(
                            Icons.add_location,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 70,
                          ),
                        ),
                        SizedBox(height: 15),
                        Opacity(
                          opacity: 0.4,
                          child: Text(
                            'No restaurants to show\nPlease change your location',
                            //S.of(context).dont_have_any_item_in_the_notification_list,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                          ),
                        )
                      ],
                    ),
                  );

                case 'slider':
                  return HomeSliderWidget(slides: _con.slides);

                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  );

                case 'top_restaurants_heading':
                  return Column(
                    children: [
                      // delivery address
                      Padding(
                        padding: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delivery Address',
                                    style: Theme.of(context).textTheme.headline4,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                InkWell(
                                  child: Container(
                                    child: Text('Change', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  onTap: () {
                                    var parentScaffoldState = widget.parentScaffoldKey.currentState;

                                    var bottomSheetController = parentScaffoldState.showBottomSheet(
                                      (context) => DeliveryAddressBottomSheetWidget(
                                        scaffoldKey: widget.parentScaffoldKey,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                    );

                                    bottomSheetController.closed.then((v) => _con.refreshHome());
                                  },
                                )
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    settingsRepo.deliveryAddress.value?.address ?? '',
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.left,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      if (_con.nearbyRestaurants.isNotEmpty)
                        // restaurants + dispatch method
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // restaurants near you heading
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Restaurants near you',
                                      //S.of(context).top_restaurants,
                                      style: Theme.of(context).textTheme.headline4,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              // select dispatch method - delivery/pickup/preorder
                              Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Choose method',
                                        style: Theme.of(context).textTheme.bodyText1,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    // delivery button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (settingsRepo.dispatchMethod == DispatchMethod.delivery)
                                            settingsRepo.dispatchMethod = DispatchMethod.none;
                                          else
                                            settingsRepo.dispatchMethod = DispatchMethod.delivery;

                                          _con.refreshHome();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: settingsRepo.dispatchMethod == DispatchMethod.delivery ? Colors.green : Theme.of(context).focusColor.withOpacity(0.1),
                                        ),
                                        child: Text(
                                          S.of(context).delivery,
                                          style: TextStyle(color: settingsRepo.dispatchMethod == DispatchMethod.delivery ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 7),
                                    // pickup button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (settingsRepo.dispatchMethod == DispatchMethod.pickup)
                                            settingsRepo.dispatchMethod = DispatchMethod.none;
                                          else
                                            settingsRepo.dispatchMethod = DispatchMethod.pickup;
                                          _con.refreshHome();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: settingsRepo.dispatchMethod == DispatchMethod.pickup ? Colors.orange : Theme.of(context).focusColor.withOpacity(0.1),
                                        ),
                                        child: Text(
                                          S.of(context).pickup,
                                          style: TextStyle(color: settingsRepo.dispatchMethod == DispatchMethod.pickup ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 7),
                                    // preorder button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (settingsRepo.dispatchMethod == DispatchMethod.preorder)
                                            settingsRepo.dispatchMethod = DispatchMethod.none;
                                          else
                                            settingsRepo.dispatchMethod = DispatchMethod.preorder;

                                          _con.refreshHome();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: settingsRepo.dispatchMethod == DispatchMethod.preorder ? Colors.blue : Theme.of(context).focusColor.withOpacity(0.1),
                                        ),
                                        child: Text(
                                          'Pre-Order',
                                          //S.of(context).pickup,
                                          style: TextStyle(color: settingsRepo.dispatchMethod == DispatchMethod.preorder ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  );

                case 'top_restaurants':
                  return (_con.showableRestaurants != null && _con.showableRestaurants.isEmpty)
                      ? Container(
                          width: double.infinity,
                          height: 288,
                          child: Center(
                            child: Text(
                              'No results found',
                              style: Theme.of(context).textTheme.headline4,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        )
                      : CardsCarouselWidget(restaurantsList: _con.showableRestaurants, heroTag: 'home_top_restaurants');

                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );

                case 'trending_week':
                  return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');

                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.fastfood,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        "Cuisines",
                        //S.of(context).food_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );

                case 'categories':
                  return CuisinesCarouselWidget(
                    cuisines: _con.cuisines,
                  );

                case 'popular_heading':
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );

                case 'popular':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridWidget(
                      restaurantsList: _con.popularRestaurantsNearby,
                      heroTag: 'home_restaurants',
                    ),
                  );

                /*case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );

                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  );*/

                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }


}
