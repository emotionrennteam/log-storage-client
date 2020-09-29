import 'package:emotion/utils/locator.dart';
import 'package:emotion/utils/navigation_service.dart';
import 'package:emotion/utils/constants.dart' as constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatefulWidget {
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem(
      'Dashboard',
      Icons.dashboard_rounded,
      DashboardRoute,
    ),
    new AppDrawerItem(
      'Profiles',
      FontAwesomeIcons.userAlt,
      ProfilesRoute,
    ),
    new AppDrawerItem(
      'Local Log Files',
      FontAwesomeIcons.solidFolder,
      LocalLogFilesRoute,
    ),
    new AppDrawerItem(
      'Remote Log Files',
      FontAwesomeIcons.cloud,
      RemoteLogFilesRoute,
    ),
    new AppDrawerItem(
      'Settings',
      FontAwesomeIcons.cog,
      SettingsRoute,
    ),
  ];

  AppDrawer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _activeRouteName = DashboardRoute;

  List<Widget> _buildAppDrawerItems(BuildContext context) {
    final appDrawerItems = List<Widget>();
    widget.appDrawerItems.asMap().forEach((index, element) {
      appDrawerItems.add(
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: this._activeRouteName == element.routeName
                      ? Theme.of(context).accentColor.withOpacity(0.5)
                      : Colors.transparent,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              borderRadius: BorderRadius.circular(7),
              color: this._activeRouteName == element.routeName
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              child: InkWell(
                splashColor: Theme.of(context).accentColor,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    this._activeRouteName = element.routeName;
                  });
                  locator<NavigationService>().navigateTo(element.routeName);
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 30,
                      child: Align(
                        alignment: Alignment.center,
                        child: FaIcon(
                          element.icon,
                          color: constants.TEXT_COLOR,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      element.title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
    return appDrawerItems;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Theme.of(context).primaryColor,
      child: ListView(
        children: this._buildAppDrawerItems(context),
      ),
    );
  }
}

class AppDrawerItem {
  final String title;
  final IconData icon;
  final String routeName;

  AppDrawerItem(this.title, this.icon, this.routeName);
}
