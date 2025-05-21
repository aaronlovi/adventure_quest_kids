// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get adventure_quest_kids => 'Adventure Quest Kids';

  @override
  String get all_endings_visited => 'All endings visited\nCongratulations!';

  @override
  String get some_endings_visited => 'Some endings visited\nKeep exploring!';

  @override
  String get no_endings_visited => 'No endings visited\nStart exploring!';

  @override
  String get begin_adventure => 'Begin Adventure';

  @override
  String get start_of_story => 'Start of story';

  @override
  String get story_list => 'Story list';

  @override
  String get settings => 'Settings';

  @override
  String get read_aloud => 'Read Aloud';

  @override
  String get the_end => 'The End';

  @override
  String restart_s0(Object story) {
    return 'Restart $story';
  }

  @override
  String get back_to_story_list => 'Back to Story List';

  @override
  String get unsaved_changes => 'Unsaved Changes';

  @override
  String get you_have_unsaved_changes__confirm =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String background_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Background Volume: $volumeString';
  }

  @override
  String foreground_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Foreground Volume: $volumeString';
  }

  @override
  String speech_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Speech Volume: $volumeString';
  }

  @override
  String speech_rate_n0(double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String rateString = rateNumberFormat.format(rate);

    return 'Speech Rate: $rateString';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get privacy_policy => 'Privacy Policy';
}
