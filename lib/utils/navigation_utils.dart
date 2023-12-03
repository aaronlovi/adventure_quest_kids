import 'package:adventure_quest_kids/utils/constants.dart';
import 'package:flutter/material.dart';

void popUntilNamedRoute(BuildContext context, String routeName) =>
    Navigator.popUntil(context, ModalRoute.withName(routeName));

void popUntilFirstRoute(BuildContext context) =>
    Navigator.popUntil(context, (route) => route.isFirst);

void popOnce(BuildContext context) => Navigator.pop(context);

void pushRouteWithTransition(
  BuildContext context,
  Widget nextScreen, {
  String routeName = '',
  Duration transitionDuration = Constants.oneSecond,
}) {
  var pageRouteBuilder = PageRouteBuilder(
    settings: routeName.isEmpty ? null : RouteSettings(name: routeName),
    pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
    transitionsBuilder: _getTypicalPageTransition,
    transitionDuration: transitionDuration,
  );

  Navigator.push(context, pageRouteBuilder);
}

///////////////////////////////////////////////////////////////////////////////
/// Private helper methods
///////////////////////////////////////////////////////////////////////////////

Widget _getTypicalPageTransition(
  context,
  animation,
  secondaryAnimation,
  child,
) {
  var begin = const Offset(1.0, 0.0);
  var end = Offset.zero;
  var tween = Tween(begin: begin, end: end);
  var curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.ease,
  );
  return SlideTransition(
    position: tween.animate(curvedAnimation),
    child: child,
  );
}
