class StoryMetaData {
  final String assetName;
  final String title;
  final String subTitle;
  final String firstPageId;
  final String listIcon;
  final String backgroundSoundFilename;
  final double backgroundVolumeAdjustmentFactor;
  final double backgroundSoundPlaybackRate;

  StoryMetaData({
    required this.assetName,
    required this.title,
    required this.firstPageId,
    required this.subTitle,
    required this.listIcon,
    required this.backgroundSoundFilename,
    required this.backgroundVolumeAdjustmentFactor,
    required this.backgroundSoundPlaybackRate,
  });

  String get assetsFolder => 'assets/$assetName';

  String get imagesFolder => '$assetsFolder/images';

  String get soundsFolder => '$assetsFolder/sounds';

  String get storyDataFolder => '$assetsFolder/story_data';

  String get fullTitle => subTitle.isEmpty ? title : '$title: $subTitle';

  String get listIconFilename => '$imagesFolder/$listIcon';
}
