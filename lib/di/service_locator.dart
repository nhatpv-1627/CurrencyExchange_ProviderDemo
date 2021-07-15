import 'package:get_it/get_it.dart';
import 'package:my_words/data/local/storage_service.dart';
import 'package:my_words/data/local/storage_service_impl.dart';
import 'package:my_words/data/remote/api.dart';
import 'package:my_words/data/remote/currency_service.dart';
import 'package:my_words/data/remote/currentcy_service_impl.dart';
import 'package:my_words/data/remote/web_api_implementation.dart';
import 'package:my_words/presentation/favorite/favorite_view_model.dart';
import 'package:my_words/presentation/home/home_view_model.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator
      .registerLazySingleton<StorageService>(() => StorageServiceImpl());
  serviceLocator
      .registerLazySingleton<CurrencyService>(() => CurrencyServiceImpl());

  serviceLocator.registerFactory<HomeViewModel>(() => HomeViewModel());
  serviceLocator.registerFactory<FavoriteViewModel>(() => FavoriteViewModel());

  serviceLocator.registerLazySingleton<WebApi>(() => WebApiImpl());
}
