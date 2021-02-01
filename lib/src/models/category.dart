import 'dart:io';

import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  Media image;
  bool selected;

  Category();

  Category.from({this.id,this.name,this.selected});

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      selected = jsonMap['selected'] ?? false;
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      selected = false;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    return map;
  }

}
