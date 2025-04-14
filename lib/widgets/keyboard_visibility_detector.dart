import 'package:flutter/material.dart';

class KeyboardVisibilityDetector extends StatefulWidget {
  const KeyboardVisibilityDetector({super.key});

  @override
  _KeyboardVisibilityDetectorState createState() => _KeyboardVisibilityDetectorState();
}

class _KeyboardVisibilityDetectorState extends State<KeyboardVisibilityDetector> with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() => _isKeyboardVisible = bottomInset > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Text(_isKeyboardVisible ? "Keyboard Visible" : "Keyboard Hidden");
  }
}