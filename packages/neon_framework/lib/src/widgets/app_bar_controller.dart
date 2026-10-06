import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:neon_framework/src/models/disposable.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/src/widgets/app_bar.dart';
import 'package:neon_framework/src/widgets/multi_select.dart';

class NeonAppBarProvider extends StatelessWidget {
  const NeonAppBarProvider({
    required this.builder,
    this.title,
    super.key,
  });

  final Widget Function(BuildContext context, NeonAppBar appBar) builder;
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
