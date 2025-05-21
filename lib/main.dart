import 'package:adventure_quest_kids/l10n/app_localizations.dart';
import 'package:adventure_quest_kids/services/user_settings_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:yaml/yaml.dart';

import 'model/story_meta_data.dart';
import 'model/user_settings.dart';
import 'registry.dart';
import 'utils/ad_state.dart';
import 'utils/constants.dart';
import 'utils/locale_utils.dart';
import 'views/main_screen.dart';

typedef AssetSourceFactory = AssetSource Function(String assetPath);

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

AssetSource createAssetSource(String assetPath) {
  return AssetSource(assetPath);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
      fileName: kDebugMode
          ? 'assets/.config/.env.debug'
          : 'assets/.config/.env.release');

  var getIt = GetIt.instance;

  final initAdMobsFuture = MobileAds.instance.initialize().then((_) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes),
    );
  });
  getIt.registerSingleton<AdState>(AdState(initAdMobsFuture));

  // Remove the asset prefix for all audio players (the default is '/assets')
  AudioCache.instance = AudioCache(prefix: '');

  AudioPlayer backgroundAudioPlayer = AudioPlayer();
  AudioPlayer speechAudioPlayer = AudioPlayer();
  IUserSettingsService settingsService = UserSettingsService();
  UserSettings settings = await settingsService.loadSettings();

  getIt.registerSingleton<Registry>(Registry(
      backgroundAudioPlayer, speechAudioPlayer, settings, settingsService));
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  getIt.registerSingleton<AssetSourceFactory>(
      (assetPath) => AssetSource(assetPath));
  getIt.registerSingleton<UserSettingsService>(UserSettingsService());

  // Load the list of stories
  await loadStoryList();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: MyApp(
        routeObserver: routeObserver,
        registry: getIt.get<Registry>(),
      ),
    ),
  );
}

Future<void> loadStoryList() async {
  String yamlString = await rootBundle.loadString('assets/story_list.yaml');
  YamlMap yamlMap = loadYaml(yamlString);

  var registry = GetIt.I.get<Registry>();
  registry.storyList.clear();

  for (var storyKey in yamlMap['story_list'].keys) {
    StoryMetaData storyMetaData = getStoryMetadataFromYaml(yamlMap, storyKey);
    registry.storyList[storyKey] = storyMetaData;
  }
}

StoryMetaData getStoryMetadataFromYaml(YamlMap yamlMap, storyKey) {
  var entry = yamlMap['story_list'][storyKey];
  String title = entry['title'];
  String subTitle = entry['subtitle'] ?? '';
  String firstPage = entry['first_page'];
  String listIcon = entry['icon'] ?? '';
  String backgroundSoundFilename = entry['background_sound_filename'] ?? '';
  double backgroundSoundVolumeFactor =
      entry['background_sound_volume_factor'] ?? 1.0;
  double backgroundSoundPlaybackRate =
      entry['background_sound_playback_rate'] ?? 1.0;
  Set<String> terminalPageIds =
      (entry['terminal_page_ids'] as String?)?.split(',').toSet() ?? {};

  Map<String, String> titleByLanguage = {};
  for (var locale in supportedNonDefaultLocales) {
    if (entry['title-$locale'] != null) {
      titleByLanguage[locale] = entry['title-$locale'];
    }
  }

  Map<String, String> subTitleByLanguage = {};
  for (var locale in supportedNonDefaultLocales) {
    if (entry['subtitle-$locale'] != null) {
      subTitleByLanguage[locale] = entry['subtitle-$locale'];
    }
  }

  Color gradientTopColor = entry['gradient_top_color'] == null
      ? Constants.mainScreenTopGradientColor
      : Color(int.parse(entry['gradient_top_color']));
  Color gradientBottomColor = entry['gradient_bottom_color'] == null
      ? Constants.mainScreenBottomGradientColor
      : Color(int.parse(entry['gradient_bottom_color']));
  Color highlightedWordGlowColor = entry['highlighted_word_glow_color'] == null
      ? Constants.defaultHighlightedWordGlowColor
      : Color(int.parse(entry['highlighted_word_glow_color']));
  Color storyChoiceButtonBackgroundColor =
      entry['story_choice_button_background_color'] == null
          ? Constants.defaultStoryChoiceButtonBackgroundColor
          : Color(int.parse(entry['story_choice_button_background_color']));
  Color storyChoiceButtonForegroundColor =
      entry['story_choice_button_foreground_color'] == null
          ? Constants.defaultStoryChoiceButtonForegroundColor
          : Color(int.parse(entry['story_choice_button_foreground_color']));
  Color storyTextColor = entry['story_text_color'] == null
      ? Constants.defaultStoryTextColor
      : Color(int.parse(entry['story_text_color']));

  final storyMetaData = StoryMetaData(
    assetName: storyKey,
    title: title,
    titleByLanguage: titleByLanguage,
    subTitle: subTitle,
    subTitleByLanguage: subTitleByLanguage,
    firstPageId: firstPage,
    listIcon: listIcon,
    storyId: storyKey,
    backgroundSoundFilename: backgroundSoundFilename,
    backgroundVolumeAdjustmentFactor: backgroundSoundVolumeFactor,
    backgroundSoundPlaybackRate: backgroundSoundPlaybackRate,
    terminalPageIds: terminalPageIds,
    gradientTopColor: gradientTopColor,
    gradientBottomColor: gradientBottomColor,
    highlightedWordGlowColor: highlightedWordGlowColor,
    storyChoiceButtonBackgroundColor: storyChoiceButtonBackgroundColor,
    storyChoiceButtonForegroundColor: storyChoiceButtonForegroundColor,
    storyTextColor: storyTextColor,
  );
  return storyMetaData;
}

class MyApp extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  final Registry registry;

  const MyApp({super.key, required this.routeObserver, required this.registry});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(Locale(widget.registry.localeName));
    });
  }

  @override
  void dispose() {
    GetIt.I<AudioPlayer>().dispose();
    GetIt.I<Registry>().dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, localeProvider, child) {
      return MaterialApp(
          title: 'Adventure Quest Kids',
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [widget.routeObserver],
          debugShowCheckedModeBanner: false,
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
          initialRoute: Constants.storyListRoute,
          routes: {
            Constants.storyListRoute: (context) =>
                MainScreen(routeObserver: routeObserver),
          });
    });
  }
}
