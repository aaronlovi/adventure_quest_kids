class UserSettings {
  static const double defaultBackgroundVolume = 0.3;
  static const double defaultForegroundVolume = 0.8;

  double backgroundVolume;
  double foregroundVolume;

  UserSettings({
    this.backgroundVolume = defaultBackgroundVolume,
    this.foregroundVolume = defaultForegroundVolume,
  });
}
