import 'package:flutter/material.dart';

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
  final attendance = [
    {
      "date": "2024-11-06",
      "employee_name": "UZAIR AHMED",
      "in_time": "11:02 PM",
      "out_time": "11:10 PM",
      "status": "Present",
    },
    {
      "date": "2024-11-07",
      "employee_name": "UZAIR AHMED",
      "in_time": "11:00 AM",
      "out_time": "06:30 PM",
      "status": "Present",
    },
    {
      "date": "2024-11-08",
      "employee_name": "UZAIR AHMED",
      "in_time": "04:30 AM",
      "out_time": "08:30 AM",
      "status": "Abbesnt",
    },
  ];
// ----------------------------------------------------

  // int currYear = DateTime.now().year;
  // int yearLinit = 10;
  //
  // final _dropDownCustomBGKey = GlobalKey<DropdownSearchState<String>>();
  //
  // MenuProps menuPropsStyle = const MenuProps(
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.only(
  //       bottomLeft: Radius.circular(20),
  //       bottomRight: Radius.circular(20),
  //       topLeft: Radius.zero,
  //       topRight: Radius.zero,
  //     ),
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: ListView.builder(
        itemCount: attendance.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final item = attendance[index];
          final statusColor = item['status'] == "Present"
              ? Colors.greenAccent
              : Colors.redAccent;
          final statusIcon =
              item['status'] == "Present" ? Icons.check_circle : Icons.cancel;

          return Card(
            color: Color(0xFF1E1E1E), // Dark card background
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item['employee_name']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "${item['date']}",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "In: ${item['in_time']} | Out: ${item['out_time']}",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${item['status']}",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  // var newVariable = <DropdownSearch<Object>>[
  //   DropdownSearch<String>(
  //     items: (f, cs) =>
  //         ['Facebook', 'Twitter', 'Instagram', 'SnapChat', 'Other'],
  //     decoratorProps: const DropDownDecoratorProps(
  //       decoration: InputDecoration(
  //         labelText: "Select  Department",
  //         hintText: "Select an department name",
  //       ),
  //     ),
  //     popupProps: PopupProps.menu(
  //       showSearchBox: true,
  //       showSelectedItems: true,
  //       menuProps: menuPropsStyle,
  //     ),
  //   ),
  //   DropdownSearch<String>(
  //       items: (f, cs) =>
  //           ['Facebook', 'Twitter', 'Instagram', 'SnapChat', 'Other'],
  //       decoratorProps: const DropDownDecoratorProps(
  //         decoration: InputDecoration(
  //           labelText: "Select Employee",
  //           hintText: "Select an employee name",
  //         ),
  //       ),
  //       popupProps: const PopupProps.menu(
  //         showSearchBox: true,
  //         menuProps: menuPropsStyle,
  //       )),
  //   DropdownSearch<String>(
  //     items: (f, cs) => months,
  //     decoratorProps: const DropDownDecoratorProps(
  //       decoration: InputDecoration(
  //         labelText: "Select Year",
  //       ),
  //     ),
  //     popupProps: const PopupProps.menu(
  //       menuProps: menuPropsStyle,
  //     ),
  //   ),
  //   DropdownSearch<int>(
  //     items: (f, cs) => List.generate(yearLinit, (i) => currYear - i),
  //     decoratorProps: const DropDownDecoratorProps(
  //       decoration: InputDecoration(
  //         labelText: "Select Year",
  //       ),
  //     ),
  //     popupProps: menuPropsStyle,
  //   ),
  // ];
}

// class FormSelect extends StatelessWidget {
//   const FormSelect({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch(
//       items: (f, cs) => [1],
//       decoratorProps: const DropDownDecoratorProps(
//         decoration: InputDecoration(
//           labelText: "Select Year",
//         ),
//       ),
//       popupProps: const MenuProps(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//             topLeft: Radius.zero,
//             topRight: Radius.zero,
//           ),
//         ),
//       ),
//     );
//   }
// }
