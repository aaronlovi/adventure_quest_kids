import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/navigation_utils.dart';
import 'app_bar_title_widget.dart';

AppBar getAppBar(
  BuildContext context, {
  required String title,
  required String subTitle,
  required bool isStartPage,
}) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => popOnce(context),
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
  const right8 = Padding(padding: EdgeInsets.only(right: 8));
  const all2 = EdgeInsets.all(2);

  final widgets = <Widget>[];

  if (!isStartPage) {
    widgets.add(IconButton(
      visualDensity: Constants.mostDense,
      padding: all2,
      tooltip: 'Start of story',
      onPressed: () => navigateToStartOfStory(context),
      icon: const Icon(Icons.home),
    ));

    widgets.add(right8);
  }

  widgets.add(IconButton(
    visualDensity: Constants.mostDense,
    padding: all2,
    tooltip: 'Story list',
    onPressed: () => navigateToStoryList(context),
    icon: const Icon(Icons.list),
  ));

  widgets.add(right8);

  widgets.add(IconButton(
    visualDensity: Constants.mostDense,
    padding: all2,
    tooltip: 'Settings',
    onPressed: () => navigateToSettings(context),
    icon: const Icon(Icons.settings),
  ));

  widgets.add(right8);

  return widgets;
}
