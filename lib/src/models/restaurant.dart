import 'dart:io';

import 'package:intl/intl.dart';

import '../helpers/custom_trace.dart';
import '../models/media.dart';
import 'user.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool closed;
  bool availableForDelivery;
  double deliveryRange;
  double distance;
  double distanceInKm;
  List<User> users;
  double minOrderAmount;
  bool availableForPreorder;
  OpeningTimesForWeek openingTimes;

  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      minOrderAmount = jsonMap['min_order_amount'] != null ? jsonMap['min_order_amount'].toDouble() : 0.0;
      address = jsonMap['address'];
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? false;
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
      distanceInKm = jsonMap['distance_km'] != null ? double.parse(jsonMap['distance_km'].toString()) : 0.0;
      users = jsonMap['users'] != null && (jsonMap['users'] as List).length > 0 ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toSet().toList() : [];
      availableForPreorder = jsonMap['available_for_preorder'] ?? false;
      openingTimes = (jsonMap['opening_times'] != null) ? OpeningTimesForWeek.fromJSON(jsonMap['opening_times']) : null;
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      users = [];
      minOrderAmount = 0.0;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'latitude': latitude, 'longitude': longitude, 'delivery_fee': deliveryFee, 'distance': distance, 'min_order_amount': minOrderAmount};
  }

  bool isCurrentlyOpen() {
    if (closed || openingTimes == null) return false;

    var dateTime = DateTime.now();
    var formatter = DateFormat('EEEE');
    var today = formatter.format(dateTime).toLowerCase();
    var timeSlotsForToday = openingTimes.toMap()[today];

    if (timeSlotsForToday == null) return false;

    var timeFormatter = DateFormat('jm');
    var timeNow = timeFormatter.parse(timeFormatter.format(dateTime));

    for (var slot in timeSlotsForToday) {
      var opensAt = timeFormatter.parse(slot.opensAt);
      var closesAt = timeFormatter.parse(slot.closesAt);

      if (timeNow.compareTo(opensAt) >= 0 && timeNow.compareTo(closesAt) <= 0) {
        return true;
      }
    }

    return false;
  }

  bool isAvailableForDelivery() {
    return isCurrentlyOpen() && availableForDelivery;
  }

  bool isAvailableForPickup() {
    return isCurrentlyOpen() && !availableForDelivery;
  }

  bool isAvailableForPreorder() {
    return isAvailableForPreorderToday() || isAvailableForPreorderTomorrow();
  }

  bool isClosedAndAvailableForPreorder() {
    return !isCurrentlyOpen() && isAvailableForPreorder();
  }

  bool isAvailableForPreorderToday() {
    if (!availableForPreorder || closed || openingTimes == null) return false;

    var dateTime = DateTime.now();
    var dayFormatter = DateFormat('EEEE');
    var today = dayFormatter.format(dateTime).toLowerCase();
    var todaySlots = openingTimes.toMap()[today];

    if (todaySlots != null) {
      var timeFormatter = DateFormat('jm');
      var time = timeFormatter.parse(timeFormatter.format(dateTime));

      for (var slot in todaySlots) {
        var opensAt = timeFormatter.parse(slot.opensAt);
        var closesAt = timeFormatter.parse(slot.closesAt);

        if (time.isBefore(opensAt) || (time.compareTo(opensAt) >= 0 && time.compareTo(closesAt) <= 0)) {
          return true;
        }
      }
    }

    return false;
  }

  List<String> generateTimesForToday({int durationInMin = 15}) {
    var times = List<String>();

    if (isAvailableForPreorderToday()) {
      var dateTime = DateTime.now();
      var dayFormatter = DateFormat('EEEE');
      var timeFormatter = DateFormat('jm');
      var today = dayFormatter.format(dateTime).toLowerCase();
      var todaySlots = openingTimes.toMap()[today];
      var time = timeFormatter.parse(timeFormatter.format(dateTime));

      for (var slot in todaySlots) {
        var opensAt = timeFormatter.parse(slot.opensAt);
        var closesAt = timeFormatter.parse(slot.closesAt);
        var minutesToAdd = (durationInMin * ((opensAt.minute ~/ durationInMin) + (opensAt.minute % durationInMin == 0 ? 0 : 1))) - opensAt.minute;
        var startTime = opensAt.add(Duration(minutes: minutesToAdd));

        while (startTime.compareTo(closesAt) <= 0) {
          if (startTime.compareTo(time) >= 0 && startTime.difference(time) >= Duration(hours: 1)) times.add(timeFormatter.format(startTime));
          startTime = startTime.add(Duration(minutes: durationInMin));
        }
      }
    }

    return times;

  }

  List<String> generateTimesForTomorrow({int durationInMin = 15}) {
    var times = List<String>();

    if (isAvailableForPreorderTomorrow()) {
      var dateTime = DateTime.now();
      var dayFormatter = DateFormat('EEEE');
      var timeFormatter = DateFormat('jm');
      var tomorrow = dayFormatter.format(dateTime.add(Duration(days: 1))).toLowerCase();
      var tomorrowSlots = openingTimes.toMap()[tomorrow];

      for (var slot in tomorrowSlots) {
        var opensAt = timeFormatter.parse(slot.opensAt);
        var closesAt = timeFormatter.parse(slot.closesAt);
        var minutesToAdd = (durationInMin * ((opensAt.minute ~/ durationInMin) + (opensAt.minute % durationInMin == 0 ? 0 : 1))) - opensAt.minute;
        var startTime = opensAt.add(Duration(minutes: minutesToAdd));

        while (startTime.compareTo(closesAt) <= 0) {
          times.add(timeFormatter.format(startTime));
          startTime = startTime.add(Duration(minutes: durationInMin));
        }
      }
    }

    return times;
  }

  bool isAvailableForPreorderTomorrow() {
    if (!availableForPreorder || openingTimes == null) return false;

    var formatter = DateFormat('EEEE');
    var tomorrow = formatter.format(DateTime.now().add(Duration(days: 1))).toLowerCase();
    var tomorrowSlots = openingTimes.toMap()[tomorrow];
    return tomorrowSlots != null;
  }

  bool openingLaterToday() {
    if (closed || openingTimes == null) return false;

    var dateTime = DateTime.now();
    var dayFormatter = DateFormat('EEEE');

    var today = dayFormatter.format(dateTime).toLowerCase();
    var todaySlots = openingTimes.toMap()[today];

    if (todaySlots != null) {
      var timeFormatter = DateFormat('jm');
      var time = timeFormatter.parse(timeFormatter.format(dateTime));

      for (var slot in todaySlots) {
        var opensAt = timeFormatter.parse(slot.opensAt);
        if (time.isBefore(opensAt)) return true;
      }
    }

    return false;
  }

}

