import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/blocs/accounts.dart';
import 'package:neon_framework/src/settings/widgets/custom_settings_tile.dart';
import 'package:neon_framework/src/widgets/dialog.dart';
import 'package:neon_framework/src/widgets/error.dart';
import 'package:neon_framework/utils.dart';

/// Account settings tile for clearing framework-managed filesystem cache data.
@internal
class ClearCachedFilesTile extends StatefulWidget {
  /// Creates a cache clearing tile for [account].
  const ClearCachedFilesTile({
    required this.account,
    required this.accountsBloc,
    super.key,
  });

  /// The account whose cache will be cleared.
  final Account account;

  /// The account coordinator used to clear the cache.
  final AccountsBloc accountsBloc;

  @override
  State<ClearCachedFilesTile> createState() => _ClearCachedFilesTileState();
}

class _ClearCachedFilesTileState extends State<ClearCachedFilesTile> {
  var _isClearing = false;

  Future<void> _clearCachedFiles() async {
    if (_isClearing) {
      return;
    }

    final localizations = NeonLocalizations.of(context);
    final name = widget.account.humanReadableID;
    final decision = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => NeonConfirmationDialog(
        icon: const Icon(Icons.delete_sweep),
        title: localizations.accountOptionsClearCachedFilesConfirmation(name),
        content: Text(localizations.accountOptionsClearCachedFilesExplanation),
      ),
    );

    if (!(decision ?? false) || !mounted) {
      return;
    }

    setState(() => _isClearing = true);
    try {
      await widget.accountsBloc.clearCachedFiles(widget.account);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.accountOptionsClearCachedFilesSuccess(name))),
        );
      }
    } catch (error) {
      if (mounted) {
        NeonError.showSnackbar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => CustomSettingsTile(
        // Keep destructive cache management visibly attached to the selected account's storage information.
        title: Text(NeonLocalizations.of(context).accountOptionsClearCachedFiles),
        subtitle: Text(NeonLocalizations.of(context).accountOptionsClearCachedFilesSubtitle),
        leading: const Icon(Icons.delete_sweep),
        trailing: _isClearing
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator.adaptive(),
              )
            : null,
        onTap: _isClearing ? null : _clearCachedFiles,
      );
}
