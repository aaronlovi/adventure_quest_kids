import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:flutter/material.dart';

class StoryPageScreen extends StatelessWidget {
  final Story story;
  final StoryPage storyPage;

  const StoryPageScreen(this.story, this.storyPage, {super.key});

  String get imagePath => '${story.imagesFolder}/${storyPage.imageFileName}';

  @override
  Widget build(BuildContext context) {
    List<Widget> choicesWidgets = getChoiceWidgets(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(story.title),
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
                    fit: BoxFit.cover,
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

  List<Widget> getChoiceWidgets(BuildContext context) {
    var widgets = <Widget>[];

    widgets.add(Center(
      child: Text(
        storyPage.text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ));
    widgets.add(const SizedBox(height: 16));

    for (String choiceName in storyPage.choices.keys) {
      StoryChoice choice = storyPage.choices[choiceName]!;

      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(ElevatedButton(
        onPressed: () async {
          if (!context.mounted) return;
          StoryPage nextPage = story.pages[choice.nextPageId]!;

          Navigator.push(
            context,
            getPageTransition(nextPage),
          );
        },
        child: Text(choice.text),
      ));
    }

    if (storyPage.isTerminal) {
      widgets.add(const Padding(padding: EdgeInsets.only(top: 16)));
      widgets.add(const Text('The End',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));

      widgets.add(const Padding(padding: EdgeInsets.only(top: 24)));
      widgets.add(ElevatedButton(
        onPressed: () async {
          if (!context.mounted) return;

          Navigator.popUntil(context, ModalRoute.withName('front-page'));
        },
        child: Text('Restart ${story.title}'),
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

  PageRouteBuilder<dynamic> getPageTransition(StoryPage nextPage) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoryPageScreen(story, nextPage),
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
}
