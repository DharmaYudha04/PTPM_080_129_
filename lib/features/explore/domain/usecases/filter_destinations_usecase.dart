import '../../../../shared/models/destination.dart';

class FilterModel {
  const FilterModel({this.query = '', this.category});

  final String query;
  final String? category;
}

class FilterDestinationsUseCase {
  const FilterDestinationsUseCase();

  List<DestinationModel> call(
    List<DestinationModel> items,
    FilterModel filter,
  ) {
    final normalizedQuery = _normalize(filter.query);
    final selectedCategory = _normalize(filter.category ?? '');

    return items.where((item) {
      final searchable = [
        item.name,
        item.description,
        item.story,
        item.localInsight,
        item.address,
        item.category,
        item.type,
        ...item.tags,
      ].map(_normalize).join(' ');

      final matchesQuery = normalizedQuery.isEmpty || searchable.contains(normalizedQuery);
      final matchesCategory = selectedCategory.isEmpty || _matchesCategory(item, selectedCategory);

      return matchesQuery && matchesCategory;
    }).toList();
  }

  bool _matchesCategory(DestinationModel item, String selected) {
    final tokens = <String>{
      _normalize(item.category),
      _normalize(item.type),
      ...item.tags.map(_normalize),
      ..._aliasesFor(item.category),
      ..._aliasesFor(item.type),
      for (final tag in item.tags) ..._aliasesFor(tag),
    };

    final wanted = <String>{selected, ..._aliasesFor(selected)};
    return wanted.any(tokens.contains);
  }

  Set<String> _aliasesFor(String value) {
    final v = _normalize(value);
    const map = <String, Set<String>>{
      'budaya': {'culture', 'cultural', 'heritage', 'keraton', 'tradisi', 'jawa'},
      'culture': {'budaya', 'heritage', 'keraton', 'tradisi', 'jawa'},
      'sejarah': {'history', 'historical', 'heritage', 'museum', 'kolonial'},
      'history': {'sejarah', 'historical', 'heritage', 'museum'},
      'alam': {'nature', 'natural', 'pantai', 'gunung', 'goa', 'hutan', 'bukit'},
      'nature': {'alam', 'natural', 'pantai', 'gunung', 'goa', 'hutan', 'bukit'},
      'kuliner': {'culinary', 'food', 'makanan', 'gudeg', 'kopi', 'sate'},
      'culinary': {'kuliner', 'food', 'makanan', 'gudeg', 'kopi', 'sate'},
      'belanja': {'shopping', 'oleh oleh', 'oleh-oleh', 'pasar', 'gift'},
      'shopping': {'belanja', 'oleh oleh', 'oleh-oleh', 'pasar', 'gift'},
      'seni': {'art', 'museum', 'galeri', 'batik', 'lukisan'},
      'art': {'seni', 'museum', 'galeri', 'batik', 'lukisan'},
      'aktivitas': {'activity', 'adventure', 'outbound', 'camping', 'hiking'},
      'activity': {'aktivitas', 'adventure', 'outbound', 'camping', 'hiking'},
      'foto': {'photo', 'photospot', 'spot foto', 'instagramable', 'view'},
      'photo': {'foto', 'photospot', 'spot foto', 'instagramable', 'view'},
      'keluarga': {'family', 'edukasi', 'anak', 'rekreasi'},
      'family': {'keluarga', 'edukasi', 'anak', 'rekreasi'},
    };
    return {v, ...?map[v]};
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
