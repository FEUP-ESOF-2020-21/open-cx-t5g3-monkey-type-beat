import 'dart:convert';
import 'dart:io';

import 'package:communio/controller/redux/action_creators.dart';
import 'package:communio/controller/redux/actions.dart';
import 'package:communio/model/app_state.dart';
import 'package:communio/model/known_person.dart';
import 'package:communio/view/Pages/secondary_page_view.dart';
import 'package:communio/view/Widgets/photo_avatar.dart';
import 'package:communio/view/Widgets/profile_interests.dart';
import 'package:communio/view/Widgets/social_media_column.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';


import '../theme.dart';
import 'general_page_view.dart';

class ProfilePage extends StatelessWidget {
  final String profileId;
  KnownPerson knownPerson;
  final bool edit;
  final bool isUser;
  static Future<KnownPerson> person = null;

  ProfilePage(
      {this.profileId,
      this.knownPerson,
      @required this.edit,
      @required this.isUser}) {
    if (person == null) person = getPerson(profileId);
  }

  @override
  Widget build(BuildContext context) {
    if (knownPerson != null) {
      return buildProfilePage(context, knownPerson);
    }
    return FutureBuilder<List<KnownPerson>>(
        future: Future.wait([getPerson(profileId)]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          print('DATA: ' + snapshot.data.toString());
          return buildProfilePage(context, knownPerson);
        });
  }

  buildProfilePage(BuildContext context, KnownPerson person) {
    if (edit) {
      return GeneralPageView(
        child: this.buildPerson(context, person),
      );
    }
    return SecondaryPageView(
      child: this.buildPerson(context, person),
    );
  }

