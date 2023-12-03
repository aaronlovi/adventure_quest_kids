import 'package:adventure_quest_kids/services/user_settings_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:yaml/yaml.dart';

import 'model/story_meta_data.dart';
import 'model/user_settings.dart';
import 'registry.dart';
import 'views/main_screen.dart';

typedef AssetSourceFactory = AssetSource Function(String assetPath);

AssetSource createAssetSource(String assetPath) {
  return AssetSource(assetPath);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var getIt = GetIt.instance;

  // Remove the asset prefix for all audio players (the default is '/assets')
  AudioCache.instance = AudioCache(prefix: '');

  AudioPlayer backgroundAudioPlayer = AudioPlayer();
  IUserSettingsService settingsService = UserSettingsService();
  UserSettings settings = await settingsService.loadSettings();

  getIt.registerSingleton<Registry>(
      Registry(backgroundAudioPlayer, settings, settingsService));
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  getIt.registerSingleton<AssetSourceFactory>(
      (assetPath) => AssetSource(assetPath));
  getIt.registerSingleton<UserSettingsService>(UserSettingsService());

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
  String subTitle = entry['subtitle'] ?? '';
  String firstPage = entry['first_page'];
  String listIcon = entry['icon'] ?? '';
  String backgroundSoundFilename = entry['background_sound_filename'] ?? '';
  double backgroundSoundVolumeFactor =
      entry['background_sound_volume_factor'] ?? 1.0;
  double backgroundSoundPlaybackRate =
      entry['background_sound_playback_rate'] ?? 1.0;
  StoryMetaData storyMetaData = StoryMetaData(
    assetName: story,
    title: title,
    subTitle: subTitle,
    firstPageId: firstPage,
    listIcon: listIcon,
    backgroundSoundFilename: backgroundSoundFilename,
    backgroundVolumeAdjustmentFactor: backgroundSoundVolumeFactor,
    backgroundSoundPlaybackRate: backgroundSoundPlaybackRate,
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
    GetIt.I<Registry>().dispose();
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
