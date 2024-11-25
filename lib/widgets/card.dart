import 'package:flutter/material.dart';

class AtCard1 extends StatelessWidget {
  const AtCard1({
    super.key,
    required this.title,
    this.children = const <Widget>[],
  });

  final Widget title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            title,
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
