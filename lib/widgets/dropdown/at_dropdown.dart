import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class AtDropdown<T> extends StatelessWidget {
  const AtDropdown({
    super.key,
    this.itemAsString,
    required this.labelText,
    required this.hintText,
    required this.validationErrorText,
    required this.items,
    this.itemBuilder,
    this.showSearchBox = false,
    this.onChanged,
    this.title,
    this.dropdownKey,
    this.selectedItem,
  });
  final DropdownSearchOnFind<T> items;
  final String Function(T)? itemAsString;

  final DropdownSearchPopupItemBuilder<T>? itemBuilder;
  final String labelText;
  final String hintText;
  final String validationErrorText;
  final bool showSearchBox;
  final void Function(T?)? onChanged;
  final Widget? title;
  final Key? dropdownKey;
  final T? selectedItem;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      selectedItem: selectedItem,
      key: dropdownKey,
      items: items,
      itemAsString: itemAsString,
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: showSearchBox,
        title: title,
        itemBuilder: itemBuilder,
        menuProps: const MenuProps(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topLeft: Radius.zero,
              topRight: Radius.zero,
            ),
          ),
        ),
      ),
      compareFn: (item1, item2) => item1 == item2,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
      ),
      validator: (value) {
        if (value == null) {
          return validationErrorText;
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
