import 'package:emotion/pages/home_page.dart';
import 'package:emotion/pages/local_log_files_page.dart';
import 'package:emotion/pages/remote_log_files_page.dart';
import 'package:emotion/pages/settings_page.dart';
import 'package:emotion/utils/constants.dart' as constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatelessWidget {
  final int activeListItemIndex;
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem(
      'Home Page',
      FontAwesomeIcons.home,
      HomePage(),
    ),
    new AppDrawerItem(
      'Profiles',
      FontAwesomeIcons.userAlt,
      HomePage(),
    ),
    new AppDrawerItem(
      'Local Log Files',
      FontAwesomeIcons.solidFolder,
      LocalLogFilesPage(),
    ),
    new AppDrawerItem(
      'Remote Log Files',
      FontAwesomeIcons.cloud,
      RemoteLogFilesPage(),
    ),
    new AppDrawerItem(
      'Settings',
      FontAwesomeIcons.cog,
      SettingsPage(),
    ),
  ];

  AppDrawer(this.activeListItemIndex);

  List<Widget> _buildAppDrawerItems(BuildContext context) {
    final appDrawerItems = List<Widget>();
    this.appDrawerItems.asMap().forEach((index, element) {
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
                  color: this.activeListItemIndex == index
                      ? Theme.of(context).accentColor.withOpacity(0.5)
                      : Colors.transparent,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(7),
              color: this.activeListItemIndex == index
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              child: InkWell(
                splashColor: Theme.of(context).accentColor,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context, _, __) {
                        return element.destinationPage;
                      },
                    ),
                  );
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
        children: _buildAppDrawerItems(context),
      ),
    );
  }
}

class AppDrawerItem {
  final String title;
  final IconData icon;
  final Widget destinationPage;

  AppDrawerItem(this.title, this.icon, this.destinationPage);
}
