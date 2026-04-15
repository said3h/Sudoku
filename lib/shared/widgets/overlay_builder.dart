import 'package:flutter/material.dart';

class OverlayBuilder extends StatefulWidget {
  final Widget Function(BuildContext) overlayBuilder;
  final Widget child;

  const OverlayBuilder({
    super.key,
    required this.overlayBuilder,
    required this.child,
  });

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        widget.overlayBuilder(context),
      ],
    );
  }
}
