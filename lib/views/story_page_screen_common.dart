import 'package:adventure_quest_kids/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/navigation_utils.dart';
import 'app_bar_title_widget.dart';

AppBar getAppBar(
  BuildContext context, {
  required String title,
  required String subTitle,
  required bool isStartPage,
  required GlobalKey<State<StatefulWidget>> key,
  Color foregroundColor = Colors.white,
}) {
  return AppBar(
    key: key,
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: foregroundColor),
      onPressed: () => popOnce(context),
    ),
    titleSpacing: 0,
    title: AppBarTitleWidget(
      title: title,
      subTitle: subTitle,
      foregroundColor: foregroundColor,
    ),
    actions: getAppBarActionButtons(
      context,
      isStartPage: isStartPage,
      foregroundColor: foregroundColor,
    ),
  );
}

List<Widget> getAppBarActionButtons(
  BuildContext context, {
  required bool isStartPage,
  Color foregroundColor = Colors.white,
}) {
  const right8 = Padding(padding: EdgeInsets.only(right: 8));
  const all2 = EdgeInsets.all(2);

  final widgets = <Widget>[];

  if (!isStartPage) {
    widgets.add(IconButton(
      visualDensity: Constants.mostDense,
      padding: all2,
      tooltip: AppLocalizations.of(context)!.start_of_story,
      onPressed: () => navigateToStartOfStory(context),
      icon: Icon(Icons.home, color: foregroundColor),
    ));

    widgets.add(right8);
  }

  widgets.add(IconButton(
    visualDensity: Constants.mostDense,
    padding: all2,
    tooltip: AppLocalizations.of(context)!.story_list,
    onPressed: () => navigateToStoryList(context),
    icon: Icon(Icons.list, color: foregroundColor),
  ));

  widgets.add(right8);

  widgets.add(IconButton(
    visualDensity: Constants.mostDense,
    padding: all2,
    tooltip: AppLocalizations.of(context)!.settings,
    onPressed: () => navigateToSettings(context),
    icon: Icon(Icons.settings, color: foregroundColor),
  ));

  widgets.add(right8);

  return widgets;
}
