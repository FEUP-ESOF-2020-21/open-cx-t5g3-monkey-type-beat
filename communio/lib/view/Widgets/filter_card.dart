import 'package:flutter/material.dart';

class FilterCard extends StatefulWidget {
  final String filter;
  final Function removeFilter;
  final String filterType;

  FilterCard({Key key, @required this.filter, @required this.removeFilter, @required this.filterType});

  @override
  _FilterCardState createState() => _FilterCardState(filter, removeFilter, filterType);
}

class _FilterCardState extends State<FilterCard> {
  final Function removeFilter;
  final String filter;
  final String filterType;
  final horizontalPadding = 5.0;
  final horizontalMargin = 5.0;

  _FilterCardState(this.filter, this.removeFilter, this.filterType);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryVariant,
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin:
            EdgeInsets.only(right: horizontalMargin, left: horizontalMargin),
        child: Container(
          padding: EdgeInsets.only(
              left: horizontalPadding, right: horizontalPadding),
          child: Row(children: <Widget>[
            Text(
              filter,
              style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 0),
            ),
            if(filterType == 'filter' || filterType == 'userInterest')
              IconButton(
                onPressed: () {
                  this.removeFilter();
                  if(filterType == 'filter')
                    Navigator.of(context).pushNamed('/PeopleSearch');
                  else
                    Navigator.of(context).pushNamed('/Profile');
                },
                icon: Icon(
                  Icons.cancel,
                  size: 24.0,
                  semanticLabel: filter,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
