import 'package:flutter/cupertino.dart';
import 'package:my_words/data/model/currency.dart';
import 'package:my_words/data/model/rate.dart';
import 'package:my_words/data/remote/currency_service.dart';
import 'package:my_words/di/service_locator.dart';
import 'package:my_words/utils/iso_data.dart';

class HomeViewModel extends ChangeNotifier {
  final CurrencyService _currencyService = serviceLocator<CurrencyService>();
  List<CurrencyPresentation> _quoteCurrencies = [];
  List<Rate> _rates = [];
  CurrencyPresentation _baseCurrency = defaultBaseCurrency;

  bool? _isSelected = false;

  static final CurrencyPresentation defaultBaseCurrency = CurrencyPresentation(
      flag: '', alphabeticCode: '', longName: '', amount: '');

  void loadData() async {
    await _loadCurrencies();
    _rates = await _currencyService.getAllExchangeRates(
        base: _baseCurrency.alphabeticCode);
    notifyListeners();
  }

  Future<void> _loadCurrencies() async {
    final currencies = await _currencyService.getFavoriteCurrencies();
    _baseCurrency = _loadBaseCurrency(currencies);
    _quoteCurrencies = _loadQuoteCurrencies(currencies);
  }

  CurrencyPresentation _loadBaseCurrency(List<Currency> currencies) {
    if (currencies.length == 0) {
      return defaultBaseCurrency;
    }
    String code = currencies[0].isoCode;
    return CurrencyPresentation(
        flag: IsoData.flagOf(code),
        alphabeticCode: code,
        longName: IsoData.longNameOf(code),
        amount: '');
  }

  Future refreshFavorites() async {
    await _loadCurrencies();
    notifyListeners();
  }

  List<CurrencyPresentation> _loadQuoteCurrencies(List<Currency> currencies) {
    List<CurrencyPresentation> quotes = [];
    for (int i = 1; i < currencies.length; i++) {
      String code = currencies[i].isoCode;
      quotes.add(CurrencyPresentation(
        flag: IsoData.flagOf(code),
        alphabeticCode: code,
        longName: IsoData.longNameOf(code),
        amount: currencies[i].amount.toStringAsFixed(2),
      ));
    }
    return quotes;
  }

  CurrencyPresentation get baseCurrency {
    return _baseCurrency;
  }

  List<CurrencyPresentation> get quoteCurrencies {
    return _quoteCurrencies;
  }

  Future setNewBaseCurrency(int quoteCurrencyIndex) async {
    _quoteCurrencies.add(_baseCurrency);
    _baseCurrency = _quoteCurrencies[quoteCurrencyIndex];
    _quoteCurrencies.removeAt(quoteCurrencyIndex);
    await _currencyService
        .saveFavoriteCurrencies(_convertPresentationToCurrency());
    loadData();
  }

  List<Currency> _convertPresentationToCurrency() {
    List<Currency> currencies = [];
    currencies.add(Currency(_baseCurrency.alphabeticCode ?? ""));
    for (CurrencyPresentation currency in _quoteCurrencies) {
      currencies.add(Currency(currency.alphabeticCode ?? ""));
    }
    return currencies;
  }

  void calculateExchange(String baseAmount) async {
    double amount;
    try {
      amount = double.parse(baseAmount);
    } catch (e) {
      _updateCurrenciesFor(0);
      notifyListeners();
      return null;
    }

    _updateCurrenciesFor(amount);

    notifyListeners();
  }

  void _updateCurrenciesFor(double baseAmount) {
    for (CurrencyPresentation c in _quoteCurrencies) {
      for (Rate r in _rates) {
        if (c.alphabeticCode == r.quoteCurrency) {
          c.amount = (baseAmount * r.exchangeRate).toStringAsFixed(2);
          break;
        }
      }
    }
  }

  set isTextSelected(bool isSelected) {
    this._isSelected = isSelected;
    notifyListeners();
  }

  bool getTextSeleted() => this._isSelected ?? false;
}

class SelectedPresentation {
  bool? isSelected = false;
  SelectedPresentation({this.isSelected});
}

class CurrencyPresentation {
  final String? flag;
  final String? alphabeticCode;
  final String? longName;
  String? amount;

  CurrencyPresentation({
    this.flag,
    this.alphabeticCode,
    this.longName,
    this.amount,
  });
}
