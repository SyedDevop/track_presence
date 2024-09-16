import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 55,
                  horizontal: 10,
                ),
                child: Text(
                  "Redister Face ID",
                  style: TextStyle(fontSize: 38),
                ),
              ),
              const Expanded(child: SizedBox()),
              Center(
                child: SvgPicture.asset(
                  "assets/svg/face.svg",
                  width: 65,
                  height: 65,
                  color: Colors.white54,
                ),
              ),
              const Expanded(child: SizedBox()),
              const Text(
                "Face ID",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Text(
                "Use Face ID to register in to your",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Text(
                "Track Presence account",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: FilledButton(
                  onPressed: () {},
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
