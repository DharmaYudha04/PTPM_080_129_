extension StringExt on String {
  String get titleCase {
    if (trim().isEmpty) return this;
    return split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
