import 'package:log_storage_client/views/profiles_view.dart';
import 'package:log_storage_client/views/dashboard_view.dart';
import 'package:log_storage_client/views/local_log_files_view.dart';
import 'package:log_storage_client/views/remote_log_files_view.dart';
import 'package:log_storage_client/views/settings_view.dart';
import 'package:flutter/widgets.dart';

const String DashboardRoute = 'dashboard';
const String ProfilesRoute = 'profiles';
const String LocalLogFilesRoute = 'localLogFiles';
const String RemoteLogFilesRoute = 'remoteLogFiles';
const String SettingsRoute = 'settings';

/// Implements the navigation to different views using named routes with no page transition animation.
/// 
/// The implementation of this service class is base on this tutorial:
/// https://medium.com/flutter-community/layout-templates-and-basic-navigation-in-flutter-web-2e283edd5204
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  navigateBack() {
    navigatorKey.currentState.pop();
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case DashboardRoute:
        return _getPageRoute(DashboardView());
      case LocalLogFilesRoute:
        return _getPageRoute(LocalLogFilesView());
      case RemoteLogFilesRoute:
        return _getPageRoute(RemoteLogFilesView());
      case SettingsRoute:
        return _getPageRoute(SettingsView());
      case ProfilesRoute:
        return _getPageRoute(ProfilesView());
      default:
        return _getPageRoute(DashboardView());
    }
  }

  PageRoute _getPageRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        return child;
      },
      transitionDuration: Duration.zero,
    );
  }
}