class OpeningTimesForWeek {
  List<TimeSlot> monday;
  List<TimeSlot> tuesday;
  List<TimeSlot> wednesday;
  List<TimeSlot> thursday;
  List<TimeSlot> friday;
  List<TimeSlot> saturday;
  List<TimeSlot> sunday;

  OpeningTimesForWeek.fromJSON(Map<String, dynamic> jsonMap) {
    monday = jsonMap['monday'] != null ? List.from(jsonMap['monday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    tuesday = jsonMap['tuesday'] != null ? List.from(jsonMap['tuesday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    wednesday = jsonMap['wednesday'] != null ? List.from(jsonMap['wednesday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    thursday = jsonMap['thursday'] != null ? List.from(jsonMap['thursday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    friday = jsonMap['friday'] != null ? List.from(jsonMap['friday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    saturday = jsonMap['saturday'] != null ? List.from(jsonMap['saturday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
    sunday = jsonMap['sunday'] != null ? List.from(jsonMap['sunday'])?.map((e) => TimeSlot.fromJSON(e)).toList() : null;
  }

  Map<String, List<TimeSlot>> toMap() {
    return {
      "monday": monday,
      "tuesday": tuesday,
      "wednesday": wednesday,
      "thursday": thursday,
      "friday": friday,
      "saturday": saturday,
      "sunday": sunday,
    };
  }
}

class TimeSlot {
  String opensAt;
  String closesAt;

  TimeSlot.fromJSON(Map<String, dynamic> jsonMap) {
    opensAt = jsonMap['opens_at'];
    closesAt = jsonMap['closes_at'];
  }
}
