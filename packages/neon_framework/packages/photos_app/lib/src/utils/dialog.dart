import 'package:flutter/material.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/widgets.dart';
import 'package:photos_app/l10n/localizations.dart';

/// Asks whether photos in subdirectories should be loaded, preserving dismissal as `null`.
Future<bool?> showRecursionDialog(BuildContext context) => showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => NeonDialog(
        automaticallyShowCancel: false,
        title: Text(PhotosLocalizations.of(context).recursionDialogTitle),
        content: Text(PhotosLocalizations.of(context).recursionDialogContent),
        actions: [
          NeonDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            // Keep dialog answers conversational while settings use state labels.
            child: Text(NeonLocalizations.of(context).actionNo),
          ),
          NeonDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(NeonLocalizations.of(context).actionYes),
          ),
        ],
      ),
    );
