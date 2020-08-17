import 'package:flutter/material.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_actions.dart';
import '../util/multi_select_list_type.dart';

/// A bottom sheet widget containing either a classic checkbox style list, or a chip style list.
class MultiSelectBottomSheet<V> extends StatefulWidget
    with MultiSelectActions<V> {
  final MultiSelectListType listType;
  final Text title;
  final List<MultiSelectItem<V>> items;
  final List<V> initialValue;
  final void Function(List<V>) onSelectionChanged;
  final void Function(List<V>) onConfirm;
  final bool searchable;
  final Text confirmText;
  final Text cancelText;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  MultiSelectBottomSheet({
    @required this.items,
    @required this.initialValue,
    this.title,
    this.onSelectionChanged,
    this.onConfirm,
    this.listType,
    this.cancelText,
    this.confirmText,
    this.searchable,
    this.initialChildSize,
    this.minChildSize,
    this.maxChildSize,
  });

  @override
  _MultiSelectBottomSheetState<V> createState() =>
      _MultiSelectBottomSheetState<V>(items);
}

class _MultiSelectBottomSheetState<V> extends State<MultiSelectBottomSheet<V>> {
  List<V> _selectedValues = List<V>();
  bool _showSearch = false;
  List<MultiSelectItem<V>> _items;

  _MultiSelectBottomSheetState(this._items);

  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedValues.addAll(widget.initialValue);
    }
  }

  Widget _buildListItem(MultiSelectItem<V> item) {
    return CheckboxListTile(
      value: _selectedValues.contains(item.value),
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        setState(() {
          _selectedValues =
              widget.onItemCheckedChange(_selectedValues, item.value, checked);
        });
      },
    );
  }

  Widget _buildChipItem(MultiSelectItem<V> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        label: Text(item.label),
        selected: _selectedValues.contains(item.value),
        onSelected: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize ?? 0.3,
        minChildSize: widget.minChildSize ?? 0.3,
        maxChildSize: widget.maxChildSize ?? 0.6,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _showSearch
                        ? Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _items = widget.updateSearchQuery(
                                        val, widget.items);
                                  });
                                },
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: widget.title != null
                                ? Text(
                                    widget.title.data,
                                    style: widget.title.style ??
                                        TextStyle(fontSize: 18),
                                  )
                                : Text(
                                    "Select",
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                    widget.searchable != null && widget.searchable
                        ? IconButton(
                            icon: _showSearch
                                ? Icon(Icons.close)
                                : Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                _showSearch = widget.onSearchTap(_showSearch);
                                if (!_showSearch) _items = widget.items;
                              });
                            },
                          )
                        : Padding(
                            padding: EdgeInsets.all(15),
                          ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget.listType == null ||
                          widget.listType == MultiSelectListType.LIST
                      ? ListTileTheme(
                          contentPadding:
                              EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                          child: ListBody(
                            children: _items.map(_buildListItem).toList(),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(10),
                          child: Wrap(
                            children: _items.map(_buildChipItem).toList(),
                          ),
                        ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          widget.onCancelTap(
                              context, widget.initialValue);
                        },
                        child: widget.cancelText ?? Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          widget.onConfirmTap(
                              context, _selectedValues, widget.onConfirm);
                        },
                        child: widget.confirmText ?? Text("Confirm"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
