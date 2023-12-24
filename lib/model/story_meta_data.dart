class StoryMetaData {
  final String assetName;
  final String _title;
  final Map<String, String> _titleByLanguage;
  final String _subTitle;
  final Map<String, String> _subTitleByLanguage;
  final String firstPageId;
  final String listIcon;
  final String storyId; // Key for this story in YAML file
  final String backgroundSoundFilename;
  final double backgroundVolumeAdjustmentFactor;
  final double backgroundSoundPlaybackRate;
  final Set<String> terminalPageIds;

  StoryMetaData({
    required this.assetName,
    required title,
    required titleByLanguage,
    required this.firstPageId,
    required subTitle,
    required subTitleByLanguage,
    required this.listIcon,
    required this.storyId,
    required this.backgroundSoundFilename,
    required this.backgroundVolumeAdjustmentFactor,
    required this.backgroundSoundPlaybackRate,
    required this.terminalPageIds,
  })  : _title = title,
        _titleByLanguage = titleByLanguage,
        _subTitle = subTitle,
        _subTitleByLanguage = subTitleByLanguage;

  String get assetsFolder => 'assets/$assetName';

  String get imagesFolder => '$assetsFolder/images';

  String get soundsFolder => '$assetsFolder/sounds';

  String get speechFolder => '$assetsFolder/speech';

  String get storyDataFolder => '$assetsFolder/story_data';

  // String get fullTitle => subTitle.isEmpty ? title : '$title: $subTitle';

  String getFullTitle(String localeName) {
    String title_ = getTitle(localeName);
    String subTitle_ = getSubTitle(localeName);
    return subTitle_.isEmpty ? title_ : '$title_: $subTitle_';
  }

  String getTitle(String localeName) {
    return _titleByLanguage[localeName] ?? _title;
  }

  String getSubTitle(String localeName) {
    return _subTitleByLanguage[localeName] ?? _subTitle;
  }

  String get listIconFilename => '$imagesFolder/$listIcon';
}
