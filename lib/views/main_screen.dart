import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:adventure_quest_kids/views/story_front_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
import '../utils/constants.dart';

class MainScreen extends StatefulWidget {
  final Registry registry;
  final RouteObserver<PageRoute> routeObserver;

  MainScreen({super.key, required this.routeObserver})
      : registry = GetIt.I.get<Registry>();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with RouteAware {
  late int _colorIndex;

  MainScreenState() : _colorIndex = 0;

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
      body: _getBody(storyNames, registry, context),
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
    Registry registry,
    BuildContext context,
  ) {
    return ListView.builder(
        itemCount: storyNames.length,
        itemBuilder: (content, index) {
          var storyName = storyNames[index];
          StoryMetaData storyMetaData = registry.storyList[storyName]!;
          Set<String> terminalPagesVisited =
              registry.getTerminalPagesVisited(storyName);
          bool anyTerminalPagesVisited = terminalPagesVisited.isNotEmpty;
          bool allTerminalPagesVisited = terminalPagesVisited.length ==
              storyMetaData.terminalPageIds.length;
          Icon trailingIcon = allTerminalPagesVisited
              ? const Icon(Icons.check)
              : anyTerminalPagesVisited
                  ? const Icon(Icons.check_circle)
                  : const Icon(Icons.check_box_outline_blank_outlined);
          return ListTile(
              leading: _getStoryListItemIcon(storyMetaData),
              trailing: trailingIcon,
              title: Text(storyMetaData.fullTitle),
              onTap: () => navigateToRoute(
                  context,
                  StoryFrontPageScreen(
                      storyMetadata: storyMetaData,
                      routeObserver: RouteObserver<PageRoute>(),
                      assetSourceFactory: GetIt.I.get<AssetSourceFactory>(),
                      registry: registry),
                  Constants.frontPageRoute));
        });
  }

  Widget _getStoryListItemIcon(StoryMetaData storyMetaData) {
    final iconColors = <Color>[
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    if (storyMetaData.listIcon.isEmpty) {
      _colorIndex = (_colorIndex + 1) % iconColors.length;
      return Icon(
        Icons.book,
        size: 40.0,
        color: iconColors[_colorIndex],
      );
    } else {
      return Image(image: AssetImage(storyMetaData.listIconFilename));
    }
  }
}
