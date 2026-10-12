import 'package:files_app/files_lib.dart';
import 'package:flutter/material.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    Key? key,
    required this.bloc,
    required this.details,
    this.disabled = false,
  }) : super(key: key);

  final FilesBloc bloc;
  final FileDetails details;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed:
          disabled ? null : () => ToggleFavoriteFilesAction(items: [details], filesBloc: bloc).onSelected(context),
      icon: details.isFavorite ?? false ? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.star_outline),
    );
  }
}
