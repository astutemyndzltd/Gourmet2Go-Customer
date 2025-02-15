import '../../src/pages/favorites.dart';
import '../../src/repository/settings_repository.dart';
import 'package:flutter/material.dart';

import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../pages/home.dart';
import '../pages/map.dart';
import '../pages/notifications.dart';
import '../pages/orders.dart';
import 'messages.dart';

// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesWidget({Key key, this.currentTab}) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {

  initState() {
    super.initState();

    if (deliveryAddress.value == null || !deliveryAddress.value.isValid()) {
      Navigator.of(context).pushReplacementNamed('/LocationChoice');
    }

    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {

      //print('tabItem -> $tabItem');

      widget.currentTab = tabItem;

      switch (tabItem) {

        case 0:
          widget.currentPage = NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;

        case 1:
          widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
          break;

        case 2:
          widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;

        case 3:
          widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;

        case 4:
          widget.currentPage = FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          //widget.currentPage = MessagesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        endDrawer: FilterWidget(onFilter: (filter) {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
        }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab == 4 ? 1 :  widget.currentTab - 1,
          onTap: (int i) {
            //print('tab no => ' + i.toString());
            this._selectTab(i + 1);
          },
          // this will be set when a new tab is tapped
          items: [
            // notifications
            /*BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: '',
            ),*/
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: '',
            ),
            BottomNavigationBarItem(
                label: '',
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)), BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))],
                  ),
                  child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
              icon: new Icon(Icons.local_mall),
              label: '',
            ),
            /*BottomNavigationBarItem(
              icon: new Icon(Icons.chat),
              label: '',
            ),*/
            // fav food
            /*BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: '',
            )*/
          ],
        ),
      ),
    );
  }
}