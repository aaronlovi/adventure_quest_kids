import 'dart:async';

import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
import '../registry.dart';
import '../utils/constants.dart';
import '../utils/read_timestamp_file.dart';
import 'animated_story_text.dart';
import 'story_page_screen_common.dart';

class StoryPageScreen extends StatefulWidget {
  final String storyPageId;
  final Story story;
  final StoryPage storyPage;
  final RouteObserver<PageRoute> routeObserver;
  final Registry registry;

  const StoryPageScreen(this.storyPageId, this.story, this.storyPage,
      this.routeObserver, this.registry,
      {super.key});

  @override
  StoryPageScreenState createState() => StoryPageScreenState();
}

class StoryPageScreenState extends State<StoryPageScreen> with RouteAware {
  late AudioPlayer _player;

  /// Set to true to cancel the speech animation
  bool _cancelSpeechAnimation;

  /// The index of the current word being spoken
  final ValueNotifier<int> _currentWordIndex;

  StoryPageScreenState()
      : _cancelSpeechAnimation = false,
        _currentWordIndex = ValueNotifier<int>(-1);

  String get _imagePath =>
      '${widget.story.imagesFolder}/${widget.storyPage.imageFileName}';
  String get _soundPath =>
      '${widget.story.soundsFolder}/${widget.storyPage.soundFileName}';

  @override
  void initState() {
    super.initState();

    if (widget.storyPage.isTerminal) {
      widget.registry.setTerminalPageVisited(
          widget.story.storyMetaData.storyId, widget.storyPageId);
    }

    _player = GetIt.I.get<AudioPlayer>();

    _cancelSpeechAnimation = false;
    stopSpeech(widget.registry);
    _playPageLoadSound();
  }

  @override
  void dispose() {
    _cancelSpeechAnimation = true;
    stopSpeech(widget.registry);
    _currentWordIndex.dispose();
    widget.routeObserver.unsubscribe(this);
    super.dispose();
    // _player.dispose();
  }

