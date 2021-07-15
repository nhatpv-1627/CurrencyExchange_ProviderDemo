import 'dart:convert';

import 'package:my_words/data/local/storage_service.dart';
import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceImpl implements StorageService {
  static const sharedPrefExchangeRateKey = 'exchange_rate_key';
  static const sharedPrefCurrencyKey = 'currency_key';
  static const sharedPrefLastCacheTimeKey = 'cache_time_key';

  @override
  Future cacheExchangeRateData(List<Rate>? data) async {
    String jsonString = jsonEncode(data);
    _resetCacheTimeToNow();
    _saveToPreferences(sharedPrefExchangeRateKey, jsonString);
  }

  Future<void> _resetCacheTimeToNow() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(sharedPrefLastCacheTimeKey, timestamp);
  }

  @override
  Future<List<Rate>> getExchangeRateData() async {
    String? data = await _getStringFromPreferences(sharedPrefExchangeRateKey);
    List<Rate> rates = _deserializeRates(data ?? "");
    return Future<List<Rate>>.value(rates);
  }

  @override
  Future<List<Currency>>? getFavoriteCurrencies() async {
    String data = await _getStringFromPreferences(sharedPrefCurrencyKey) ?? '';
    if (data == '') {
      return [];
    }
    return _deserializeCurrencies(data);
  }

  @override
  Future<bool> isExpiredCache() async {
    final now = DateTime.now();
    DateTime lastUpdate = await _getLastRatesCacheTime();
    Duration difference = now.difference(lastUpdate);
    return difference.inDays > 1;
  }

  @override
  Future? saveFavoriteCurrencies(List<Currency> data) {
    String jsonString = _serializeCurrencies(data);
    return _saveToPreferences(sharedPrefCurrencyKey, jsonString);
  }

  String _serializeCurrencies(List<Currency> data) {
    final currencies = data.map((currency) => currency.isoCode).toList();
    return jsonEncode(currencies);
  }

  Future<void> _saveToPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> _getStringFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return Future<String>.value(prefs.getString(key) ?? '');
  }

  List<Currency> _deserializeCurrencies(String data) {
    final codeList = jsonDecode(data);
    List<Currency> list = [];
    for (String code in codeList) {
      list.add(Currency(code));
    }
    return list;
  }

  Future<DateTime> _getLastRatesCacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    int timeStamp = prefs.getInt(sharedPrefLastCacheTimeKey) ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(timeStamp);
  }

  List<Rate> _deserializeRates(String data) {
    List<Map> rateList = jsonDecode(data);
    return rateList.map((rate) {
      return Rate.fromJson(rate);
    }).toList();
  }
}
