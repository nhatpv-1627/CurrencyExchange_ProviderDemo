import 'package:my_words/data/model/rate.dart';

abstract class WebApi {
  Future<List<Rate>> fetchExchangeRates();
}
