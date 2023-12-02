import 'package:flutter/material.dart';

class AppBarTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  const AppBarTitleWidget(
      {super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    if (subTitle.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(subTitle,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      );
    } else {
      return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ));
    }
  }
}
