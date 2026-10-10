import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/blocs/unified_search.dart';
import 'package:neon_framework/src/utils/global_options.dart' as global_options;
import 'package:neon_framework/src/utils/launch_url.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/src/widgets/account_switcher_button.dart';
import 'package:neon_framework/src/widgets/app_bar_controller.dart';
import 'package:neon_framework/src/widgets/multi_select.dart';
import 'package:neon_framework/src/widgets/popup_menu_button.dart';
import 'package:neon_framework/src/widgets/unified_search_results.dart';
import 'package:rxdart/rxdart.dart';

/// Global app bar for the Neon app.
@internal
class NeonAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a new Neon app bar.
  const NeonAppBar({super.key, this.title});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<NeonAppBar> createState() => _NeonAppBarState();
}

class _NeonAppBarState extends State<NeonAppBar> {
  late global_options.GlobalOptions globalOptions;
  late UnifiedSearchBloc unifiedSearchBloc;
  late AppsBloc appsBloc;
  late NeonAppBarController appBarController;
  final searchTermController = StreamController<String>();
  late final StreamSubscription<String> searchTermSubscription;
  final searchController = SearchController();

  @override
  void initState() {
    super.initState();

    globalOptions = NeonProvider.of<global_options.GlobalOptions>(context);
    unifiedSearchBloc = NeonProvider.of<UnifiedSearchBloc>(context);
    appsBloc = NeonProvider.of<AppsBloc>(context);
    appBarController = NeonProvider.of<NeonAppBarController>(context);

    searchTermSubscription =
        searchTermController.stream.debounceTime(const Duration(milliseconds: 250)).listen(unifiedSearchBloc.search);
  }

  @override
  void dispose() {
    searchController.dispose();
    unawaited(searchTermSubscription.cancel());
    unawaited(searchTermController.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild the global bar when the active app's selection changes.
    return ListenableBuilder(
      listenable: appBarController,
      builder: (context, _) {
        final selection = appBarController.selection;

        if (selection != null && selection.selectedCount > 0) {
          return BackButtonListener(
            onBackButtonPressed: () async {
              if (selection.selectedCount > 0) {
                selection.clear();
                return true;
              }
              return false;
            },
            child: AppBar(
              leading: BackButton(
                onPressed: selection.clear,
              ),
              title: Text(NeonLocalizations.of(context).selectionCount(selection.selectedCount)),
              actions: [_buildSelectionPopupMenu(context, selection)],
            ),
          );
        }

        return AppBar(
          centerTitle: widget.title == null,
          title: widget.title != null ? Text(widget.title!) : _buildSearchAnchor(context),
          actions: const [
            AccountSwitcherButton(),
          ],
        );
      },
    );
  }

  Widget _buildSelectionPopupMenu(BuildContext context, NeonMultiSelectSession selection) {
    return NeonPopupMenuButton(
      actions: selection.actions,
      onSelected: (action) async {
        final result = await action.onSelected(context);
        if (result == NeonMultiSelectActionResult.clearSelection && identical(appBarController.selection, selection)) {
          selection.clear();
        }
      },
    );
  }

  Widget _buildSearchAnchor(BuildContext context) {
    return StreamBuilder(
      stream: appsBloc.activeApp,
      builder: (context, activeAppSnapshot) {
        if (!activeAppSnapshot.hasData) {
          return const Align(
            alignment: Alignment.topRight,
            child: AccountSwitcherButton(),
          );
        }
        final activeApp = activeAppSnapshot.requireData;

        final localizations = NeonLocalizations.of(context);
        final hintText = localizations.searchIn(activeApp.nameFromLocalization(localizations));

        return SearchAnchor(
          isFullScreen: true,
          viewHintText: hintText,
          textInputAction: TextInputAction.search,
          searchController: searchController,
          builder: (context, controller) => SearchBar(
            constraints: const BoxConstraints(minHeight: 44),
            hintText: hintText,
            textInputAction: TextInputAction.search,
            onTap: () {
              controller.openView();
            },
          ),
          viewBuilder: (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: NeonUnifiedSearchResults(
              onSelected: (entry) async {
                searchController.closeView('');
                await launchUrl(NeonProvider.of<Account>(context), entry.resourceUrl);
              },
            ),
          ),
          viewOnChanged: searchTermController.add,
          // The view is completely custom rendered, so we don't need the suggestions
          suggestionsBuilder: (context, controller) async => [],
        );
      },
    );
  }
}
