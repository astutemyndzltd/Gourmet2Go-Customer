import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<CartItem>> getCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}carts?${_apiToken}with=food;food.restaurant;extras&search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return CartItem.fromJSON(data);
  });
}

Future<List<CartItem>> getCartItemsNew() async {
  var user = userRepo.currentUser.value;

  if (user.apiToken == null) {
    return null;
  }

  final String apiToken = 'api_token=${user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?${apiToken}with=food;food.restaurant;extras&search=user_id:${user.id}&searchFields=user_id:=';

  var response = await http.get(url.toString());

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    var data = json['data'];
    List<CartItem> items = (data as List).map((ci) => CartItem.fromJSON(ci)).toList();
    return items;
  }

  return null;

}


  Future<Stream<int>> getCartCount() async {
    User _user = userRepo.currentUser.value;
    if (_user.apiToken == null) {
      return new Stream.value(0);
    }
    final String _apiToken = 'api_token=${_user.apiToken}&';
    final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/count?${_apiToken}search=user_id:${_user.id}&searchFields=user_id:=';

    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map(
          (data) => Helper.getIntData(data),
    );
  }

  Future<CartItem> addCart(CartItem cart, bool reset) async {
    User _user = userRepo.currentUser.value;
    if (_user.apiToken == null) {
      return new CartItem();
    }
    Map<String, dynamic> decodedJSON = {};
    final String _apiToken = 'api_token=${_user.apiToken}';
    final String _resetParam = 'reset=${reset ? 1 : 0}';
    cart.userId = _user.id;
    final String url = '${GlobalConfiguration().getValue('api_base_url')}carts?$_apiToken&$_resetParam';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(cart.toMap()),
    );
    try {
      decodedJSON = json.decode(response.body)['data'] as Map<String, dynamic>;
    } on FormatException catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
    return CartItem.fromJSON(decodedJSON);
  }

  Future<CartItem> updateCart(CartItem cart) async {
    User _user = userRepo.currentUser.value;
    if (_user.apiToken == null) {
      return new CartItem();
    }
    final String _apiToken = 'api_token=${_user.apiToken}';
    cart.userId = _user.id;
    final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$_apiToken';
    final client = new http.Client();
    final response = await client.put(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(cart.toMap()),
    );
    return CartItem.fromJSON(json.decode(response.body)['data']);
  }

  Future<bool> removeCart(CartItem cart) async {
    User _user = userRepo.currentUser.value;
    if (_user.apiToken == null) {
      return false;
    }
    final String _apiToken = 'api_token=${_user.apiToken}';
    final String url = '${GlobalConfiguration().getValue('api_base_url')}carts/${cart.id}?$_apiToken';
    final client = new http.Client();
    final response = await client.delete(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Helper.getBoolData(json.decode(response.body));
  }
