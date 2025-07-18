import 'package:flutter/material.dart';

class PersonOption {
  final String name;
  final String personalId;
  PersonOption({required this.name, required this.personalId});
}

class SearchablePersonComboBox extends StatelessWidget {
  final List<PersonOption> options;
  final PersonOption? value;
  final void Function(PersonOption?) onChanged;
  final String hintText;
  final String? Function(PersonOption?)? validator;

  const SearchablePersonComboBox({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.hintText = '',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<PersonOption>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return options;
        }
        return options.where((PersonOption option) {
          return option.name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      displayStringForOption: (PersonOption option) => option.name,
      initialValue: value != null ? TextEditingValue(text: value!.name) : null,
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.blue[50],
          ),
          validator: (v) => validator != null ? validator!(value) : null,
        );
      },
    );
  }
}
