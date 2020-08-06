import 'package:emotion/pages/home_page.dart';
import 'package:emotion/pages/local_log_files_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int activeListItemIndex;
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem('Home Page', HomePage()),
    new AppDrawerItem('Drivers', HomePage()),
    new AppDrawerItem('Local Log Files', LocalLogFilesPage()),
    new AppDrawerItem('Remote Log Files', HomePage()),
    new AppDrawerItem('Settings', HomePage()),
  ];

  AppDrawer(this.activeListItemIndex);

  Widget _buildImageAndTitleContainer(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                child: Text('John Doe'),
                radius: 50,
                foregroundColor: Colors.black,
                backgroundImage: NetworkImage(
                    'https://cdn4.vectorstock.com/i/1000x1000/46/73/person-gray-photo-placeholder-man-material-design-vector-23804673.jpg'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Telemetry Log Client',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppDrawerItems(BuildContext context) {
    final appDrawerItems = List<Widget>();
    this.appDrawerItems.asMap().forEach((index, element) {
      appDrawerItems.add(
        Ink(
          color: activeListItemIndex == index
              ? Colors.grey.shade300
              : Colors.transparent,
          child: ListTile(
            title: Text(element.title),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                    return element.destinationPage;
                  },
                ),
              );
            },
          ),
        ),
      );
    });
    return appDrawerItems;
  }

  @override
  Widget build(BuildContext context) {
    final childWidgets = <Widget>[
      _buildImageAndTitleContainer(context),
      Divider(
        indent: 5,
        endIndent: 5,
      ),
    ];
    childWidgets.addAll(_buildAppDrawerItems(context));

    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
            width: 2.0,
          ),
        ),
      ),
      child: ListView(
        children: childWidgets,
      ),
    );
  }
}

class AppDrawerItem {
  final String title;
  final Widget destinationPage;

  AppDrawerItem(this.title, this.destinationPage);
}
