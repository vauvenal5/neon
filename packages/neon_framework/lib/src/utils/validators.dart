import 'package:flutter/widgets.dart';
import 'package:neon_framework/l10n/localizations.dart';

/// Validates whether the given [input] is a valid HTTP(S) URL.
///
/// Set [httpsOnly] if you want to only allow HTTPS URLs.
/// Set [autoHttps] if you want to treat scheme-less URLs as HTTPS URLs.
/// Returns `null` if the URL is valid or a localized error message if not.
String? validateHttpUrl(
  BuildContext context,
  String? input, {
  bool httpsOnly = false,
  bool autoHttps = false,
}) {
  if (input == null || input.isEmpty) {
    return NeonLocalizations.of(context).errorInvalidURL;
  }
  final parsedInput = Uri.tryParse(input);
  // Treat a server address without a scheme as HTTPS so users can enter a bare host.
  final uri = autoHttps && parsedInput != null && !parsedInput.hasScheme
      ? Uri.tryParse('https://$input')
      : parsedInput;

  if (uri != null) {
    if (uri.isScheme('https')) {
      return null;
    }
    if (uri.isScheme('http') && !httpsOnly) {
      // TODO: Maybe make a better error message for http URLs if only https is allowed
      return null;
    }
  }

  return NeonLocalizations.of(context).errorInvalidURL;
}

/// Validates that the given [input] is neither null nor empty.
///
/// Returns `null` if not empty or a localized error message if empty.
String? validateNotEmpty(BuildContext context, String? input) {
  if (input == null || input.isEmpty) {
    return NeonLocalizations.of(context).errorEmptyField;
  }

  return null;
}
