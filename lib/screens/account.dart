import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';
import 'package:vcare_attendance/widgets/report/report_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _accApi = Api.account;
  final profile = getIt<AppState>().profile;
  bool _loading = false;

  final _conformPassCT = TextEditingController(text: '');
  final _passCT = TextEditingController(text: '');
  final _currPassCT = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _conformPassCT.dispose();
    _passCT.dispose();
    _currPassCT.dispose();
  }

  _reset() {
    _conformPassCT.clear();
    _passCT.clear();
    _currPassCT.clear();
  }

  Future<void> _submit() async {
    if (profile == null) {
      snackbarError(context, message: "User profile is not Set 😭");
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        await _accApi.changePassword(
          profile!.userId,
          _currPassCT.text,
          _passCT.text,
        );
        if (mounted) {
          snackbarSuccess(
            context,
            message: "password updated successful..🎉🎉🎉..",
          );
        }
        _reset();
      } on DioException catch (e) {
        snackbarError(context, message: "${e.message}  😭");
      } catch (e) {
        print("[Error]: changePassword error :: $e");
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  String? _isPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "password is required";
    } else if (value.length < 6) {
      return "Must be at least 6 characters in length";
    }
    return null;
  }

  String? _isPasswordEq(String? value, String toValue) {
    final isPass = _isPassword(value);
    if (isPass != null) {
      return isPass;
    } else if (value != toValue) {
      return "Passwords are not equal";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const ReportHeader("Change Password"),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currPassCT,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_open_outlined),
                            labelText: "Current Password",
                          ),
                          validator: (v) => _isPassword(v),
                        ),
                        TextFormField(
                          controller: _passCT,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_open_outlined),
                            labelText: "Password",
                          ),
                          validator: (v) =>
                              _isPasswordEq(v, _conformPassCT.text),
                        ),
                        TextFormField(
                          controller: _conformPassCT,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_open_outlined),
                            labelText: "Conform password",
                          ),
                          validator: (v) => _isPasswordEq(v, _passCT.text),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 75),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.update_rounded),
                          label: const Text("change password"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
