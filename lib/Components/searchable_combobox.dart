import 'package:flutter/material.dart';

/// A simple searchable combobox for Flutter.
/// [items] is a list of DropdownMenuItem<T>.
/// [onChanged] is called with the selected value.
/// [hintText] is shown in the text field.
/// [value] is the currently selected value.
class SearchableComboBox<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?) onChanged;
  final String hintText;
  final String? labelText;
  final String? Function(T?)? validator;

  const SearchableComboBox({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText = '',
    this.labelText,
    this.validator,
  });

  @override
  State<SearchableComboBox<T>> createState() => _SearchableComboBoxState<T>();
}

class _SearchableComboBoxState<T> extends State<SearchableComboBox<T>> {
  late TextEditingController _controller;
  late List<DropdownMenuItem<T>> _filteredItems;
  String _search = '';
  bool _dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _filteredItems = widget.items;
    if (widget.value != null) {
      final selected = widget.items.firstWhereOrNull((item) => item.value == widget.value);
      if (selected != null) {
        _controller.text = selected.child is Text ? (selected.child as Text).data ?? '' : '';
      }
    }
  }

  @override
  void didUpdateWidget(covariant SearchableComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final selected = widget.items.firstWhereOrNull((item) => item.value == widget.value);
      if (selected != null) {
        _controller.text = selected.child is Text ? (selected.child as Text).data ?? '' : '';
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      _filteredItems = widget.items.where((item) {
        final label = item.child is Text ? (item.child as Text).data ?? '' : '';
        return label.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    });
  }

  void _onItemSelected(DropdownMenuItem<T> item) {
    widget.onChanged(item.value);
    setState(() {
      _controller.text = item.child is Text ? (item.child as Text).data ?? '' : '';
      _dropdownOpen = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(widget.labelText!, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        GestureDetector(
          onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
          child: TextFormField(
            controller: _controller,
            readOnly: false,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.blue[50],
              suffixIcon: Icon(_dropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ),
            onChanged: (v) {
              _onSearchChanged(v);
              setState(() => _dropdownOpen = true);
            },
            validator: (v) => widget.validator != null ? widget.validator!(widget.value) : null,
            onTap: () => setState(() => _dropdownOpen = true),
          ),
        ),
        if (_dropdownOpen && _filteredItems.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey.shade100),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: ListView(
              shrinkWrap: true,
              children: _filteredItems.map((item) {
                return ListTile(
                  title: item.child,
                  onTap: () => _onItemSelected(item),
                  selected: widget.value == item.value,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

extension _FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
