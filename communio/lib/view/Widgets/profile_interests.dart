import 'package:communio/view/Widgets/filter_card.dart';
import 'package:communio/view/Widgets/textfield_form.dart';
import 'package:flutter/material.dart';

class ProfileInterests extends StatefulWidget {
  final List interests;
  final String type;
  final String name;
  final bool isUser;
  final bool edit;
  final Function(String, String) adding;
  final Function(String, String) removing;

  const ProfileInterests(
      {Key key,
      this.interests,
      this.type,
      @required this.edit,
      @required this.name,
      @required this.isUser,
      this.adding,
      this.removing})
      : super(key: key);

  @override
  _ProfileInterestsState createState() =>
      _ProfileInterestsState(interests, type, edit, name, isUser, adding, removing);
}

class _ProfileInterestsState extends State<ProfileInterests> {
  final List interests;
  final String type;
  final String name;
  final bool isUser;
  final bool edit;
  final Function(String, String) adding;
  final Function(String, String) removing;

  _ProfileInterestsState(this.interests, this.type, this.edit, this.name,
      this.isUser, this.adding, this.removing);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildInterestsCol(context),
    );
  }

  buildInterestsCol(BuildContext context) {
    final List<Widget> children = List();
    final padding = MediaQuery.of(context).size.height * 0.008;
    children.add(buildInterestTitle(context));

    if (interests.isNotEmpty) {
      children.add(Container(
        padding:
            EdgeInsets.symmetric(vertical: padding, horizontal: padding * 3.5),
        child: SizedBox(
          height: Theme.of(context).textTheme.body2.fontSize + 22,
          child: ListView(
            key: Key(buildCurrentInterests(context).length.toString()),
            scrollDirection: Axis.horizontal,
            children: buildCurrentInterests(context),
          ),
        ),
      ));
    }

    if (edit) {
      children.add(Container(
          padding: EdgeInsets.only(bottom: 30),
          child: TextFieldForm(
            callback: addInterest,
            type: type,
          )));
    }

    return children;
  }

  buildInterestTitle(BuildContext context) {
    return Container(
        padding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.065),
        child: Text(
          name,
          style: Theme.of(context).textTheme.body2,
        ));
  }

  buildCurrentInterests(BuildContext context) {
    List<Widget> interestsCards = List();
    interests.asMap().forEach((index, interest) {
      interestsCards.add(Container(
        key: Key('$type-$index'),
        child: FilterCard(
          filter: interest,
          removeFilter: () async {
            if (removing != null) removing(interest, type);
            setState(() {
              interests.remove(interest);
            });
          },
            filterType:
            (isUser) ? 'userInterest' : 'interest',
        ),
      ));
    });
    return interestsCards;
  }

  addInterest(String interest) async {
    final trimmed = interest.trim();
    if (adding != null) adding(trimmed, type);
    setState(() {
      interests.add(trimmed);
    });
  }
}
