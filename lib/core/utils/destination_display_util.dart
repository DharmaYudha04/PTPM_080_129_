import '../../shared/models/destination.dart';

abstract final class DestinationDisplayUtil {
  static String categoryFor(DestinationModel destination) {
    final source = [
      destination.category,
      destination.type,
      ...destination.tags,
      destination.name,
    ].join(' ').toLowerCase();

    if (_hasAny(source, const [
      'kuliner',
      'culinary',
      'food',
      'makanan',
      'masakan',
      'sate',
      'bakmi',
      'gudeg',
      'kopi',
      'warung',
      'resto',
      'restaurant',
      'cafe',
      'kafe',
      'angkringan',
      'jajanan',
    ])) {
      return 'Kuliner';
    }

    if (_hasAny(source, const [
      'candi',
      'keraton',
      'tamansari',
      'taman sari',
      'sejarah',
      'history',
      'heritage',
      'monumen',
      'benteng',
      'makam',
    ])) {
      return 'Sejarah';
    }

    if (_hasAny(source, const [
      'museum',
      'budaya',
      'culture',
      'kampung',
      'batik',
      'tradisi',
      'ramayana',
    ])) {
      return 'Budaya';
    }

    if (_hasAny(source, const [
      'seni',
      'art',
      'galeri',
      'gallery',
      'pertunjukan',
      'sendratari',
      'musik',
    ])) {
      return 'Seni';
    }

    if (_hasAny(source, const [
      'alam',
      'nature',
      'pantai',
      'goa',
      'gua',
      'hutan',
      'bukit',
      'gunung',
      'air terjun',
      'viewpoint',
      'sunrise',
      'sunset',
    ])) {
      return 'Alam';
    }

    if (_hasAny(source, const [
      'belanja',
      'shopping',
      'gift',
      'oleh-oleh',
      'malioboro',
      'pasar',
    ])) {
      return 'Belanja';
    }

    if (_hasAny(source, const [
      'aktivitas',
      'activity',
      'adventure',
      'petualangan',
      'jeep',
      'rafting',
      'workshop',
    ])) {
      return 'Aktivitas';
    }

    if (_hasAny(source, const [
      'foto',
      'photo',
      'spot foto',
      'instagram',
    ])) {
      return 'Foto';
    }

    final fallback = destination.category.trim().isNotEmpty
        ? destination.category.trim()
        : destination.type.trim();
    return fallback.isEmpty ? 'Wisata' : titleCase(fallback);
  }

  static String categoryFromRaw(String category, {String type = '', List<String> tags = const <String>[], String name = ''}) {
    return categoryFor(
      DestinationModel(
        id: '_display',
        name: name,
        category: category,
        description: '',
        latitude: 0,
        longitude: 0,
        imageUrl: '',
        rating: 0,
        ticketPrice: '',
        openHours: '',
        type: type,
        tags: tags,
      ),
    );
  }

  static String compactPrice(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned == '-') return 'Cek berkala';
    final lower = cleaned.toLowerCase();
    if (lower.contains('perlu verifikasi')) return 'Perlu verifikasi';
    if (lower.contains('gratis')) return 'Gratis';
    if (cleaned.length > 36) return cleaned.replaceAll('Mulai sekitar ', 'Mulai ');
    return cleaned;
  }

  static String compactOpenHours(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned == '-') return 'Jam belum tersedia';
    final lower = cleaned.toLowerCase();
    if (lower.contains('perlu verifikasi')) return 'Perlu verifikasi';
    if (lower.contains('mengikuti jadwal')) return 'Sesuai jadwal';
    if (cleaned.length > 28) return '${cleaned.substring(0, 27).trim()}…';
    return cleaned;
  }

  static String titleCase(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[_-]+'), ' ');
    if (cleaned.isEmpty) return cleaned;
    return cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          if (lower.length <= 2 && RegExp(r'^[a-z]+$').hasMatch(lower)) {
            return lower.toUpperCase();
          }
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  static bool _hasAny(String source, List<String> needles) {
    return needles.any(source.contains);
  }
}
