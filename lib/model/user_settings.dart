class UserSettings {
  static const double defaultBackgroundVolume = 0.3;
  static const double defaultForegroundVolume = 0.8;
  static const double defaultSpeechVolume = 0.7;

  double backgroundVolume;
  double foregroundVolume;
  double speechVolume;

  UserSettings({
    this.backgroundVolume = defaultBackgroundVolume,
    this.foregroundVolume = defaultForegroundVolume,
    this.speechVolume = defaultSpeechVolume,
  });
}
