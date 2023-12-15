import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
  late bool _isDirty;

  @override
  void initState() {
    super.initState();
    stopSpeech(widget.registry);
    _backgroundVolume = widget.registry.backgroundVolume;
    _foregroundVolume = widget.registry.foregroundVolume;
    _speechVolume = widget.registry.speechVolume;
    _speechRate = widget.registry.speechRate;
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
        title: const Text('Settings'));
  }

  void _onBackButtonPressed(BuildContext context) async {
    if (!_isDirty) {
      popOnce(context);
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () => _cancelChanges(context, closeAlertDialog: true),
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () => popOnce(context),
          ),
        ],
      ),
    );
  }

  void _cancelChanges(BuildContext context, {bool closeAlertDialog = false}) {
    _backgroundVolume = widget.registry.backgroundVolume;
    _foregroundVolume = widget.registry.foregroundVolume;
    _speechVolume = widget.registry.speechVolume;
    _speechRate = widget.registry.speechRate;
    _isDirty = false;
    if (closeAlertDialog) popOnce(context); // Close the alert dialog
    popOnce(context); // Close the SettingsScreen (this widget)
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
    _getSaveCancelButtons(context, widgets);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: widgets),
    );
  }

  void _getBackgroundVolumeLabel(List<Widget> widgets) {
    widgets.add(Text(
        'Background Volume: ${(_backgroundVolume * 100).toStringAsFixed(0)}%'));
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
        'Foreground Volume: ${(_foregroundVolume * 100).toStringAsFixed(0)}%'));
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
        Text('Speech Volume: ${(_speechVolume * 100).toStringAsFixed(0)}%'));
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
        .add(Text('Speech Rate: ${(_speechRate * 100).toStringAsFixed(0)}%'));
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

  void _getSaveCancelButtons(BuildContext context, List<Widget> widgets) {
    widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Spacer(),
      _getOneLineFittedTextButton('Save'),
      const SizedBox(width: 16),
      _getOneLineFittedTextButton('Cancel'),
      const Spacer(),
    ]));
  }

  Widget _getOneLineFittedTextButton(final String text) {
    return Expanded(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(2)),
            onPressed: _isDirty ? _saveSettings : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: const TextStyle(fontSize: 16)),
            )));
  }

  Future<void> _saveSettings() async {
    widget.registry.backgroundVolume = _backgroundVolume;
    widget.registry.foregroundVolume = _foregroundVolume;
    widget.registry.speechVolume = _speechVolume;
    widget.registry.speechRate = _speechRate;
    await widget.registry.saveSettings();
    _isDirty = false;
    setState(() {});
  }
}
