import 'package:my_words/data/local/storage_service.dart';
import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';
import 'package:my_words/di/service_locator.dart';

import 'api.dart';
import 'currency_service.dart';

class CurrencyServiceImpl implements CurrencyService {
  WebApi _webApi = serviceLocator<WebApi>();
  StorageService _storageService = serviceLocator<StorageService>();

  static final defaultFavorites = [Currency('EUR'), Currency('USD')];

  @override
  Future<List<Rate>> getAllExchangeRates({String? base}) async {
    List<Rate> webData = await _webApi.fetchExchangeRates();
    if (base != null) {
      return _convertBaseCurrency(base, webData);
    }
    return webData;
  }

  @override
  Future<List<Currency>> getFavoriteCurrencies() async {
    final favorite = await _storageService.getFavoriteCurrencies();
    if (favorite == null || favorite.isEmpty) return defaultFavorites;
    return favorite;
  }

  @override
  Future<void> saveFavoriteCurrencies(List<Currency>? data) async {
    if (data == null || data.length == 0) return;
    await _storageService.saveFavoriteCurrencies(data);
  }

  List<Rate> _convertBaseCurrency(String base, List<Rate> remoteData) {
    if (remoteData.isEmpty) return [];
    if (remoteData[0].baseCurrency == base) {
      return remoteData;
    }
    double divisor = remoteData
        .firstWhere((rate) => rate.quoteCurrency == base)
        .exchangeRate;
    return remoteData
        .map((rate) => Rate(
              baseCurrency: base,
              quoteCurrency: rate.quoteCurrency,
              exchangeRate: rate.exchangeRate / divisor,
            ))
        .toList();
  }
}
