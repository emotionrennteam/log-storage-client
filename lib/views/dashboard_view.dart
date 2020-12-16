import 'package:flutter/foundation.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/app_settings.dart' as appSettings;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:log_storage_client/utils/storage_manager.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/widgets/dashboard/active_upload_profile_panel.dart';
import 'package:log_storage_client/widgets/dashboard/buckets_panel.dart';
import 'package:log_storage_client/widgets/dashboard/configuration_panel.dart';
import 'package:log_storage_client/widgets/dashboard/configuration_validation_panel.dart';
import 'package:log_storage_client/widgets/dashboard/region_panel.dart';
import 'package:log_storage_client/widgets/dashboard/storage_connection_panel.dart';
import 'package:minio/models.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String _bucket;
  List<Bucket> _buckets;
  String _endpoint;
  String _port;
  String _region;
  UploadProfile _activeUploadProfile;
  bool _useTLS = false;
  String _logFileDirectoryPath;
  StorageConnectionCredentials _storageConnectionCredentials;

  @override
  initState() {
    super.initState();

    appSettings.getStorageBucket().then((String bucket) {
      this._bucket = bucket == null || bucket.isEmpty ? '-' : bucket;
    });

    appSettings.getStorageConnectionCredentials().then((credentials) {
      if (mounted) {
        setState(() {
          this._storageConnectionCredentials = credentials;
          this._endpoint =
              credentials.endpoint == null ? '-' : credentials.endpoint;
          this._port =
              credentials.port == null ? '-' : credentials.port.toString();
          this._useTLS =
              credentials.tlsEnabled == null ? false : credentials.tlsEnabled;
        });
      }
      validateConnection(credentials).then((result) {
        if (mounted) {
          setState(() {
            this._region = result.item3;
            this._buckets = result.item4;
          });
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar(error.toString(), true),
      );
    });

    appSettings.getUploadProfiles().then((List<UploadProfile> profiles) {
      if (mounted) {
        setState(() {
          if (profiles != null && profiles.isNotEmpty) {
            this._activeUploadProfile =
                profiles.where((profile) => profile.enabled)?.first;
          }
        });
      }
    });

    appSettings.getLogFileDirectoryPath().then((logFileDirectoryPath) {
      this._logFileDirectoryPath = logFileDirectoryPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      padding: EdgeInsets.symmetric(
        horizontal: 64,
        vertical: 42,
      ),
      crossAxisSpacing: 32,
      mainAxisSpacing: 32,
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ConfigurationPanel(
            bucket: this._bucket,
            endpoint: this._endpoint,
            port: this._port,
            useTLS: this._useTLS,
          );
        } else if (index == 1) {
          return StorageConnectionPanel();
        } else if (index == 2) {
          return RegionPanel(
            region: this._region,
          );
        } else if (index == 3) {
          return BucketsPanel(
            buckets: this._buckets,
          );
        } else if (index == 4) {
          return ActiveUploadPanel(
            activeUploadProfile: this._activeUploadProfile,
          );
        } else if (index == 5) {
          return ConfigurationValidationPanel(
            storageConnectionCredentials: this._storageConnectionCredentials,
            logFileDirectoryPath: this._logFileDirectoryPath,
          );
        }
        return SizedBox();
      },
      physics: BouncingScrollPhysics(),
      staggeredTileBuilder: (int index) {
        if (index == 0) {
          return StaggeredTile.fit(6);
        } else if (index == 1) {
          return StaggeredTile.fit(3);
        } else if (index == 2) {
          return StaggeredTile.fit(3);
        } else if (index == 3) {
          if (MediaQuery.of(context).size.width > 1500) {
            return StaggeredTile.fit(4);
          }
          return StaggeredTile.fit(6);
        } else if (index == 4) {
          return StaggeredTile.fit(2);
        } else if (index == 5) {
          if (MediaQuery.of(context).size.width < 1500) {
            return StaggeredTile.fit(4);
          }
          return StaggeredTile.fit(3);
        }
        return StaggeredTile.count(1, 1);
      },
    );
  }
}
