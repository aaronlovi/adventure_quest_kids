import 'dart:async';

import 'package:adventure_quest_kids/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
import '../model/story.dart';
import '../model/story_meta_data.dart';
import '../model/story_page.dart';
import '../registry.dart';
import 'story_page_screen_common.dart';

class StoryFrontPageScreen extends StatefulWidget {
  final StoryMetaData storyMetadata;

  const StoryFrontPageScreen({super.key, required this.storyMetadata});

  @override
  StoryFrontPageScreenState createState() => StoryFrontPageScreenState();
}

class StoryFrontPageScreenState extends State<StoryFrontPageScreen> {
  final AssetSourceFactory assetSourceFactory;
  late AssetSource soundAsset;

  StoryFrontPageScreenState()
      : assetSourceFactory = GetIt.I.get<AssetSourceFactory>();

  @override
  initState() {
    super.initState();
    _playStoryBackgroundSound();
    GetIt.I.get<Registry>().currentStoryMetaData = widget.storyMetadata;
    soundAsset = assetSourceFactory(
        '${widget.storyMetadata.soundsFolder}/${widget.storyMetadata.backgroundSoundFilename}');
  }

  @override
  void dispose() {
    super.dispose();
    var registry = GetIt.I.get<Registry>();
    registry.backgroundAudioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final double w = context.width;
    final double h = context.height;
    final storyMetadata = widget.storyMetadata;

    return Scaffold(
        appBar: getAppBar(context,
            title: storyMetadata.title,
            subTitle: storyMetadata.subTitle,
            isStartPage: true),
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
          storyMetadata.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (storyMetadata.subTitle.isNotEmpty) {
      bodyChildWidgets.add(
        Center(
          child: Text(
            storyMetadata.subTitle,
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
          onPressed: () async {
            Story story = await storyMetadata.getStory();
            StoryPage storyPage = story.pages[storyMetadata.firstPageId]!;

            if (!context.mounted) return;

            Navigator.push(
              context,
              getPageTransition(story, storyPage),
            );
          },
          child: const Text('Begin Adventure'),
        ),
      ),
    );

    return bodyChildWidgets;
  }

  Future<void> _playStoryBackgroundSound() async {
    var storyMetaData = widget.storyMetadata;
    if (storyMetaData.backgroundSoundFilename.isEmpty) return;

    var registry = GetIt.I.get<Registry>();
    var player = registry.backgroundAudioPlayer;

    try {
      await player.stop();
      player.setReleaseMode(ReleaseMode.release);
      await soundAsset.setOnPlayer(player);

      // Create a loop that plays the sound, waits for it to complete, waits for an additional delay, and then repeats
      while (registry.currentStoryMetaData == storyMetaData) {
        // Check if the current story meta data is still the same
        await player.setPlaybackRate(storyMetaData.backgroundSoundPlaybackRate);
        await player.setVolume(0); // Start with volume 0
        await player.play(soundAsset, mode: PlayerMode.mediaPlayer);

        // Fade in the volume over the period of 1 second
        const fadeInDuration = Duration(seconds: 1);
        const stepTime = Duration(milliseconds: 100);
        var steps = fadeInDuration.inMilliseconds ~/ stepTime.inMilliseconds;
        var volumeStep = storyMetaData.backgroundSoundVolume / steps;
        for (var i = 0; i < steps; i++) {
          // Allow cancellation
          if (registry.currentStoryMetaData != storyMetaData) break;

          await Future.delayed(stepTime);
          await player.setVolume((i + 1) * volumeStep);
        }

        // Allow cancellation
        if (registry.currentStoryMetaData != storyMetaData) break;

        // Wait for the audio to finish playing
        var completer = Completer();
        StreamSubscription playerCompletionSubscription =
            player.onPlayerComplete.listen((_) {});

        playerCompletionSubscription = player.onPlayerComplete.listen((event) {
          playerCompletionSubscription.cancel(); // Unregister the listener
          completer.complete();
        });
        await completer.future;

        await Future.delayed(
            const Duration(milliseconds: 500)); // Wait for an additional delay
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background sound: $e');
      }
    }
  }
}
