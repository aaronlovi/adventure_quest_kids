import 'package:adventure_quest_kids/services/yaml_factory.dart';
import 'package:adventure_quest_kids/utils/constants.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model/story.dart';
import '../model/story_meta_data.dart';
import '../model/story_page.dart';
import '../registry.dart';
import 'story_page_screen.dart';
import 'story_page_screen_common.dart';

class StoryFrontPageScreen extends StatefulWidget {
  final StoryMetaData storyMetadata;
  final AssetSourceFactory assetSourceFactory;
  final Registry registry;
  final RouteObserver<PageRoute> routeObserver;

  const StoryFrontPageScreen({
    super.key,
    required this.storyMetadata,
    required this.assetSourceFactory,
    required this.registry,
    required this.routeObserver,
  });

  @override
  StoryFrontPageScreenState createState() => StoryFrontPageScreenState();
}

class StoryFrontPageScreenState extends State<StoryFrontPageScreen> {
  late AssetSource soundAsset;

  StoryFrontPageScreenState();

  String get localeName => widget.registry.localeName;

  @override
  initState() {
    super.initState();
    soundAsset = widget.assetSourceFactory(
        '${widget.storyMetadata.soundsFolder}/${widget.storyMetadata.backgroundSoundFilename}');
    widget.registry.currentStoryMetaData = widget.storyMetadata;
    stopSpeech(widget.registry);
    playStoryBackgroundSound(widget.storyMetadata, soundAsset, widget.registry);
  }

  @override
  void dispose() {
    super.dispose();
    widget.registry.backgroundAudioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final double w = context.width;
    final double h = context.height;
    final storyMetadata = widget.storyMetadata;

    return Scaffold(
        appBar: getAppBar(
          context,
          title: storyMetadata.getTitle(localeName),
          subTitle: storyMetadata.getSubTitle(localeName),
          isStartPage: true,
        ),
        body: _getBodyWidgets(w, h, context, storyMetadata));
  }

  Column _getBodyWidgets(
    final double w,
    final double h,
    BuildContext context,
    StoryMetaData storyMetadata,
  ) {
    var bodyChildWidgets = _createBodyChildWidgets(storyMetadata, context);

    return Column(
      children: [
        // Top half: Container for Image
        Container(
            height: h * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(
                      '${storyMetadata.imagesFolder}/cover_image.jpg')),
            )),
        // Bottom half: Text and Choices
        Container(
          height: h * 0.4,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bodyChildWidgets,
          ),
        ),
      ],
    );
  }

  List<Widget> _createBodyChildWidgets(
      StoryMetaData storyMetadata, BuildContext context) {
    final bodyChildWidgets = <Widget>[];

    // Text for this page
    bodyChildWidgets.add(
      Center(
        child: Text(
          storyMetadata.getTitle(localeName),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final String subTitle = storyMetadata.getSubTitle(localeName);
    if (subTitle.isNotEmpty) {
      bodyChildWidgets.add(
        Center(
          child: Text(
            subTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    bodyChildWidgets.add(const SizedBox(height: 16));
    bodyChildWidgets.add(
      // Add your choice buttons/widgets here
      Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
          onPressed: () async {
            Story story = await YamlFactory.getStory(storyMetadata);

            if (!context.mounted) return;

            StoryPage storyPage = story.pages[storyMetadata.firstPageId]!;

            pushRouteWithTransition(
                context,
                StoryPageScreen(
                  storyPageId: storyMetadata.firstPageId,
                  story: story,
                  storyPage: storyPage,
                  routeObserver: widget.routeObserver,
                  registry: widget.registry,
                ));
          },
          child: Text(AppLocalizations.of(context)!.begin_adventure,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ),
      ),
    );

    return bodyChildWidgets;
  }
}
