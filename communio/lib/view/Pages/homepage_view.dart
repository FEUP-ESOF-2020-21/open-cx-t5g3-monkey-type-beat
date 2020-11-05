import 'dart:ui';
import 'package:communio/model/app_state.dart';
import 'package:communio/redux/action_creators.dart';
import 'package:communio/view/Pages/general_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:communio/model/person_found.dart';
import 'package:communio/view/Widgets/friend_information.dart';
import 'package:communio/view/Widgets/photo_avatar.dart';
import 'package:flutter/widgets.dart';



class HomePageView extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return GeneralPageView(
      child: createScrollableCardView(context),
      floatingActionButton: createActionButton(context),
    );
  }

  Widget createScrollableCardView(BuildContext context) {
    return  StoreConnector<AppState, int>(
      converter: (store) => store.state.content['counter'],
      builder: (context, counter){
        return Container(
          child:
            ListView(
              shrinkWrap: false,
              padding: EdgeInsets.all(20.0),
              children:<Widget>[
                 new Text(
                'Welcome to Commun.io!',
                   style: new TextStyle(color: Colors.black, fontSize: 30, decoration: TextDecoration.underline),
                   textAlign: TextAlign.center,
                ),
                new Container(
                  child: new Text('\nCommun.io is an application for you to meet other people during conferences.')
                ),
                new Text('People near you:\n'),
                generatePersonCard(context, new PersonFound(name: 'Happy Guy', photo: 'https://pbs.twimg.com/profile_images/1161700430528831489/BR92EsDM_400x400.jpg', location: 'Porto', interests: null, description: 'A guy'), 1),
                generatePersonCard(context, new PersonFound(name: 'Happy Girl', photo: 'https://www.demilked.com/magazine/wp-content/uploads/2019/04/5cb6d34f775c2-stock-models-share-weirdest-stories-photo-use-102-5cb5c725bc378__700.jpg', location: 'Porto', interests: null, description: 'A girl'), 2),
                generatePersonCard(context, new PersonFound(name: 'Business Guy', photo: 'https://i.pinimg.com/originals/79/2e/46/792e467ba45b561ee5931e4face9fc6f.jpg', location: 'Porto', interests: null, description: 'A guy'), 3),
                generatePersonCard(context, new PersonFound(name: 'Corndog Guy', photo: 'https://i.pinimg.com/originals/43/c7/42/43c742be9d6558003b35f0ac40b4dbdf.jpg', location: 'Porto', interests: null, description: 'A guy'), 4),
              ],
            ),
        );
      },
    );
  }

  Widget createActionButton(BuildContext context){
    return new FloatingActionButton(
      key: new Key('increment'),
      onPressed: () => {
        StoreProvider.of<AppState>(context).dispatch(incrementCounter())  
      },
      tooltip: 'Increment',
      child: new Icon(Icons.add),
    );
  }

  generatePersonCard(BuildContext context, PersonFound person, int i) {
    return new Container(
        key: Key('person-card-$i'),
        padding: EdgeInsets.only(
            right: 22,
            left: 22,
            top: 3,
            bottom: 3),
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


