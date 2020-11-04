import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/floating_action_button_position.dart';
import 'package:log_storage_client/widgets/upload_profile_edit_dialog.dart';

class ProfilesView extends StatefulWidget {
  ProfilesView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  final profiles = [
    UploadProfile('FSG Nürnburg 2019', 'Jens Hertfelder', 'FSG, Nürnburgring',
        'Rainy track',
        enabled: true),
    UploadProfile('FSA Wien 2019', 'Fabian Langer', 'FSA, Wien', '-'),
    UploadProfile('Werkstatt', '-', 'Werkstatt', 'Test'),
  ];

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
          builder: (context) => UploadProfileEditDialog(),
        );
        if (newUploadProfile != null) {
          setState(() {
            this.profiles.add(newUploadProfile);
          });
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
                ? Theme.of(context).accentColor
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
                  Text(
                    this.profiles[index].name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Switch(
                    value: this.profiles[index].enabled,
                    onChanged: (enabled) {
                      setState(() {
                        if (enabled) {
                          this.profiles.forEach((element) {
                            element.enabled = false;
                          });
                          this.profiles[index].enabled = enabled;
                        }
                      });
                    },
                    activeColor: Colors.white,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 0,
                  right: 12,
                  top: 12,
                ),
                child: Column(
                  children: [
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
                        Text(
                          this.profiles[index].driver,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 18),
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
                        Text(
                          this.profiles[index].eventOrLocation,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 18),
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
                        Text(
                          this.profiles[index].notes,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: this.profiles[index].enabled
                    ? SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          EmotionDesignButton(
                            onPressed: () async {
                              final editedUploadProfile =
                                  await showCupertinoModalPopup<UploadProfile>(
                                context: context,
                                filter: ImageFilter.blur(
                                  sigmaX: 2,
                                  sigmaY: 2,
                                ),
                                builder: (context) => UploadProfileEditDialog(
                                  uploadProfile: this.profiles[index],
                                ),
                              );
                              if (editedUploadProfile != null) {
                                setState(() {
                                  this.profiles[index] = editedUploadProfile;
                                });
                              }
                            },
                            child: Text(
                              'Edit',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          EmotionDesignButton(
                            onPressed: () {
                              setState(() {
                                this.profiles.remove(this.profiles[index]);
                              });
                            },
                            child: Text(
                              'Delete',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
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
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                      padding: EdgeInsets.only(bottom: 64),
                      crossAxisCount:
                          (MediaQuery.of(context).size.width > 1200) ? 4 : 2,
                      itemCount: this.profiles.length,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 32,
                      itemBuilder: (BuildContext _, int index) =>
                          this._profileCard(index),
                      staggeredTileBuilder: (int index) {
                        return StaggeredTile.fit(2);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FloatingActionButtonPosition(
          floatingActionButton: this._createProfileFloatingActionButton(),
        ),
      ],
    );
  }
}
