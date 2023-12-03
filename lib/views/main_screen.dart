import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/views/story_front_page_screen.dart';
import 'package:adventure_quest_kids/views/user_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _colorIndex;

  MainScreenState() : _colorIndex = 0;

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
            onPressed: () => pushRouteWithTransition(
                  context,
                  SettingsScreen(),
                  routeName: 'settings',
                ))
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
          return ListTile(
              leading: _getStoryListItemIcon(storyMetaData),
              title: Text(storyMetaData.fullTitle),
              onTap: () => pushRouteWithTransition(
                    context,
                    StoryFrontPageScreen(storyMetadata: storyMetaData),
                    routeName: 'front-page',
                  ));
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
