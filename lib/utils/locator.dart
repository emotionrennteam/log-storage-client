import 'package:emotion/utils/navigation_service.dart';
import 'package:get_it/get_it.dart';

/// Allows to locate singleton instances of services.
GetIt locator = GetIt.instance;

/// Registers the [NavigationService] as a singleton.
void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}
