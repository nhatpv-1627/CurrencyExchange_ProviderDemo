import 'package:my_words/data/model/rate.dart';
import 'package:my_words/data/remote/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebApiImpl implements WebApi {
  final Map<String, String> _headers = {'Accept': 'application/json'};

  List<Rate>? _rateCache;

  @override
  Future<List<Rate>> fetchExchangeRates() async {
    if (_rateCache == null) {
      final uri = Uri.parse(
          'http://api.exchangeratesapi.io/latest?access_key=0a3ff30d717c199a4fc1f6d45ac33e5d');
      final results = await http.get(uri, headers: _headers);
      final jsonObject = json.decode(results.body);
      _rateCache = _createRateListFromRawMap(jsonObject) ?? [];
    } else {
      print('getting rates from cache');
    }
    return _rateCache ?? [];
  }

  List<Rate>? _createRateListFromRawMap(jsonObject) {
    final Map? rates = jsonObject['rates'];
    if (rates == null) return [];
    final String? base = jsonObject['base'];
    List<Rate> list = [];

    list.add(Rate(
        baseCurrency: base ?? 'AAA',
        quoteCurrency: base ?? 'AAA',
        exchangeRate: 1.0));
    for (var rate in rates.entries) {
      list.add(Rate(
          baseCurrency: base ?? 'AAA',
          quoteCurrency: rate.key,
          exchangeRate: rate.value.toDouble()));
    }
    return list;
  }
}
