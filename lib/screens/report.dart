import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

const List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currYear = DateTime.now().year;
  int yearLinit = 10;

  final _dropDownCustomBGKey = GlobalKey<DropdownSearchState<String>>();

  MenuProps menuPropsStyle = const MenuProps(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
        topLeft: Radius.zero,
        topRight: Radius.zero,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: newVariable,
        ),
      ),
    );
  }

  var newVariable = <DropdownSearch<Object>>[
    DropdownSearch<String>(
      items: (f, cs) =>
          ['Facebook', 'Twitter', 'Instagram', 'SnapChat', 'Other'],
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select  Department",
          hintText: "Select an department name",
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        menuProps: menuPropsStyle,
      ),
    ),
    DropdownSearch<String>(
        items: (f, cs) =>
            ['Facebook', 'Twitter', 'Instagram', 'SnapChat', 'Other'],
        decoratorProps: const DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: "Select Employee",
            hintText: "Select an employee name",
          ),
        ),
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          menuProps: menuPropsStyle,
        )),
    DropdownSearch<String>(
      items: (f, cs) => months,
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select Year",
        ),
      ),
      popupProps: const PopupProps.menu(
        menuProps: menuPropsStyle,
      ),
    ),
    DropdownSearch<int>(
      items: (f, cs) => List.generate(yearLinit, (i) => currYear - i),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select Year",
        ),
      ),
      popupProps: menuPropsStyle,
    ),
  ];
}

class FormSelect extends StatelessWidget {
  const FormSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownSearch(
      items: (f, cs) => [1],
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select Year",
        ),
      ),
      popupProps: const MenuProps(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.zero,
            topRight: Radius.zero,
          ),
        ),
      ),
    );
  }
}