  /// Sets up the watcher that notices when the user navigates away from this page.
  /// Then, this page can cancel its own speech animations.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      widget.routeObserver.subscribe(this, route);
    }
  }

  /// Cancels speech navigation since the user navigated away from this page.
  @override
  void didPushNext() {
    super.didPushNext();
    // A new route was pushed on top of the current route.
    _currentWordIndex.value = -1;
    _cancelSpeechAnimation = true;
  }

  @override
  Widget build(BuildContext context) {
    final double w = context.width;
    final double h = context.height;

    return Scaffold(
      appBar: _getAppBar(context),
      body: Column(
        children: [
          _getStoryImageWidgets(w, h),
          _getStoryTextAndChoicesWidgets(w, h, context),
        ],
      ),
    );
  }

  PreferredSize _getAppBar(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
            tag: 'appBar',
            child: getAppBar(context,
                title: widget.story.title,
                subTitle: widget.story.subTitle,
                isStartPage: false)));
  }

  SizedBox _getStoryImageWidgets(double w, double h) {
    return SizedBox(
      height: h * 0.4,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              height: h * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(_imagePath),
                ),
              ),
            ),
          ),
          Positioned(
            right: w * 0.1 / 2,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _startAnimation,
              tooltip: 'Read Aloud',
              mini: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              heroTag: null,
              child: const Icon(Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }

  Container _getStoryTextAndChoicesWidgets(
    double w,
    double h,
    BuildContext context,
  ) {
    var widgets = <Widget>[];
    _addStoryTextWidgets(widgets);
    _addStoryChoiceWidgets(context, widgets);
    _addEndOfStoryWidgets(context, widgets);

    return Container(
      height: h * 0.4,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets,
              ),
            ),
          );
        },
      ),
    );
  }

  void _addStoryTextWidgets(List<Widget> widgets) {
    List<String> words = widget.storyPage.text.split(' ');

    var pageTextWidget =
        AnimatedStoryText(words: words, currentWordIndex: _currentWordIndex);

    widgets.add(Center(child: pageTextWidget));
  }

  void _addStoryChoiceWidgets(BuildContext context, List<Widget> widgets) {
    widgets.add(const SizedBox(height: 16));

    for (String choiceName in widget.storyPage.choices.keys) {
      StoryChoice choice = widget.storyPage.choices[choiceName]!;
      StoryPage nextPage = widget.story.pages[choice.nextPageId]!;
      StoryPageScreen nextScreen = StoryPageScreen(
        choice.nextPageId,
        widget.story,
        nextPage,
        widget.routeObserver,
        widget.registry,
      );

      widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      widgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
        onPressed: () => pushRouteWithTransition(context, nextScreen),
        child: Text(choice.text, textAlign: TextAlign.center),
      ));
    }
  }

  void _addEndOfStoryWidgets(BuildContext context, List<Widget> widgets) {
    const paddingTop12 = Padding(padding: EdgeInsets.only(top: 12));
    const paddingTop16 = Padding(padding: EdgeInsets.only(top: 16));

    if (!widget.storyPage.isTerminal) return;

    widgets.add(paddingTop12);
    widgets.add(const Text('The End',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));

    widgets.add(paddingTop12);
    widgets.add(ElevatedButton(
      onPressed: () => popUntilNamedRoute(context, Constants.frontPageRoute),
      child: Text('Restart ${widget.story.title}'),
    ));

    widgets.add(paddingTop16);
    widgets.add(ElevatedButton(
      onPressed: () => popUntilFirstRoute(context),
      child: const Text('Back to Story List'),
    ));
  }

  Future<void> _playPageLoadSound() async {
    if (widget.storyPage.soundFileName.isEmpty) return;

    try {
      var soundAsset = AssetSource(_soundPath);
      await soundAsset.setOnPlayer(_player);
      await _player.setVolume(widget.registry.foregroundVolume);
      await _player.play(soundAsset);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  Future<void> _startAnimation() async {
    _cancelSpeechAnimation = false;
    _currentWordIndex.value = 0;

    // Step 1: Get the list of words
    List<String> words = widget.storyPage.text.split(' ');

    // Step 2: Get the time between each spoken word
    var durations = <Duration>[];
    List<Duration> delays = await _getWordDelays(words, durations);

    // Allow cancellation after an awaited method call
    if (_cancelSpeechAnimation) return;

    // Step 3: Play the speech
    if (widget.storyPage.speechFileName.isNotEmpty) {
      String speechAssetPath =
          '${widget.story.speechFolder}/${widget.storyPage.speechFileName}';
      playSpeech(
          speechAssetPath, GetIt.I.get<AssetSourceFactory>(), widget.registry);
    }

    // Allow cancellation after playSpeech is invoked
    if (_cancelSpeechAnimation) return;

    // Step 4: Display each word after the corresponding delay
    _currentWordIndex.value = 0;
    for (int i = 0; i < words.length; i++) {
      // Allow cancellation
      if (_cancelSpeechAnimation) return;

      await Future.delayed(delays[i]);

      // Allow cancellation
      if (_cancelSpeechAnimation) return;

      _currentWordIndex.value = i + 1;
    }

    // Allow cancellation
    if (_cancelSpeechAnimation) return;

    _currentWordIndex.value = -1;
  }

  /// Calculate the delay before each word
  Future<List<Duration>> _getWordDelays(
    List<String> words,
    List<Duration> durations,
  ) async {
    if (widget.storyPage.speechTimestampsFileName.isNotEmpty) {
      String speechTimestampsAssetPath =
          '${widget.story.speechFolder}/${widget.storyPage.speechTimestampsFileName}';
      durations = await readTimestamps(
          speechTimestampsAssetPath, widget.registry.speechRate);
    }

    // Calculate the delay before each word
    return List<Duration>.generate(words.length, (i) {
      if (i < durations.length - 1) {
        return durations[i + 1] - durations[i];
      } else if (i == durations.length - 1) {
        return durations[i];
      } else {
        return Constants.halfSecond * (1.0 / widget.registry.speechRate);
      }
    });
  }
}
