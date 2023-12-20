class UserSettings {
  static const double defaultBackgroundVolume = 0.3;
  static const double defaultForegroundVolume = 0.8;
  static const double defaultSpeechVolume = 0.7;
  static const double defaultSpeechRate = 0.9;

  double backgroundVolume;
  double foregroundVolume;
  double speechVolume;
  double speechRate;
  String? localeName;

  /// Map from story name => set of visited terminal page ids.
  /// The idea is to show the user whether they have gotten to the end of a story,
  /// and whether they have seen every possible end of the story.
  Map<String, Set<String>> terminalPagesVisited;

  UserSettings(
      {this.backgroundVolume = defaultBackgroundVolume,
      this.foregroundVolume = defaultForegroundVolume,
      this.speechVolume = defaultSpeechVolume,
      this.speechRate = defaultSpeechRate,
      this.localeName,
      this.terminalPagesVisited = const {}});
}
