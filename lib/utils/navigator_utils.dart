import 'package:flutter/material.dart';

void popUntilNamedRoute(BuildContext context, String routeName) =>
    Navigator.popUntil(context, ModalRoute.withName(routeName));

void popUntilFirstRoute(BuildContext context) =>
    Navigator.popUntil(context, (route) => route.isFirst);
