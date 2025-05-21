// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get adventure_quest_kids => 'Quête D\'aventure Les Enfants';

  @override
  String get all_endings_visited => 'Toutes les fins visitées\nfélicitations!';

  @override
  String get some_endings_visited =>
      'Quelques fins visitées\nContinuez à explorer!';

  @override
  String get no_endings_visited => 'Aucune fin visitée\nCommencez à explorer!';

  @override
  String get begin_adventure => 'Commencer l\'aventure';

  @override
  String get start_of_story => 'Début de l\'histoire';

  @override
  String get story_list => 'Liste d\'histoires';

  @override
  String get settings => 'Paramètres';

  @override
  String get read_aloud => 'Lit à voix haute';

  @override
  String get the_end => 'La fin';

  @override
  String restart_s0(Object story) {
    return 'Redémarrer $story';
  }

  @override
  String get back_to_story_list => 'Retour à la liste des histoires';

  @override
  String get unsaved_changes => 'Modifications non enregistrées';

  @override
  String get you_have_unsaved_changes__confirm =>
      'Vous avez des changements non enregistrés. Êtes-vous sûr de vouloir quitter?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String background_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Volume de fond: $volumeString';
  }

  @override
  String foreground_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Volume de premier plan: $volumeString';
  }

  @override
  String speech_volume_n0(double volume) {
    final intl.NumberFormat volumeNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String volumeString = volumeNumberFormat.format(volume);

    return 'Volume de la parole: $volumeString';
  }

  @override
  String speech_rate_n0(double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.percentPattern(localeName);
    final String rateString = rateNumberFormat.format(rate);

    return 'Débit de parole: $rateString';
  }

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get privacy_policy => 'Politique de confidentialité';
}
