import 'package:flutter/material.dart';

import '../model/story.dart';
import '../model/story_meta_data.dart';
import '../model/story_page.dart';
import 'story_page_screen.dart';

class StoryFrontPageScreen extends StatelessWidget {
  final StoryMetaData storyMetadata;

  const StoryFrontPageScreen({super.key, required this.storyMetadata});

  String getSoundPath(StoryPage storyPage) =>
      '${storyMetadata.soundsFolder}/${storyPage.soundFileName}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(storyMetadata.title),
          actions: [
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
                      image: AssetImage(
                          '${storyMetadata.imagesFolder}/cover_image.jpg')),
                )),
            // Bottom half: Text and Choices
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text for this page
                  Center(
                    child: Text(storyMetadata.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  // Add your choice buttons/widgets here
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        Story story = await storyMetadata.getStory();
                        StoryPage storyPage =
                            story.pages[storyMetadata.firstPageId]!;

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          getPageTransition(story, storyPage),
                        );
                      },
                      child: const Text('Begin Adventure'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  PageRouteBuilder<dynamic> getPageTransition(
      Story story, StoryPage storyPage) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          StoryPageScreen(story, storyPage),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );

        // playSoundOnPageTransition(
        //     storyPage, curvedAnimation, getSoundPath(storyPage));

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 1000),
    );
  }
}
