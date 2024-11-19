import 'package:flutter/material.dart';

class CameraHeader extends StatelessWidget {
  const CameraHeader(
    this.title, {
    super.key,
    this.captureCount,
    this.onBackPressed,
  });
  final String title;
  final String? captureCount;
  final void Function()? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.black, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBackPressed,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              width: 50,
              child: const Center(
                  child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.black,
              )),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          if (captureCount != null)
            Text(
              captureCount!,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
          // const SizedBox(
          //   width: 90,
          // )
        ],
      ),
    );
  }
}
