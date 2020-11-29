import 'package:flutter/material.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/widgets/dashboard/dashboard_panel.dart';

/// A widget that visualizes the following app settings: bucket, endpoint, port, TLS
class ConfigurationPanel extends StatelessWidget {
  final String bucket;
  final String endpoint;
  final String port;
  final bool useTLS;

  ConfigurationPanel({this.bucket, this.endpoint, this.port, this.useTLS});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: Material(
        borderRadius: BorderRadius.circular(constants.BORDER_RADIUS_MEDIUM),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DashboardPanel(
                  title: 'Bucket',
                  content: this.bucket,
                ),
              ),
              VerticalDivider(
                color: constants.DARK_GREY,
              ),
              Expanded(
                child: DashboardPanel(
                  title: 'Endpoint',
                  content: this.endpoint,
                ),
              ),
              VerticalDivider(
                color: constants.DARK_GREY,
              ),
              Expanded(
                child: DashboardPanel(
                  title: 'Port',
                  content: this.port,
                ),
              ),
              VerticalDivider(
                color: constants.DARK_GREY,
              ),
              Expanded(
                child: DashboardPanel(
                  title: 'TLS',
                  content: this.useTLS.toString(),
                  highlightedContentColor:
                      (this.useTLS != null) && (this.useTLS)
                          ? Theme.of(context).accentColor
                          : constants.LIGHT_RED,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
