import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/navigation_service.dart';
import 'package:log_storage_client/widgets/app_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Defines the layout of this app consisting of an app drawer on the left side
/// and the content on the right side.
///
/// The hierarchy looks like this:
///   .
///   ├── MaterialApp
///   │   ├── AppLayout
///   │   │   ├── AppDrawer
///   │   │   ├── ViewWidget (e.g. dashboard or settings view)
///
/// The view widgets (dashboard, local / remote log files, settings) are switched
/// using Flutter's built-in Navigator. This way, the [AppDrawer] widget will never
/// be re-initialized. We need to prevent re-initialization of this widget because
/// it must contain the logic for downloading and uploading data. The process of
/// downloading/uploading would be disrupted, if the user was to switch the views
/// during an ongoing download/upload. But, if the [AppDrawer] widget never is
/// re-initialized, then the download/upload process can't be disrupted unless the
/// user closes the app. That's the trick.
class AppLayout extends StatefulWidget {
  const AppLayout({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDrawer(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Navigator(
                  key: locator<NavigationService>().navigatorKey,
                  onGenerateRoute: locator<NavigationService>().onGenerateRoute,
                  initialRoute: DashboardRoute,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
