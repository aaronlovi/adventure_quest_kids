import 'package:adventure_quest_kids/l10n/app_localizations.dart';
import 'package:adventure_quest_kids/utils/locale_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../registry.dart';
import '../utils/navigation_utils.dart';

class SettingsScreen extends StatefulWidget {
  final Registry registry;

  SettingsScreen({super.key}) : registry = GetIt.I.get<Registry>();

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late double _backgroundVolume;
  late double _foregroundVolume;
  late double _speechVolume;
  late double _speechRate;
  late String _localeName;
  late bool _isDirty;

  @override
  void initState() {
    super.initState();
    stopSpeech(widget.registry);
    _backgroundVolume = widget.registry.backgroundVolume;
    _foregroundVolume = widget.registry.foregroundVolume;
    _speechVolume = widget.registry.speechVolume;
    _speechRate = widget.registry.speechRate;
    _localeName = widget.registry.localeName;
    _isDirty = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: _getBody(context),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onBackButtonPressed(context),
        ),
        titleSpacing: 0,
        title: Text(AppLocalizations.of(context)!.settings));
  }

  void _onBackButtonPressed(BuildContext context) async {
    if (!_isDirty) {
      popOnce(context);
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.unsaved_changes),
        content: Text(
            AppLocalizations.of(context)!.you_have_unsaved_changes__confirm),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () => _cancelChanges(context, closeAlertDialog: true),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: () => popOnce(context),
          ),
        ],
      ),
    );
  }

  void _cancelChanges(
    BuildContext context, {
    bool closeAlertDialog = false,
    bool closeSettingsScreen = true,
  }) {
    setState(() {
      _backgroundVolume = widget.registry.backgroundVolume;
      _foregroundVolume = widget.registry.foregroundVolume;
      _speechVolume = widget.registry.speechVolume;
      _speechRate = widget.registry.speechRate;
      _localeName = widget.registry.localeName;
      _isDirty = false;
    });
    if (closeAlertDialog) popOnce(context); // Close the alert dialog
    if (closeSettingsScreen) {
      popOnce(context); // Close the SettingsScreen (this widget)
    }
  }

  Widget _getBody(BuildContext context) {
    var widgets = <Widget>[];

    _getBackgroundVolumeLabel(widgets);
    _getBackgroundVolumeSlider(widgets);
    _getForegroundVolumeLabel(widgets);
    _getForegroundVolumeSlider(widgets);
    _getSpeechVolumeLabel(widgets);
    _getSpeechVolumeSlider(widgets);
    _getSpeechRateLabel(widgets);
    _getSpeechRateSlider(widgets);
    _getLocaleDropdown(widgets);
    _getSaveCancelButtons(context, widgets);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: widgets),
    );
  }

  void _getBackgroundVolumeLabel(List<Widget> widgets) {
    widgets.add(Text(
        AppLocalizations.of(context)!.background_volume_n0(_backgroundVolume)));
  }

  void _getBackgroundVolumeSlider(List<Widget> widgets) {
    widgets.add(Slider(
      value: _backgroundVolume,
      min: 0.0,
      max: 1.0,
      onChanged: (value) {
        _backgroundVolume = value;
        _isDirty = true;
        setState(() {});
      },
    ));
  }

  void _getForegroundVolumeLabel(List<Widget> widgets) {
    widgets.add(Text(
        AppLocalizations.of(context)!.foreground_volume_n0(_foregroundVolume)));
  }

  void _getForegroundVolumeSlider(List<Widget> widgets) {
    widgets.add(Slider(
      value: _foregroundVolume,
      min: 0.0,
      max: 1.0,
      onChanged: (value) {
        _foregroundVolume = value;
        _isDirty = true;
        setState(() {});
      },
    ));
  }

  void _getSpeechVolumeLabel(List<Widget> widgets) {
    widgets.add(
        Text(AppLocalizations.of(context)!.speech_volume_n0(_speechVolume)));
  }

  void _getSpeechVolumeSlider(List<Widget> widgets) {
    widgets.add(Slider(
      value: _speechVolume,
      min: 0.0,
      max: 1.0,
      onChanged: (value) {
        _speechVolume = value;
        _isDirty = true;
        setState(() {});
      },
    ));
  }

  void _getSpeechRateLabel(List<Widget> widgets) {
    widgets
        .add(Text(AppLocalizations.of(context)!.speech_rate_n0(_speechRate)));
  }

  void _getSpeechRateSlider(List<Widget> widgets) {
    widgets.add(Slider(
      value: _speechRate,
      min: 0.5,
      max: 1.25,
      onChanged: (value) {
        _speechRate = value;
        _isDirty = true;
        setState(() {});
      },
    ));
  }

  void _getLocaleDropdown(List<Widget> widgets) {
    Map<String, String> languageMap = getLanguageMap(context);

    widgets.add(
      Row(
        children: [
          const Spacer(),
          Text('${AppLocalizations.of(context)!.language}:'),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _localeName,
            icon: const Icon(Icons.arrow_downward),
            padding: const EdgeInsets.only(left: 8, right: 8),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              _localeName = newValue!;
              _isDirty = true;
              setState(() {});
            },
            items: languageMap.entries.map<DropdownMenuItem<String>>(
                (MapEntry<String, String> entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _getSaveCancelButtons(BuildContext context, List<Widget> widgets) {
    widgets.add(const SizedBox(height: 20));
    widgets.add(
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Spacer(),
        _getOneLineFittedTextButton(
            AppLocalizations.of(context)!.save, context),
        const SizedBox(width: 16),
        _getOneLineFittedTextButton(
          AppLocalizations.of(context)!.cancel,
          context,
          isCancelButton: true,
        ),
        const Spacer(),
      ]),
    );
  }

  Widget _getOneLineFittedTextButton(
    final String text,
    BuildContext context, {
    bool isCancelButton = false,
  }) {
    return Expanded(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(2)),
            onPressed: getButtonPressFn(isCancelButton, context),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: const TextStyle(fontSize: 16)),
            )));
  }

  void Function()? getButtonPressFn(bool isCancelButton, BuildContext context) {
    if (!_isDirty && isCancelButton) {
      return () => _cancelChanges(context, closeSettingsScreen: true);
    }

    if (!_isDirty) return null;

    return isCancelButton
        ? () => _cancelChanges(context, closeSettingsScreen: false)
        : () => _saveSettings();
  }

  Future<void> _saveSettings() async {
    widget.registry.backgroundVolume = _backgroundVolume;
    widget.registry.foregroundVolume = _foregroundVolume;
    widget.registry.speechVolume = _speechVolume;
    widget.registry.speechRate = _speechRate;
    widget.registry.localeName = _localeName;
    Provider.of<LocaleProvider>(context, listen: false)
        .setLocale(Locale(widget.registry.localeName));
    await widget.registry.saveSettings();
    _isDirty = false;
    setState(() {});
  }
}
