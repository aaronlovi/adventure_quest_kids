import 'package:adventure_quest_kids/l10n/app_localizations.dart';
import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';
import '../utils/ad_state.dart';
import '../utils/constants.dart';
import 'story_list_item.dart';

class MainScreen extends StatefulWidget {
  final Registry registry;
  final AdState adState;
  final RouteObserver<PageRoute> routeObserver;
  final AssetSourceFactory assetSourceFactory;

  MainScreen({super.key, required this.routeObserver})
      : registry = GetIt.I.get<Registry>(),
        adState = GetIt.I.get<AdState>(),
        assetSourceFactory = GetIt.I.get<AssetSourceFactory>();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with RouteAware {
  Registry get registry => widget.registry;
  AdState get adState => widget.adState;
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
      extendBodyBehindAppBar: true,
      appBar: _getAppBar(context),
      body: _getBody(storyNames, context),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.contain,
          width: 40,
          height: 40,
        ),
      ),
      title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context)!.adventure_quest_kids,
            style: const TextStyle(color: Colors.white),
          )),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => navigateToSettings(context),
          color: Colors.white,
        )
      ],
    );
  }

  Widget _getBody(List<String> storyNames, BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constants.mainScreenTopGradientColor,
                  Constants.mainScreenBottomGradientColor
                ],
              ),
            ),
            child: ListView.builder(
                itemCount: storyNames.length,
                itemBuilder: (content, index) {
                  var storyName = storyNames[index];
                  int colorIndex = index % Constants.iconColors.length;
                  final Color iconColor = Constants.iconColors[colorIndex];
                  StoryMetaData storyMetaData = registry.storyList[storyName]!;
                  Set<String> terminalPagesVisited =
                      registry.getTerminalPagesVisited(storyName);
                  bool anyTerminalPagesVisited =
                      terminalPagesVisited.isNotEmpty;
                  bool allTerminalPagesVisited = terminalPagesVisited.length ==
                      storyMetaData.terminalPageIds.length;
                  String toolTipMsg = allTerminalPagesVisited
                      ? AppLocalizations.of(context)!.all_endings_visited
                      : anyTerminalPagesVisited
                          ? AppLocalizations.of(context)!.some_endings_visited
                          : AppLocalizations.of(context)!.no_endings_visited;
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
                    adState: adState,
                    assetSourceFactory: assetSourceFactory,
                    routeObserver: routeObserver,
                    iconColor: iconColor,
                  );
                })),
        Positioned(
            right: 0,
            bottom: 0,
            child: TextButton(
                onPressed: () => _launchUrl(
                    'https://app.enzuzo.com/policies/privacy/e1a6bd74-b2b6-11ee-82c3-83a96d2585d9'),
                child: Text(AppLocalizations.of(context)!.privacy_policy,
                    style: const TextStyle(color: Colors.white)))),
      ],
    );
  }

  Future<void> _launchUrl(url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(url)
        : throw 'Could not launch $url';
  }
}
