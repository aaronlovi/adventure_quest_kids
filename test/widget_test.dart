// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:adventure_quest_kids/main.dart';
import 'package:adventure_quest_kids/model/user_settings.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/services/user_settings_service.dart';
import 'package:adventure_quest_kids/views/main_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {
  @override
  Future<void> stop() async {}

  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {}

  @override
  Future<void> setPlaybackRate(double playbackRate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {}

  @override
  Stream<void> get onPlayerComplete => const Stream.empty();
}

class MockAssetSource extends AssetSource {
  MockAssetSource(String path) : super('');

  @override
  Future<void> setOnPlayer(AudioPlayer player) async {}
}

class MockUserSettingsService extends Mock implements IUserSettingsService {
  @override
  Future<UserSettings> loadSettings() async {
    return UserSettings();
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {}
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    GetIt getIt = GetIt.instance;

    final mockUserSettingsService = MockUserSettingsService();
    final mockUserSettings = await mockUserSettingsService.loadSettings();
    final mockAudioPlayer = MockAudioPlayer();
    getIt.registerSingleton<Registry>(Registry(mockAudioPlayer, mockAudioPlayer,
        mockUserSettings, mockUserSettingsService));
    getIt.registerSingleton<AudioPlayer>(mockAudioPlayer);
    getIt.registerSingleton<AssetSourceFactory>(
        (assetPath) => MockAssetSource(assetPath));
  });

  testWidgets('Check if any widget overflows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;

    // Note: If a font is not explicitly set the default font is excessively
    //       large, which will cause artificial overflow errors
    final roboto = rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final fontLoader = FontLoader('Roboto')..addFont(roboto);
    await fontLoader.load();

    await loadStoryList();

    // Build your widget
    var mainWidget = MaterialApp(
        home: MainScreen(routeObserver: routeObserver),
        theme: ThemeData(fontFamily: 'Roboto'));
    await tester.pumpWidget(mainWidget);

    // Iterate over all widgets
    for (final widget in tester.allWidgets) {
      // Get the RenderBox of each matching widget.
      // There can be more than one matching widget if a widget is reused on the screen.
      // For example, constant Icon widgets
      Finder finder = find.byWidget(widget);
      for (final Element element in finder.evaluate()) {
        final renderObject = element.renderObject;

        if (renderObject is RenderBox) {
          // Get the Rect of the RenderBox
          final rect =
              renderObject.localToGlobal(Offset.zero) & renderObject.size;

          // Check if the Rect is within the screen bounds
          if (rect.left < 0 ||
              rect.top < 0 ||
              rect.right > tester.view.physicalSize.width ||
              rect.bottom > tester.view.physicalSize.height) {
            throw Exception('Overflow detected');
          }

          // Check if the Rect is within the screen bounds
          expect(rect.left >= 0, isTrue);
          expect(rect.top >= 0, isTrue);
          expect(rect.right <= tester.view.physicalSize.width, isTrue);
          expect(rect.bottom <= tester.view.physicalSize.height, isTrue);
        }
      }
    }

    // Check for overflow errors
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Check for overflow errors
    expect(tester.takeException(), isNull);

    // Clear the screen size settings after the test
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
