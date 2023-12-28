import 'package:flutter/material.dart';

class AppBarTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color foregroundColor;

  const AppBarTitleWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.foregroundColor = Colors.white,
  });

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
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: foregroundColor),
              )),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(subTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor))),
        ],
      );
    } else {
      return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: foregroundColor),
          ));
    }
  }
}
