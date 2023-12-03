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
  late bool _isDirty;

  @override
  void initState() {
    super.initState();
    _backgroundVolume = widget.registry.backgroundVolume;
    _foregroundVolume = widget.registry.foregroundVolume;
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

  Padding _getBody(BuildContext context) {
    var widgets = <Widget>[];

    _getBackgroundVolumeLabel(widgets);
    _getBackgroundVolumeSlider(widgets);
    _getForegroundVolumeLabel(widgets);
    _getForegroundVolumeSlider(widgets);
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

  void _getSaveCancelButtons(BuildContext context, List<Widget> widgets) {
    widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Spacer(),
      Expanded(
        child: ElevatedButton(
            onPressed: _isDirty ? _saveSettings : null,
            child: const Text('Save')),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
            onPressed: () => _cancelChanges(context),
            child: const Text('Cancel')),
      ),
      const Spacer(),
    ]));
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
    _isDirty = false;
    if (closeAlertDialog) popOnce(context); // Close the alert dialog
    popOnce(context); // Close the SettingsScreen (this widget)
  }

  Future<void> _saveSettings() async {
    widget.registry.backgroundVolume = _backgroundVolume;
    widget.registry.foregroundVolume = _foregroundVolume;
    await widget.registry.saveSettings();
    _isDirty = false;
    setState(() {});
  }
}
