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
    return builder(
      context,
      NeonAppBar(title: title),
    );
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
  final searchTermController = StreamController<String>();
  late final StreamSubscription<String> searchTermSubscription;
  final searchController = SearchController();

  @override
  void initState() {
    super.initState();

    globalOptions = NeonProvider.of<global_options.GlobalOptions>(context);
    unifiedSearchBloc = NeonProvider.of<UnifiedSearchBloc>(context);
    appsBloc = NeonProvider.of<AppsBloc>(context);

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
    return AppBar(
      centerTitle: widget.title == null,
      title: widget.title != null ? Text(widget.title!) : _buildSearchAnchor(context),
      actions: const [
        AccountSwitcherButton(),
      ],
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
