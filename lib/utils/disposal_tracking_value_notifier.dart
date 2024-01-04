import 'package:flutter/material.dart';

class DisposalTrackingValueNotifier<T> extends ValueNotifier<T> {
  bool _isDisposed = false;

  DisposalTrackingValueNotifier(super.value);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get isDisposed => _isDisposed;
}
