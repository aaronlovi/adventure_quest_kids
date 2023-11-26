import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    super.dispose();
    // _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> choicesWidgets = _getChoiceWidgets(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.story.title),
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
                children: choicesWidgets,
              ),
            ),
          ],
        ));
  }

  List<Widget> _getChoiceWidgets(BuildContext context) {
    var widgets = <Widget>[];

    widgets.add(Center(
      child: Text(
        widget.storyPage.text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ));
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
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }
}