  buildPerson(BuildContext context, KnownPerson person) {
    final query = MediaQuery.of(context).size;
    final Function(String, String) addingFunc = (interest, type) async {
      final String profile =
          StoreProvider.of<AppState>(context).state.content['user_id'];
      final Map<String, String> body = {'$type': interest};
      await http.put('${DotEnv().env['API_URL']}users/tags/$profile',
          body: json.encode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });
    };
    final Function(String, String) removeFunc = (interest, type) async {
      final String profile =
          StoreProvider.of<AppState>(context).state.content['user_id'];
      final Map<String, String> body = {'$type': interest};
      await http.post('${DotEnv().env['API_URL']}users/tags/$profile',
          body: json.encode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });
    };
    if (profileId != null)
      return ListView(
        children: <Widget>[
          buildImage(context, person, query),
          buildName(person, context, query),
          buildLocation(person, context, query),
          buildDescription(person, context, query),
          buildSocialMedia(person, context, query),
          ProfileInterests(
            interests: person.interests,
            name: 'Interests',
            type: 'tags',
            edit: edit,
            isUser: isUser,
            adding: addingFunc,
            removing: removeFunc,
          ),
          ProfileInterests(
            interests: person.programmingLanguages,
            name: 'Programming Languages',
            type: 'programming_languages',
            edit: edit,
            isUser: isUser,
            adding: addingFunc,
            removing: removeFunc,
          ),
          ProfileInterests(
            interests: person.skills,
            name: 'Skills',
            type: 'skills',
            edit: edit,
            isUser: isUser,
            adding: addingFunc,
            removing: removeFunc,
          ),
          if (isUser) buildDeleteButton(context),
        ],
      );
    else
      return Container(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            shrinkWrap: false,
            children: [Image.asset('assets/icon/icon.png', alignment: Alignment.topCenter, height: 150,),
              Text(
                  '\n\nNo account logged in.\nCreate a new account or login to your account to explore the app!',
                  style: new TextStyle(fontSize: 30, ),
                  textAlign: TextAlign.center
              ),
            ],
          ));
  }

  Widget buildDeleteButton(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = MediaQuery.of(context).size.width * 0.15;

    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Center(
            child: ButtonTheme(
                buttonColor: communRedColor,
                minWidth: width,
                height: height,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(height * 0.25)),
                  textColor: Theme.of(context).canvasColor,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 35, horizontal: 40),
                                height: 225,
                                width: 350,
                                child: ListView(children: <Widget>[
                                  Text(
                                      "Are you sure you want to delete your account?",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .apply(
                                            color: cyanColor,
                                            fontWeightDelta: 2,
                                          )),
                                  buildDeleteFormButtons(context),
                                ]),
                              ));
                        });
                  },
                  child: Text(
                    'Delete Account',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(fontSizeDelta: -5),
                  ),
                ))));
  }

  Widget padWidget({Widget child, Size query}) {
    return Padding(
        padding: EdgeInsets.only(
            top: query.height * 0.005,
            bottom: query.height * 0.005,
            left: query.height * 0.05,
            right: query.height * 0.05),
        child: child);
  }

  Widget buildName(KnownPerson person, BuildContext context, Size query) {
    return padWidget(
        child: Center(
          child: (person.name == null)
              ? new Text("")
              : Text(
                  person.name,
                  style: Theme.of(context)
                      .textTheme
                      .body2
                      .apply(fontSizeDelta: 10),
                ),
        ),
        query: query);
  }

  buildImage(BuildContext context, KnownPerson person, Size query) {
    final double _picRatio = 0.217;

    return padWidget(
        child: Container(
          margin: EdgeInsets.only(top: query.height * 0.03),
          padding: EdgeInsets.only(
              left: query.height * 0.1, right: query.height * 0.1),
          height: query.height * _picRatio,
          child: PhotoAvatar(
            photo: (person.photo == null) ? "/" : person.photo,
          ),
        ),
        query: query);
  }

  buildLocation(KnownPerson person, BuildContext context, Size query) {
    return padWidget(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.location_on,
                color: cyanColor,
              ),
              (person.location == null)
                  ? new Text("")
                  : Text(
                      person.location,
                      style: Theme.of(context).textTheme.body2,
                    )
            ],
          ),
        ),
        query: query);
  }

  buildDescription(KnownPerson person, BuildContext context, Size query) {
    return buildRowWithItem(
        context,
        Icons.info,
        Container(
          width: query.width * 0.75,
          child: (person.description == null)
              ? new Text("")
              : Text(
                  person.description,
                  style: Theme.of(context).textTheme.body2,
                ),
        ),
        query);
  }

  buildSocialMedia(KnownPerson person, BuildContext context, Size query) {
    if (knownPerson.socials == null) return Container();
    return buildRowWithItem(context, Icons.person,
        SocialMediaColumn(person: person, edit: edit), query);
  }

  buildRowWithItem(
      BuildContext context, IconData iconData, Widget widget, Size query) {
    return Padding(
      padding: EdgeInsets.only(
        top: query.height * 0.03,
        bottom: query.height * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: query.width * 0.13,
            child: Center(
              child: Icon(
                iconData,
                color: cyanColor,
              ),
            ),
          ),
          Container(
            child: widget,
          )
        ],
      ),
    );
  }

  Widget buildDeleteFormButtons(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.2;
    final height = MediaQuery.of(context).size.width * 0.10;

    return Padding(
      padding: EdgeInsets.only(bottom: 30, top: 30),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ButtonTheme(
              minWidth: width,
              height: height,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(height * 0.25)),
                textColor: Theme.of(context).canvasColor,
                onPressed: () {
                  StoreProvider.of<AppState>(context)
                      .dispatch(UpdateUser(null));
                  Toast.show('Deleting...', context, duration: 5);
                  Navigator.of(context).pushNamed('/LogIn');
                },
                child: Text(
                  'Yes',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .apply(fontSizeDelta: -5),
                ),
              ),
            ),
            ButtonTheme(
                minWidth: width,
                height: height,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(height * 0.25)),
                  textColor: Theme.of(context).canvasColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'No',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .apply(fontSizeDelta: -5),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<KnownPerson> getPerson(String profileId) async {
    final response =
        await http.get('${DotEnv().env['API_URL']}users/profile/$profileId');
    final map = json.decode(utf8.decode(response.bodyBytes));
    this.knownPerson = KnownPerson.fromJson(map);
    return KnownPerson.fromJson(map);
  }
}
