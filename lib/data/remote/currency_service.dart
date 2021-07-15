import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';

abstract class CurrencyService {
  Future<List<Rate>> getAllExchangeRates({String? base});

  Future<List<Currency>> getFavoriteCurrencies();

  Future<void> saveFavoriteCurrencies(List<Currency>? data);
}
