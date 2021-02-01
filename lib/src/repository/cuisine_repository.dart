import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/cuisine.dart';



Future<Stream<Cuisine>> getCuisines() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cuisines?orderBy=updated_at&sortedBy=desc';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Cuisine.fromJSON(data);
  });
}

Future<List<Cuisine>> getCuisinesNew() async {

  final String url = '${GlobalConfiguration().getValue('api_base_url')}cuisines?orderBy=updated_at&sortedBy=desc';

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      List data = json['data'];
      return data.map((rd) => Cuisine.fromJSON(rd)).toList();
    }

  } catch (e) {
    //print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return List<Cuisine>();
  }




}
