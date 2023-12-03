import 'dart:async';

import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../registry.dart';
import '../utils/constants.dart';
import 'animated_story_text.dart';
import 'story_page_screen_common.dart';

class StoryPageScreen extends StatefulWidget {
  final Story story;
  final StoryPage storyPage;

  const StoryPageScreen(this.story, this.storyPage, {super.key});

  @override
  StoryPageScreenState createState() => StoryPageScreenState();
}

class StoryPageScreenState extends State<StoryPageScreen> {
  late AudioPlayer _player;
  final ValueNotifier<int> _currentWordIndex = ValueNotifier<int>(-1);
  final Registry _registry;
  Timer? _timer;

  StoryPageScreenState() : _registry = GetIt.I.get<Registry>();

  String get _imagePath =>
      '${widget.story.imagesFolder}/${widget.storyPage.imageFileName}';
  String get _soundPath =>
      '${widget.story.soundsFolder}/${widget.storyPage.soundFileName}';

  @override
  void initState() {
    super.initState();

    _player = GetIt.I.get<AudioPlayer>();

    _playPageLoadSound();
  }

  @override
  void dispose() {
    _currentWordIndex.dispose();
    _timer?.cancel();
    super.dispose();
    // _player.dispose();
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

  List<Widget> _addStoryChoiceWidgets(
    BuildContext context,
    List<Widget> widgets,
  ) {
    widgets.add(const SizedBox(height: 16));

    for (String choiceName in widget.storyPage.choices.keys) {
      StoryChoice choice = widget.storyPage.choices[choiceName]!;

      widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      widgets.add(ElevatedButton(
        onPressed: () {
          StoryPage nextPage = widget.story.pages[choice.nextPageId]!;
          pushRouteWithTransition(
              context, StoryPageScreen(widget.story, nextPage));
        },
        child: Text(choice.text, textAlign: TextAlign.center),
      ));
    }

    if (widget.storyPage.isTerminal) {
      widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      widgets.add(const Text('The End',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));

      widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      widgets.add(ElevatedButton(
        onPressed: () => popUntilNamedRoute(context, 'front-page'),
        child: Text('Restart ${widget.story.title}'),
      ));

      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(ElevatedButton(
        onPressed: () => popUntilFirstRoute(context),
        child: const Text('Back to Story List'),
      ));
    }

    return widgets;
  }

  Future<void> _playPageLoadSound() async {
    if (widget.storyPage.soundFileName.isEmpty) return;

    try {
      var soundAsset = AssetSource(_soundPath);
      await soundAsset.setOnPlayer(_player);
      await _player.setVolume(_registry.foregroundVolume);
      await _player.play(soundAsset);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  void _startAnimation() {
    List<String> words = widget.storyPage.text.split(' ');

    _timer?.cancel();
    _currentWordIndex.value = 0;

    _timer = Timer.periodic(Constants.oneSecond, (timer) {
      if (_currentWordIndex.value < words.length - 1) {
        _currentWordIndex.value++;
      } else {
        timer.cancel();
        _currentWordIndex.value = -1;
      }
    });
  }
}
