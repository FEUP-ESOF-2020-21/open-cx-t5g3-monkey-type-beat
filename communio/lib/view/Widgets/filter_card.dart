import 'package:flutter/material.dart';

class FilterCard extends StatefulWidget {
  final String filter;
  final Function removeFilter;

  FilterCard({Key key, @required this.filter, @required this.removeFilter});

  @override
  _FilterCardState createState() => _FilterCardState(filter, removeFilter);
}

class _FilterCardState extends State<FilterCard> {
  final Function removeFilter;
  final String filter;
  final horizontalPadding = 5.0;
  final horizontalMargin = 5.0;

  _FilterCardState(this.filter, this.removeFilter);

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
            IconButton(
              onPressed: () {
                this.removeFilter();
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
