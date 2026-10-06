import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/blocs/unified_search.dart';
import 'package:neon_framework/src/models/disposable.dart';
import 'package:neon_framework/src/utils/global_options.dart' as global_options;
import 'package:neon_framework/src/utils/launch_url.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/src/widgets/account_switcher_button.dart';
import 'package:neon_framework/src/widgets/multi_select.dart';
import 'package:neon_framework/src/widgets/popup_menu_button.dart';
import 'package:neon_framework/src/widgets/unified_search_results.dart';
import 'package:rxdart/rxdart.dart';

/// A provider for the Neon app bar.
/// This is in preparation for global Multi-Select support.
/// This provider will wrap the NeonAppBar with the respective controller.
/// For now we are using this to allow apps to re-use the same app bar for a unified experience across all apps.
class NeonAppBarProvider extends StatelessWidget {
  /// Creates a new Neon app bar provider.
  const NeonAppBarProvider({
    required this.builder,
    this.title,
    super.key,
  });

  /// Gets called back with the [NeonAppBar] and the [BuildContext]. Is expected to build the actual app page.
  final Widget Function(BuildContext context, NeonAppBar appBar) builder;

  // The title of the app bar. If null, the app bar will show the search bar instead.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return NeonProvider<NeonAppBarController>(
      create: (_) => NeonAppBarController(),
      child: builder(
        context,
        NeonAppBar(title: title),
      ),
    );
  }
}

/// Lets an active app register selection state for the global app bar.
class NeonAppBarController extends ChangeNotifier implements Disposable {
  ObjectKey? _owner;
  NeonMultiSelectSession? _selection;

  /// The current selection session, if an active app has registered one.
  NeonMultiSelectSession? get selection => _selection;

  /// Registers [session] until [owner] clears it or another owner replaces it.
  void registerSelectionSession(ObjectKey owner, NeonMultiSelectSession session) {
    if (identical(_owner, owner) && identical(_selection, session)) {
      return;
    }

    _switchState(owner, session);
  }

  /// Clears the selection session only when [owner] still owns the app bar.
  void clearSelectionSession(ObjectKey owner) {
    if (!identical(_owner, owner)) {
      return;
    }

    _switchState(null, null);
  }

  @override
  void dispose() {
    _switchState(null, null);
    super.dispose();
  }

  void _onSelectionChanged() => notifyListeners();

  void _switchState(ObjectKey? owner, NeonMultiSelectSession? session) {
    _selection?.removeListener(_onSelectionChanged);
    _owner = owner;
    _selection = session;
    _selection?.addListener(_onSelectionChanged);
  }
}

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
              leading: BackButton(onPressed: selection.clear),
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
            // SearchBar by default uses the entire AppBar height.
            constraints: const BoxConstraints(minHeight: kToolbarHeight - 12),
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
