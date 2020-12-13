import 'dart:ui';
import 'dart:convert';
import 'package:communio/controller/redux/action_creators.dart';
import 'package:communio/model/app_state.dart';
import 'package:communio/model/known_person.dart';
import 'package:communio/view/Pages/general_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:redux/src/store.dart';

import 'package:communio/model/person_found.dart';
import 'package:communio/view/Widgets/friend_information.dart';
import 'package:communio/view/Widgets/photo_avatar.dart';
import 'package:flutter/widgets.dart';

class HomePageView extends StatelessWidget {
  KnownPerson person;
  Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return GeneralPageView(
      child: createScrollableCardView(context),
      floatingActionButton: createActionButton(context),
    );
  }

  Widget createScrollableCardView(BuildContext context) {
    getPerson(context).then((value) => person = value);
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(queryFriendsList(store.state.content['user_id']));
    return StoreConnector<AppState, Set<KnownPerson>>(
      converter: (store) => store.state.content['friends'],
      builder: (context, friends) {
        return Container(
          child: ListView(
            shrinkWrap: false,
            padding: EdgeInsets.all(20.0),
            children: (person == null)
                ? <Widget>[
                    new Text(
                      '\n\n\n\nLoading...',
                      style: new TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ), // Wait for data to load
                  ]
                : <Widget>[
                    new Text(
                      'Welcome back,',
                      style: new TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    new Text(
                      person.name + '!\n',
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                    if (friends.length > 0) // has friends
                      new Text('\nSome of the friends you\'ve made:\n')
                    else // has no friends
                      new Text(
                        '\nLooks like you still have no connections.\n\nExplore the app to meet new people!',
                        style: new TextStyle(fontSize: 30),
                      ),
                    for (var i = 0; i < friends.length && i < 4; i++)
                      generatePersonCard(
                          context,
                          new PersonFound(
                              name: friends.toList()[i].name,
                              photo: friends.toList()[i].photo,
                              location: friends.toList()[i].location,
                              interests: friends.toList()[i].interests,
                              description: friends.toList()[i].description),
                          i),
                  ],
          ),
        );
      },
    );
  }

  Future<KnownPerson> getPerson(BuildContext context) async {
    final store = StoreProvider.of<AppState>(context);
    final response = await http.get(store.state.content['profile'] +
        '/profile/' +
        store.state.content['user_id']);
    final map = json.decode(utf8.decode(response.bodyBytes));
    return KnownPerson.fromJson(map);
  }

  Widget createActionButton(BuildContext context) {
    return new FloatingActionButton(
      key: new Key('increment'),
      onPressed: () =>
          {StoreProvider.of<AppState>(context).dispatch(incrementCounter())},
      tooltip: 'Increment',
      child: new Icon(Icons.add),
    );
  }

  generatePersonCard(BuildContext context, PersonFound person, int i) {
    return new Container(
        key: Key('person-card-$i'),
        padding: EdgeInsets.only(right: 22, left: 22, top: 3, bottom: 3),
        margin: EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            PhotoAvatar(
              photo: person.photo,
            ),
            FriendInformation(
              name: person.name,
              location: person.location,
            ),
          ],
        ));
  }
}
