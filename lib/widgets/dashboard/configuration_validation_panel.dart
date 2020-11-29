import 'package:flutter/material.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/configuration_validator.dart'
    as configurationValidator;
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:tuple/tuple.dart';

/// A widget that executes a static analysis of the app settings.
///
/// This widget does not try to establish a connection to the storage
/// system via the given app settings. Instead, it analyzes whether some
/// settings are invalid, empty, or missing completely.
class ConfigurationValidationPanel extends StatelessWidget {
  final StorageConnectionCredentials storageConnectionCredentials;
  final String logFileDirectoryPath;

  ConfigurationValidationPanel({
    this.storageConnectionCredentials,
    this.logFileDirectoryPath,
  });

  Widget _configurationValidationWidget(
      BuildContext context,
      String configurationName,
      Tuple2<bool, String> configurationValidationResult) {
    var validationSucceeded = configurationValidationResult.item1;
    var validationMessage = configurationValidationResult.item2;
    // if (validateConfigurationFunction != null) {
    //   final result = validateConfigurationFunction(configurationValue)
    //       as Tuple2<bool, String>;
    //   validationSucceeded = result.item1;
    //   validationMessage = result.item2;
    // }
    return Row(
      children: [
        Container(
          width: 40,
          child: Checkbox(
            activeColor: Colors.transparent,
            checkColor: validationSucceeded
                ? Theme.of(context).accentColor
                : constants.LIGHT_RED,
            value: validationSucceeded ? true : null,
            tristate: true,
            onChanged: null,
          ),
        ),
        Expanded(
          child: Text(
            validationSucceeded
                ? configurationName
                : '$configurationName: $validationMessage',
            style: TextStyle(
              color: constants.TEXT_COLOR,
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration Validation',
                      style: TextStyle(
                        color: constants.LIGHT_GREY,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        _configurationValidationWidget(
                          context,
                          'Endpoint',
                          configurationValidator.validateEndpoint(
                            this.storageConnectionCredentials?.endpoint,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Port',
                          configurationValidator.validatePort(
                            this.storageConnectionCredentials?.port,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Region',
                          configurationValidator.validateRegion(
                            this.storageConnectionCredentials?.region,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Bucket',
                          configurationValidator.validateBucket(
                            this.storageConnectionCredentials?.bucket,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Access Key',
                          configurationValidator.validateAccessKey(
                            this.storageConnectionCredentials?.accessKey,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Secret Key',
                          configurationValidator.validateSecretKey(
                            this.storageConnectionCredentials?.secretKey,
                          ),
                        ),
                        _configurationValidationWidget(
                          context,
                          'Log File Directory',
                          configurationValidator.validateLogFileDirectory(
                            this.logFileDirectoryPath,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
