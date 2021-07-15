import 'package:flutter/cupertino.dart';
import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';
import 'package:my_words/data/remote/currency_service.dart';
import 'package:my_words/di/service_locator.dart';
import 'package:my_words/utils/iso_data.dart';

class FavoriteViewModel extends ChangeNotifier {
  final CurrencyService _currencyService = serviceLocator<CurrencyService>();

  List<FavoritePresentation> _choices = [];
  List<Currency> _favorites = [];

  List<FavoritePresentation> get choices => _choices;

  void loadData() async {
    final rates = await _currencyService.getAllExchangeRates();
    _favorites = await _currencyService.getFavoriteCurrencies();
    _prepareChoicePresentation(rates);
    notifyListeners();
  }

  void _prepareChoicePresentation(List<Rate> rates) {
    List<FavoritePresentation> list = [];
    for (Rate rate in rates) {
      String code = rate.quoteCurrency;
      bool isFavorite = _isRateFavorite(code);
      list.add(FavoritePresentation(
          flag: IsoData.flagOf(code),
          alphabeticCode: code,
          longName: IsoData.longNameOf(code),
          isFavorite: isFavorite));
    }
    _choices = list;
  }

  void toggleFavoriteStatus(int choiceIndex) {
    final isFavorite = _choices[choiceIndex].isFavorite != true;
    final code = _choices[choiceIndex].alphabeticCode;
    _choices[choiceIndex].isFavorite = isFavorite;
    if (isFavorite)
      _addToFavorite(code);
    else
      _removeFromFavorite(code);

    notifyListeners();
  }

  bool _isRateFavorite(String code) {
    for (Currency currency in _favorites) {
      if (code == currency.isoCode) return true;
    }
    return false;
  }

  void _addToFavorite(String? code) {
    _favorites.add(Currency(code ?? ""));
    _currencyService.saveFavoriteCurrencies(_favorites);
  }

  void _removeFromFavorite(String? code) {
    for (final currency in _favorites) {
      if (currency.isoCode == code) _favorites.remove(currency);
    }
    _currencyService.saveFavoriteCurrencies(_favorites);
  }
}

class FavoritePresentation {
  final String? flag;
  final String? alphabeticCode;
  final String? longName;
  bool? isFavorite;

  FavoritePresentation({
    this.flag,
    this.alphabeticCode,
    this.longName,
    this.isFavorite,
  });
}
