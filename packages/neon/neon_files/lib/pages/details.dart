part of '../neon_files.dart';

class FilesDetailsPage extends StatelessWidget {
  const FilesDetailsPage({
    required this.bloc,
    required this.details,
    super.key,
  });

  final FilesBloc bloc;
  final FileDetails details;

  @override
  Widget build(final BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(details.name),
        ),
        body: Scrollbar(
          interactive: true,
          child: ListView(
            primary: true,
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.primary,
                child: FilePreview(
                  bloc: bloc,
                  details: details,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height / 4,
                  ),
                ),
              ),
              DataTable(
                headingRowHeight: 0,
                columns: [
                  DataColumn(label: Container()),
                  DataColumn(label: Container()),
                ],
                rows: [
                  for (final entry in {
                    details.isDirectory
                        ? AppLocalizations.of(context).filesDetailsFolderName
                        : AppLocalizations.of(context).filesDetailsFileName: details.name,
                    AppLocalizations.of(context).filesDetailsParentFolder:
                        details.path.length == 1 ? '/' : details.path.sublist(0, details.path.length - 1).join('/'),
                    details.isDirectory
                        ? AppLocalizations.of(context).filesDetailsFolderSize
                        : AppLocalizations.of(context).filesDetailsFileSize: filesize(details.size, 1),
                    AppLocalizations.of(context).filesDetailsLastModified:
                        details.lastModified.toLocal().toIso8601String(),
                    if (details.isFavorite != null) ...{
                      AppLocalizations.of(context).filesDetailsIsFavorite:
                          details.isFavorite! ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no,
                    },
                  }.entries) ...[
                    DataRow(
                      cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value)),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
}
