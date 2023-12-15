class StoryMetaData {
  final String assetName;
  final String title;
  final String subTitle;
  final String firstPageId;
  final String listIcon;
  final String storyId; // Key for this story in YAML file
  final String backgroundSoundFilename;
  final double backgroundVolumeAdjustmentFactor;
  final double backgroundSoundPlaybackRate;
  final Set<String> terminalPageIds;

  StoryMetaData({
    required this.assetName,
    required this.title,
    required this.firstPageId,
    required this.subTitle,
    required this.listIcon,
    required this.storyId,
    required this.backgroundSoundFilename,
    required this.backgroundVolumeAdjustmentFactor,
    required this.backgroundSoundPlaybackRate,
    required this.terminalPageIds,
  });

  String get assetsFolder => 'assets/$assetName';

  String get imagesFolder => '$assetsFolder/images';

  String get soundsFolder => '$assetsFolder/sounds';

  String get speechFolder => '$assetsFolder/speech';

  String get storyDataFolder => '$assetsFolder/story_data';

  String get fullTitle => subTitle.isEmpty ? title : '$title: $subTitle';

  String get listIconFilename => '$imagesFolder/$listIcon';
}
