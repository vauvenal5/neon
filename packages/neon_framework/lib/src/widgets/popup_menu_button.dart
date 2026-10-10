import 'package:flutter/material.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/widgets.dart';

/// A popup menu button that displays a list of [FilesAction]s.
class NeonPopupMenuButton extends StatelessWidget {
  /// Creates a new [NeonPopupMenuButton].
  const NeonPopupMenuButton({
    super.key,
    required this.actions,
    this.onSelected,
  });

  final List<FilesAction> actions;
  final void Function(FilesAction)? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilesAction>(
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

  PopupMenuItem<FilesAction> _buildPopupMenuItem(BuildContext context, FilesAction action) {
    return PopupMenuItem<FilesAction>(
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
