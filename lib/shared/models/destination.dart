import 'package:hive/hive.dart';

class DestinationModel {
  DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.rating,
    required this.ticketPrice,
    required this.openHours,
    this.slug = '',
    this.type = '',
    this.story = '',
    this.localInsight = '',
    this.address = '',
    this.bestTimeToVisit = '',
    this.recommendedDuration = '',
    this.tags = const <String>[],
    this.isFavorite = false,
  });

  final String id;
  final String slug;
  final String name;
  final String type;
  final String category;
  final String description;
  final String story;
  final String localInsight;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double rating;
  final String ticketPrice;
  final String openHours;
  final String bestTimeToVisit;
  final String recommendedDuration;
  final List<String> tags;
  final bool isFavorite;

  DestinationModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? type,
    String? category,
    String? description,
    String? story,
    String? localInsight,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    String? ticketPrice,
    String? openHours,
    String? bestTimeToVisit,
    String? recommendedDuration,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      story: story ?? this.story,
      localInsight: localInsight ?? this.localInsight,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      openHours: openHours ?? this.openHours,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      recommendedDuration: recommendedDuration ?? this.recommendedDuration,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'type': type,
        'category': category,
        'description': description,
        'story': story,
        'localInsight': localInsight,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'rating': rating,
        'ticketPrice': ticketPrice,
        'openHours': openHours,
        'openingHours': openHours,
        'bestTimeToVisit': bestTimeToVisit,
        'recommendedDuration': recommendedDuration,
        'tags': tags,
        'isFavorite': isFavorite,
      };

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      DestinationModel(
        id: json['id'] as String,
        slug: json['slug']?.toString() ?? '',
        name: json['name'] as String,
        type: json['type']?.toString() ?? '',
        category: json['category'] as String,
        description: json['description'] as String,
        story: json['story']?.toString() ?? '',
        localInsight: json['localInsight']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        imageUrl: json['imageUrl']?.toString() ?? '',
        rating: (json['rating'] as num).toDouble(),
        ticketPrice: json['ticketPrice']?.toString() ?? '-',
        openHours: (json['openHours'] ?? json['openingHours'] ?? '-').toString(),
        bestTimeToVisit: json['bestTimeToVisit']?.toString() ?? '',
        recommendedDuration: json['recommendedDuration']?.toString() ?? '',
        tags: _toStringList(json['tags']),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  factory DestinationModel.fromApiJson(Map<String, dynamic> json) =>
      DestinationModel(
        id: json['id'] as String,
        slug: json['slug']?.toString() ?? '',
        name: json['name'] as String? ?? 'Destinasi tanpa nama',
        type: json['type']?.toString() ?? '',
        category: (json['category'] ?? json['type'] ?? 'Wisata').toString(),
        description: json['description'] as String? ?? '',
        story: json['story']?.toString() ?? '',
        localInsight: json['localInsight']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        imageUrl: json['imageUrl']?.toString() ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        ticketPrice: json['ticketPrice']?.toString() ?? '-',
        openHours: json['openingHours']?.toString() ?? json['openHours']?.toString() ?? '-',
        bestTimeToVisit: json['bestTimeToVisit']?.toString() ?? '',
        recommendedDuration: json['recommendedDuration']?.toString() ?? '',
        tags: _toStringList(json['tags']),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  static List<String> _toStringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is String && value.trim().isNotEmpty) {
      return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    return const <String>[];
  }
}

class DestinationModelAdapter extends TypeAdapter<DestinationModel> {
  @override
  final int typeId = 1;

  @override
  DestinationModel read(BinaryReader reader) {
    // Adapter tetap membaca format lama agar aman untuk pengguna yang sudah punya cache Hive.
    return DestinationModel(
      id: reader.readString(),
      name: reader.readString(),
      category: reader.readString(),
      description: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      imageUrl: reader.readString(),
      rating: reader.readDouble(),
      ticketPrice: reader.readString(),
      openHours: reader.readString(),
      isFavorite: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, DestinationModel obj) {
    // Format lama dipertahankan supaya cache lama tidak rusak.
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.category)
      ..writeString(obj.description)
      ..writeDouble(obj.latitude)
      ..writeDouble(obj.longitude)
      ..writeString(obj.imageUrl)
      ..writeDouble(obj.rating)
      ..writeString(obj.ticketPrice)
      ..writeString(obj.openHours)
      ..writeBool(obj.isFavorite);
  }
}
