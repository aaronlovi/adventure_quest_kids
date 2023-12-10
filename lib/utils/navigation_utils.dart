import 'package:adventure_quest_kids/utils/constants.dart';
import 'package:flutter/material.dart';

import '../views/user_settings_screen.dart';

/// Pops the navigation stack until the route with the given name is reached.
/// This function is useful when you want to go back to a specific page in your navigation stack.
void popUntilNamedRoute(BuildContext context, String routeName) =>
    Navigator.popUntil(context, ModalRoute.withName(routeName));

/// Pops the navigation stack until the first route is reached.
/// This function is useful when you want to go back to the first page in your navigation stack.
void popUntilFirstRoute(BuildContext context) =>
    Navigator.popUntil(context, (route) => route.isFirst);

/// Pops the navigation stack once.
/// This function is useful when you want to go back to the previous page in your navigation stack.
void popOnce(BuildContext context) => Navigator.pop(context);

/// Pushes a route onto the navigation stack.
/// This function is useful when you want to add a page to your navigation stack, and navigate to it.
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

/// Pops all pages from the navigation stack until reaching the start of the current story.
void navigateToStartOfStory(BuildContext context) {
  popUntilNamedRoute(context, Constants.frontPageRoute);
}

/// Pops all pages from the navigation stack until reaching the story list.
void navigateToStoryList(BuildContext context) {
  popUntilFirstRoute(context);
}

/// Navigates to the given route.
/// This function is useful when you want to add a page to your navigation stack, and navigate to it.
void navigateToRoute(
  BuildContext context,
  Widget nextScreen,
  String routeName,
) =>
    pushRouteWithTransition(context, nextScreen, routeName: routeName);

/// Navigates to the settings page.
/// Adds the settings page to the navigation stack, and navigates to it.
void navigateToSettings(BuildContext context) =>
    navigateToRoute(context, SettingsScreen(), Constants.settingsPageRoute);

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
