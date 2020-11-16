import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/services/upload_profile_service.dart';
import 'package:log_storage_client/utils/app_settings.dart' as AppSettings;
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/floating_action_button_position.dart';
import 'package:log_storage_client/widgets/upload_profile_edit_dialog.dart';

class ProfilesView extends StatefulWidget {
  ProfilesView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  List<UploadProfile> profiles = [];

  @override
  initState() {
    super.initState();
    this._loadUploadProfiles();
    locator<UploadProfileService>()
        .getUploadProfileChangeStream()
        .listen((_) => this._loadUploadProfiles());
  }

  void _loadUploadProfiles() {
    AppSettings.getUploadProfiles().then((List<UploadProfile> uploadProfiles) {
      if (mounted) {
        setState(() {
          this.profiles = uploadProfiles;
        });
      }
    });
  }

  void _persistUploadProfilesAndEmitChangeEvent() async {
    await AppSettings.setUploadProfiles(this.profiles);
    locator<UploadProfileService>().getUploadProfileChangeSink().add(null);
  }

  FloatingActionButton _createProfileFloatingActionButton() {
    return FloatingActionButton.extended(
      icon: Icon(
        Icons.add_outlined,
        color: Colors.white,
      ),
      label: Text(
        'Create',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      onPressed: () async {
        final newUploadProfile = await showCupertinoModalPopup<UploadProfile>(
          context: context,
          filter: ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          builder: (context) => UploadProfileEditDialog(
              this.profiles.map((p) => p.name).toList()),
        );
        if (newUploadProfile != null) {
          if (mounted) {
            setState(() {
              this.profiles.add(newUploadProfile);
            });
          }
          this._persistUploadProfilesAndEmitChangeEvent();
        }
      },
    );
  }

  Widget _profileCard(int index) {
    return Container(
      margin: EdgeInsets.only(top: 30, left: 30, right: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
        boxShadow: [
          BoxShadow(
            color: this.profiles[index].enabled
                ? Theme.of(context).accentColor.withOpacity(0.5)
                : Theme.of(context).primaryColor.withOpacity(0),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
        color: this.profiles[index].enabled
            ? Theme.of(context).accentColor
            : Theme.of(context).primaryColor,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
        color: this.profiles[index].enabled
            ? Theme.of(context).accentColor
            : Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      this.profiles[index].name,
                      style: Theme.of(context).textTheme.headline5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Switch(
                    value: this.profiles[index].enabled,
                    onChanged: (enabled) {
                      // Don't allow to directly disable an UploadProfile
                      if (enabled) {
                        setState(() {
                          this.profiles.forEach((element) {
                            element.enabled = false;
                          });
                          this.profiles[index].enabled = true;
                        });
                        this._persistUploadProfilesAndEmitChangeEvent();
                      }
                    },
                    activeColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Driver:',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      this.profiles[index].driver,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Event / Location:',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      this.profiles[index].eventOrLocation,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes:',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      this.profiles[index].notes,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 40,
                child: this.profiles[index].enabled
                    ? SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          EmotionDesignButton(
                            child: Text(
                              'Edit',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () async {
                              final editedUploadProfile =
                                  await showCupertinoModalPopup<UploadProfile>(
                                context: context,
                                filter: ImageFilter.blur(
                                  sigmaX: 2,
                                  sigmaY: 2,
                                ),
                                builder: (context) => UploadProfileEditDialog(
                                  this.profiles.map((p) => p.name).toList(),
                                  uploadProfile: this.profiles[index],
                                ),
                              );
                              if (editedUploadProfile != null) {
                                if (mounted) {
                                  setState(() {
                                    this.profiles[index] = editedUploadProfile;
                                  });
                                }
                                this._persistUploadProfilesAndEmitChangeEvent();
                              }
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          EmotionDesignButton(
                            child: Text(
                              'Delete',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  this.profiles.remove(this.profiles[index]);
                                });
                              }
                              this._persistUploadProfilesAndEmitChangeEvent();
                            },
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

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    double gridViewPadding = windowWidth > 1800
        ? 200
        : windowWidth > 1700
            ? 150
            : windowWidth > 1500
                ? 100
                : windowWidth > 1200
                    ? 10
                    : 100;

    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 48,
                  top: 32,
                ),
                child: Text(
                  'Upload Profiles',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              Expanded(
                child: StaggeredGridView.countBuilder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: 64,
                    left: gridViewPadding,
                    right: gridViewPadding,
                  ),
                  crossAxisCount: windowWidth > 1200 ? 4 : 2,
                  itemCount: this.profiles?.length,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 32,
                  itemBuilder: (BuildContext _, int index) =>
                      this._profileCard(index),
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                ),
              ),
            ],
          ),
        ),
        FloatingActionButtonPosition(
          floatingActionButton: this._createProfileFloatingActionButton(),
        ),
      ],
    );
  }
}
