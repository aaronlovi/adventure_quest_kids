import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:yaml/yaml.dart';

import 'model/story_meta_data.dart';
import 'registry.dart';
import 'views/story_front_page_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var getIt = GetIt.instance;

  // Remove the asset prefix for all audio players (the default is '/assets')
  AudioCache.instance = AudioCache(prefix: '');

  getIt.registerSingleton<Registry>(Registry());
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());

  // Load the list of stories
  await loadStoryList();

  runApp(const MyApp());
}

Future<void> loadStoryList() async {
  String yamlString = await rootBundle.loadString('assets/story_list.yaml');
  YamlMap yamlMap = loadYaml(yamlString);

  var registry = GetIt.I.get<Registry>();
  registry.storyList.clear();

  for (var story in yamlMap['story_list'].keys) {
    StoryMetaData storyMetaData = getStoryMetadataFromYaml(yamlMap, story);
    registry.storyList[story] = storyMetaData;
  }
}

StoryMetaData getStoryMetadataFromYaml(YamlMap yamlMap, story) {
  var entry = yamlMap['story_list'][story];
  String title = entry['title'];
  String firstPage = entry['first_page'];
  StoryMetaData storyMetaData = StoryMetaData(
    assetName: story,
    title: title,
    firstPageId: firstPage,
  );
  return storyMetaData;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void dispose() {
    GetIt.I<AudioPlayer>().dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventure Quest Kids',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var registry = GetIt.I.get<Registry>();
    List<String> storyNames = registry.storyList.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventure Quest Kids'),
      ),
      body: ListView.builder(
          itemCount: storyNames.length,
          itemBuilder: (content, index) {
            var storyName = storyNames[index];
            StoryMetaData storyMetaData = registry.storyList[storyName]!;
            return ListTile(
                title: Text(storyMetaData.title),
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        settings: const RouteSettings(name: 'front-page'),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            StoryFrontPageScreen(storyMetadata: storyMetaData),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                        transitionDuration: const Duration(milliseconds: 1000)),
                  );
                });
          }),
    );
  }
}
