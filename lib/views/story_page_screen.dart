import 'dart:async';

import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app_bar_title_widget.dart';

class StoryPageScreen extends StatefulWidget {
  final Story story;
  final StoryPage storyPage;

  const StoryPageScreen(this.story, this.storyPage, {Key? key})
      : super(key: key);

  @override
  StoryPageScreenState createState() => StoryPageScreenState();
}

class StoryPageScreenState extends State<StoryPageScreen> {
  late AudioPlayer _player;
  final ValueNotifier<int> _currentWordIndex = ValueNotifier<int>(-1);
  Timer? _timer;

  String get imagePath =>
      '${widget.story.imagesFolder}/${widget.storyPage.imageFileName}';
  String get soundPath =>
      '${widget.story.soundsFolder}/${widget.storyPage.soundFileName}';

  @override
  void initState() {
    super.initState();
    // _player = AudioPlayer();
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
    var bottomHalfWidgets = <Widget>[];
    _addStoryTextWidgets(bottomHalfWidgets);
    _addStoryChoiceWidgets(context, bottomHalfWidgets);

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleWidget(
            title: widget.story.title, subTitle: widget.story.subTitle),
        actions: [
          IconButton(
            tooltip: 'Start of story',
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('front-page'));
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            tooltip: 'Story list',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top half: Container for Image
          Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(imagePath),
                ),
              )),
          // Bottom half: Text and Choices
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bottomHalfWidgets,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _startAnimation,
          tooltip: 'Read Aloud',
          mini: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: const Icon(Icons.play_arrow)),
    );
  }

  void _addStoryTextWidgets(List<Widget> widgets) {
    List<String> words = widget.storyPage.text.split(' ');

    var pageTextWidget =
        AnimatedStoryText(words: words, currentWordIndex: _currentWordIndex);

    widgets.add(Center(child: pageTextWidget));
  }

  List<Widget> _addStoryChoiceWidgets(
      BuildContext context, List<Widget> widgets) {
    widgets.add(const SizedBox(height: 16));

    for (String choiceName in widget.storyPage.choices.keys) {
      StoryChoice choice = widget.storyPage.choices[choiceName]!;

      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(ElevatedButton(
        onPressed: () async {
          if (!context.mounted) return;
          StoryPage nextPage = widget.story.pages[choice.nextPageId]!;

          Navigator.push(
            context,
            _getPageTransition(nextPage),
          );
        },
        child: Text(choice.text),
      ));
    }

    if (widget.storyPage.isTerminal) {
      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(const Text('The End',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));

      widgets.add(const Padding(padding: EdgeInsets.only(top: 24)));
      widgets.add(ElevatedButton(
        onPressed: () async {
          if (!context.mounted) return;

          Navigator.popUntil(context, ModalRoute.withName('front-page'));
        },
        child: Text('Restart ${widget.story.title}'),
      ));

      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(ElevatedButton(
        onPressed: () async {
          if (!context.mounted) return;

          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: const Text('Back to Story List'),
      ));
    }

    return widgets;
  }

  PageRouteBuilder<dynamic> _getPageTransition(StoryPage nextPage) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoryPageScreen(widget.story, nextPage),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        transitionDuration: const Duration(milliseconds: 1000));
  }

  Future<void> _playPageLoadSound() async {
    if (widget.storyPage.soundFileName.isEmpty) return;

    try {
      var soundAsset = AssetSource(soundPath);
      await soundAsset.setOnPlayer(_player);
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentWordIndex.value < words.length - 1) {
        _currentWordIndex.value++;
      } else {
        timer.cancel();
        _currentWordIndex.value = -1;
      }
    });
  }
}

class AnimatedStoryText extends StatelessWidget {
  final List<String> words;
  final ValueNotifier<int> currentWordIndex;

  const AnimatedStoryText(
      {super.key, required this.words, required this.currentWordIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: currentWordIndex,
      builder: (context, _) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            children: words.asMap().entries.expand((entry) {
              int index = entry.key;
              String word = entry.value;
              return [
                WidgetSpan(
                  child: StoryText(
                      word: word,
                      index: index,
                      currentWordIndex: currentWordIndex),
                ),
                const TextSpan(text: ' '),
              ];
            }).toList(),
          ),
        );
      },
    );
  }
}

class StoryText extends StatelessWidget {
  final String word;
  final int index;
  final ValueNotifier<int> currentWordIndex;

  const StoryText(
      {super.key,
      required this.word,
      required this.index,
      required this.currentWordIndex});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(word,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        AnimatedOpacity(
          opacity:
              index == currentWordIndex.value && currentWordIndex.value != -1
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(word,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ],
    );
  }
}
