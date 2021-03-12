/// Flutter code sample for AnimatedList

// This sample application uses an [AnimatedList] to create an effect when
// items are removed or added to the list.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../adminDashboard.dart';

// ignore: must_be_immutable
class UserListView extends StatefulWidget {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var _list;
  int _selectedItem;

  UserListView(
      this._listKey, this._list, this._selectedItem);

  @override
  _UserListViewState createState() => _UserListViewState(this._listKey, this._list, this._selectedItem);
}

class _UserListViewState extends State<UserListView> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<int> _list;
  int _selectedItem;

  _UserListViewState(this._listKey, this._list, this._selectedItem); // The next item inserted when the user presses the '+' button.

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: _buildItem
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    this.onTap,
    this.selected = false,
     this.animation,
     this.item,
  })   : assert(item >= 0),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4;
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 80.0,
            child: Card(
              color: Colors.primaries[item % Colors.primaries.length],
              child: Center(
                child: Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
