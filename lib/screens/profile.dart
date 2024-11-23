import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/models/empolyee_modeal.dart';
import 'package:vcare_attendance/widgets/report/report_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String id;
  final String? imgPath;

  const ProfileScreen({super.key, required this.id, this.imgPath});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Employee? _employee;

  List<(String, dynamic)> _personal = [];
  List<(String, dynamic)> _company = [];
  List<(String, dynamic)> _jobHistory = [];
  List<(String, dynamic)> _bank = [];

  bool _loading = false;
  String? _imgPath;
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _imgPath = widget.imgPath;

    _imgPath = (_imgPath == null || _imgPath!.isEmpty) ? null : _imgPath;

    _loading = true;
    final emp = await Api.getEmployee(widget.id);
    setState(() {
      _employee = emp;
      _personal = _employee?.personalDetails?.todata() ?? [];
      _company = _employee?.companyDetails?.todata() ?? [];
      _jobHistory = _employee?.jobHistory?.todata() ?? [];
      _bank = _employee?.bankDetails?.todata() ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _employee == null
              ? const Center(
                  child: Text(
                  "No Profile Found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ))
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        title: const Text("Profile"),
                        stretchTriggerOffset: 300.0,
                        expandedHeight: 200.0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: widget.imgPath != null &&
                                  widget.imgPath!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      FileImage(File(widget.imgPath!)))
                              : const CircleAvatar(
                                  child: ClipOval(
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: RpoerHeader("Personal")),
                      SliverList.builder(
                        itemCount: _personal.length,
                        itemBuilder: (context, index) {
                          final item = _personal[index];
                          final value = item.$2.isEmpty ? "----" : item.$2;
                          return ReportSheetRow(
                              leadingText: item.$1, trailingText: value);
                        },
                      ),
                      const SliverToBoxAdapter(
                          child: RpoerHeader("Company Details")),
                      SliverList.builder(
                        itemCount: _company.length,
                        itemBuilder: (context, index) {
                          final item = _company[index];

                          final value = item.$2.isEmpty ? "----" : item.$2;
                          return ReportSheetRow(
                              leadingText: item.$1, trailingText: value);
                        },
                      ),
                      const SliverToBoxAdapter(
                          child: RpoerHeader("Job History")),
                      SliverList.builder(
                        itemCount: _jobHistory.length,
                        itemBuilder: (context, index) {
                          final item = _jobHistory[index];

                          final value = item.$2.isEmpty ? "----" : item.$2;
                          return ReportSheetRow(
                              leadingText: item.$1, trailingText: value);
                        },
                      ),
                      const SliverToBoxAdapter(
                          child: RpoerHeader("Bank Details")),
                      SliverList.builder(
                        itemCount: _bank.length,
                        itemBuilder: (context, index) {
                          final item = _bank[index];
                          final value = item.$2.isEmpty ? "----" : item.$2;
                          return ReportSheetRow(
                              leadingText: item.$1, trailingText: value);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
