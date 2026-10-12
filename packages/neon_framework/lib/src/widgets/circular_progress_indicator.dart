import 'package:flutter/material.dart';

class NeonCircularProgressIndicator extends StatelessWidget {
  const NeonCircularProgressIndicator({required this.iconData, Key? key, this.progress, this.visible = true})
      : super(key: key);

  final IconData iconData;
  final double? progress;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: visible
          ? [
              Icon(
                iconData,
                color: Theme.of(context).colorScheme.primary,
              ),
              CircularProgressIndicator(value: progress),
            ]
          : [],
    );
  }
}
