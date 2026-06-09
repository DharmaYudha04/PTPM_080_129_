import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/models/destination.dart';

class LocationService {
  const LocationService();

  static const double jogjaLatitude = -7.7971;
  static const double jogjaLongitude = 110.3708;
  static const Duration _positionTimeout = Duration(seconds: 9);

  LocationSettings get _currentLocationSettings {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        maximumAge: const Duration(minutes: 2),
        timeLimit: _positionTimeout,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: _positionTimeout,
    );
  }

  Future<Position?> getCurrentPositionOrNull() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(_positionTimeout, onTimeout: () => kIsWeb);
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.unableToDetermine,
      );

      if (!kIsWeb && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          _positionTimeout,
          onTimeout: () => LocationPermission.denied,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: _currentLocationSettings,
      ).timeout(_positionTimeout + const Duration(seconds: 1));
    } catch (_) {
      return null;
    }
  }

  Future<ResolvedLocation> resolveCurrentPositionOrJogjaFallback() async {
    final position = await getCurrentPositionOrNull();
    if (position != null) {
      return ResolvedLocation(position: position, isFallback: false);
    }

    return ResolvedLocation(
      position: _jogjaFallbackPosition(),
      isFallback: true,
    );
  }

  Future<Position> getCurrentPositionOrJogjaFallback() async {
    final resolved = await resolveCurrentPositionOrJogjaFallback();
    return resolved.position;
  }

  Position _jogjaFallbackPosition() {
    return Position(
      longitude: jogjaLongitude,
      latitude: jogjaLatitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  double distanceInMeters({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) {
    return Geolocator.distanceBetween(fromLat, fromLon, toLat, toLon);
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    final km = meters / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km';
  }

  List<DestinationModel> sortByDistance({
    required List<DestinationModel> destinations,
    required double userLat,
    required double userLon,
  }) {
    final sorted = [...destinations];

    sorted.sort((a, b) {
      final distanceA = distanceInMeters(
        fromLat: userLat,
        fromLon: userLon,
        toLat: a.latitude,
        toLon: a.longitude,
      );

      final distanceB = distanceInMeters(
        fromLat: userLat,
        fromLon: userLon,
        toLat: b.latitude,
        toLon: b.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return sorted;
  }

  Future<bool> openDestinationMap(DestinationModel destination) {
    return openMap(
      latitude: destination.latitude,
      longitude: destination.longitude,
      label: destination.name,
    );
  }

  Future<bool> openMap({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label);

    final candidates = <Uri>[
      if (!kIsWeb && Platform.isIOS)
        Uri.parse(
          'https://maps.apple.com/?daddr=$latitude,$longitude&q=$encodedLabel',
        ),
      if (!kIsWeb && Platform.isAndroid)
        Uri.parse(
            'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)'),
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      ),
    ];

    for (final uri in candidates) {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return false;
  }
}

class ResolvedLocation {
  const ResolvedLocation({
    required this.position,
    required this.isFallback,
  });

  final Position position;
  final bool isFallback;
}
