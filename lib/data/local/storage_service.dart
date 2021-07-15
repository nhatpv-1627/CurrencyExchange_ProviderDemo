import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';

abstract class StorageService {
  Future? cacheExchangeRateData(List<Rate>? data);

  Future<List<Rate>> getExchangeRateData();

  Future<List<Currency>>? getFavoriteCurrencies();

  Future? saveFavoriteCurrencies(List<Currency> data);

  Future<bool> isExpiredCache();
}
