import 'dart:async';

import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:adventure_quest_kids/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';

Future<void> stopSpeech(Registry registry) async {
  try {
    var player = registry.speechAudioPlayer;
    await player.stop();
  } catch (e) {
    if (kDebugMode) {
      print('Error stopping speech: $e');
    }
  }
}

Future<void> playSpeech(
  String speechAssetPath,
  final AssetSourceFactory assetSourceFactory,
  final Registry registry,
) async {
  if (speechAssetPath.isEmpty) return;

  try {
    var player = registry.speechAudioPlayer;
    player.setReleaseMode(ReleaseMode.release);
    AssetSource speechAsset = assetSourceFactory(speechAssetPath);
    await speechAsset.setOnPlayer(player);
    await player.setVolume(registry.speechVolume);
    await player.setPlaybackRate(registry.speechRate);
    await player.play(speechAsset, mode: PlayerMode.lowLatency);
  } catch (e) {
    if (kDebugMode) {
      print('Error playing speech: $e');
    }
  }
}

Future<void> playStoryBackgroundSound(
  StoryMetaData storyMetaData,
  AssetSource soundAsset,
  Registry registry,
) async {
  if (storyMetaData.backgroundSoundFilename.isEmpty) return;

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
      await player.play(soundAsset, mode: PlayerMode.lowLatency);

      // Fade in the volume over the period of 1 second
      const fadeInDuration = Constants.oneSecond;
      const stepTime = Constants.hundredMilliseconds;
      var steps = fadeInDuration.inMilliseconds ~/ stepTime.inMilliseconds;
      var volumeStep = registry.backgroundVolume *
          storyMetaData.backgroundVolumeAdjustmentFactor /
          steps;
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
