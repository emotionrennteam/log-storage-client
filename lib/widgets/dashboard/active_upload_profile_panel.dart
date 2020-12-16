import 'package:flutter/material.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/widgets/dashboard/dashboard_panel.dart';

class ActiveUploadPanel extends StatelessWidget {
  final UploadProfile activeUploadProfile;

  ActiveUploadPanel({this.activeUploadProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(constants.BORDER_RADIUS_MEDIUM),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 16,
              ),
              DashboardPanel(
                title: 'Active Upload Profile',
                content: this.activeUploadProfile?.name,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
