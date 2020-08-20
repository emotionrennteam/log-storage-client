import 'package:emotion/pages/home_page.dart';
import 'package:emotion/pages/local_log_files_page.dart';
import 'package:emotion/pages/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int activeListItemIndex;
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem('Home Page', HomePage()),
    new AppDrawerItem('Profiles', HomePage()),
    new AppDrawerItem('Local Log Files', LocalLogFilesPage()),
    new AppDrawerItem('Remote Log Files', HomePage()),
    new AppDrawerItem('Settings', SettingsPage()),
  ];

  AppDrawer(this.activeListItemIndex);

  List<Widget> _buildAppDrawerItems(BuildContext context) {
    final appDrawerItems = List<Widget>();
    this.appDrawerItems.asMap().forEach((index, element) {
      appDrawerItems.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
            top: 5,
          ),
          child: Container(
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Theme.of(context).primaryColor,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context, _, __) {
                        return element.destinationPage;
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 5.0,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: this.activeListItemIndex == index
                                ? Theme.of(context).accentColor
                                : Colors.transparent,
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
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
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      child: ListView(
        children: _buildAppDrawerItems(context),
      ),
    );
  }
}

class AppDrawerItem {
  final String title;
  final Widget destinationPage;

  AppDrawerItem(this.title, this.destinationPage);
}
