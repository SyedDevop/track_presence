import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/db/profile_db.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/screens/register_scan.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCT = TextEditingController(text: '');
  final _passwordCT = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  void _subbmit() async {
    if (_formKey.currentState!.validate()) {
      snackbarNotefy(context, message: 'Login in progress..🔥🔥🔥..');
      try {
        final profile = await Api.login(_userCT.text, _passwordCT.text);
        if (profile == null) {
          snackbarNotefy(context,
              message: 'Unable to login try after some time.');
          return;
        }
        ProfileDB pdb = ProfileDB.instance;
        await pdb.insert(profile);
        if (!context.mounted) return;
        context.goNamed(RouteNames.home);
        snackbarSuccess(context, message: "Login successful..🎉🎉🎉..");
      } on ApiException catch (e) {
        snackbarError(context, message: "${e.message}  😭");
      } catch (e) {
        print("[Error]: Api login error :: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040406),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/icons/vc-logo-bg.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 80),
                const Text("Welcome !!",
                    style: TextStyle(
                      fontSize: 28,
                    )),
                RichText(
                  text: const TextSpan(
                    text: "To ",
                    style: TextStyle(fontSize: 22),
                    children: <TextSpan>[
                      TextSpan(
                          text: "V-care Attendances",
                          style: TextStyle(color: Colors.lightBlueAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Enter your user Id and password to get \naccess your account.",
                  style: TextStyle(
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 80),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userCT,
                        autocorrect: false,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "User id",
                          prefixIcon: Icon(Icons.mail_lock_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "User Id is required";
                          } else if (value.length < 4) {
                            return "Valid user Id cant be less the 4";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordCT,
                        autocorrect: false,
                        enableSuggestions: false,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_open_outlined),
                            labelText: "user password"),
                        onFieldSubmitted: (_) => _subbmit,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _subbmit,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 50,
                              ),
                              child: Text("Login"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {},
                  child: const Text("Forgot password?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
