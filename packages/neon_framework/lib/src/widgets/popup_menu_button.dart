import 'package:flutter/material.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/widgets.dart';

/// A popup menu button that displays a list of [NeonSelectAction]s.
class NeonPopupMenuButton extends StatelessWidget {
  /// Creates a new [NeonPopupMenuButton].
  const NeonPopupMenuButton({
    super.key,
    required this.actions,
    this.onSelected,
  });

  final List<NeonSelectAction> actions;
  final void Function(NeonSelectAction)? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NeonSelectAction>(
      tooltip: NeonLocalizations.of(context).selectionActions,
      onSelected: (action) => onSelected?.call(action),
      itemBuilder: (context) => actions
          .where(
            (action) => action.mayRender(),
          )
          .map(
            (action) => _buildPopupMenuItem(context, action),
          )
          .toList(),
    );
  }

  PopupMenuItem<NeonSelectAction> _buildPopupMenuItem(BuildContext context, NeonSelectAction action) {
    return PopupMenuItem<NeonSelectAction>(
      value: action,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action.icon != null) ...[
            Icon(action.icon),
            const SizedBox(width: 8),
          ],
          Text(action.label(context)),
        ],
      ),
    );
  }
}
