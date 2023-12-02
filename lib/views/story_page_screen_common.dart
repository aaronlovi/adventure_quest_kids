import 'package:flutter/material.dart';

import '../model/story.dart';
import '../model/story_page.dart';
import '../utils/constants.dart';
import '../utils/navigator_utils.dart';
import 'app_bar_title_widget.dart';
import 'story_page_screen.dart';

AppBar getAppBar(
  BuildContext context, {
  required String title,
  required String subTitle,
  required bool isStartPage,
}) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    ),
    titleSpacing: 0,
    title: AppBarTitleWidget(title: title, subTitle: subTitle),
    actions: getAppBarActionButtons(context, isStartPage: isStartPage),
  );
}

List<Widget> getAppBarActionButtons(
  BuildContext context, {
  required bool isStartPage,
}) {
  final widgets = <Widget>[];

  if (!isStartPage) {
    widgets.add(IconButton(
      visualDensity: Constants.mostDense,
      padding: const EdgeInsets.only(right: 8),
      tooltip: 'Start of story',
      onPressed: () => popUntilNamedRoute(context, 'front-page'),
      icon: const Icon(Icons.home),
    ));
  }

  widgets.add(IconButton(
    visualDensity: Constants.mostDense,
    padding: EdgeInsets.zero,
    tooltip: 'Story list',
    onPressed: () => popUntilFirstRoute(context),
    icon: const Icon(Icons.list),
  ));

  return widgets;
}

PageRouteBuilder<dynamic> getPageTransition(Story story, StoryPage nextPage) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          StoryPageScreen(story, nextPage),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      },
      transitionDuration: Constants.oneSecond);
}
