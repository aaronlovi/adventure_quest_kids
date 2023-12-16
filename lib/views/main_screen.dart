import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
import '../utils/constants.dart';
import 'story_list_item.dart';

class MainScreen extends StatefulWidget {
  final Registry registry;
  final RouteObserver<PageRoute> routeObserver;
  final AssetSourceFactory assetSourceFactory;

  MainScreen({super.key, required this.routeObserver})
      : registry = GetIt.I.get<Registry>(),
        assetSourceFactory = GetIt.I.get<AssetSourceFactory>();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with RouteAware {
  Registry get registry => widget.registry;
  AssetSourceFactory get assetSourceFactory => widget.assetSourceFactory;

  @override
  void initState() {
    super.initState();
    stopSpeech(widget.registry);
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      widget.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var registry = GetIt.I.get<Registry>();
    List<String> storyNames = registry.storyList.keys.toList()..sort();

    return Scaffold(
      appBar: _getAppBar(context),
      body: _getBody(storyNames, context),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.contain,
          width: 40,
          height: 40,
        ),
      ),
      title: const FittedBox(
          fit: BoxFit.scaleDown, child: Text('Adventure Quest Kids')),
      actions: [
        IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => navigateToSettings(context))
      ],
    );
  }

  ListView _getBody(
    List<String> storyNames,
    BuildContext context,
  ) {
    return ListView.builder(
        itemCount: storyNames.length,
        itemBuilder: (content, index) {
          var storyName = storyNames[index];
          int colorIndex = index % Constants.iconColors.length;
          final Color iconColor = Constants.iconColors[colorIndex];
          StoryMetaData storyMetaData = registry.storyList[storyName]!;
          Set<String> terminalPagesVisited =
              registry.getTerminalPagesVisited(storyName);
          bool anyTerminalPagesVisited = terminalPagesVisited.isNotEmpty;
          bool allTerminalPagesVisited = terminalPagesVisited.length ==
              storyMetaData.terminalPageIds.length;
          String toolTipMsg = allTerminalPagesVisited
              ? 'All endings visited\nCongratulations!'
              : anyTerminalPagesVisited
                  ? 'Some endings visited\nKeep exploring!'
                  : 'No endings visited\nStart exploring!';
          Icon trailingIcon = allTerminalPagesVisited
              ? const Icon(Icons.done_all, color: Colors.green)
              : anyTerminalPagesVisited
                  ? Icon(Icons.book, color: iconColor)
                  : Icon(Icons.bookmark_border, color: iconColor);
          return StoryListItem(
            icon: trailingIcon,
            toolTipMsg: toolTipMsg,
            storyMetaData: storyMetaData,
            registry: registry,
            assetSourceFactory: assetSourceFactory,
            routeObserver: routeObserver,
            iconColor: iconColor,
          );
        });
  }
}
