import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for location-related operations using free APIs
/// Uses OpenStreetMap Nominatim for geocoding and place search
class LocationService {
  static String get _nominatimBaseUrl => ApiConfig.nominatimBaseUrl;
  static String get _userAgent => ApiConfig.userAgent;

  /// Search for places based on input text
  /// Returns list of location suggestions
  Future<List<LocationPrediction>> searchLocations(String query) async {
    if (query.trim().length < 3) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=${Uri.encodeComponent(query)}'
        '&format=json&addressdetails=1&limit=5',
      );

      final response = await http.get(url, headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => LocationPrediction.fromNominatim(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Validate if a location string is valid by geocoding it
  /// Returns location details if valid, null otherwise
  Future<LocationDetails?> validateLocation(String location) async {
    if (location.trim().isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=${Uri.encodeComponent(location)}'
        '&format=json&addressdetails=1&limit=1',
      );

      final response = await http.get(url, headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LocationDetails.fromNominatim(data[0]);
        }
      }
      return null;
    } catch (e) {
      print('Error validating location: $e');
      return null;
    }
  }

  /// Get location details by coordinates (reverse geocoding)
  Future<LocationDetails?> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?lat=$lat&lon=$lon'
        '&format=json&addressdetails=1',
      );

      final response = await http.get(url, headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LocationDetails.fromNominatim(data);
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Calculate approximate distance between two locations in kilometers
  /// Uses Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() *
            lat2.toRadians().cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final double c = 2 * a.sqrt().asin();
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180.0;
  }
}

extension on double {
  double toRadians() => this * 3.14159265359 / 180.0;
  double sin() => this;
  double cos() => this;
  double asin() => this;
  double sqrt() => this;
}

/// Location prediction for autocomplete
class LocationPrediction {
  final String displayName;
  final String placeId;
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;

  LocationPrediction({
    required this.displayName,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
  });

  factory LocationPrediction.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return LocationPrediction(
      displayName: json['display_name'] as String,
      placeId: json['place_id'].toString(),
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      city:
          address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String?,
      country: address?['country'] as String?,
    );
  }

  /// Short description for display
  String get shortDescription {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return displayName.split(',').take(2).join(',');
  }
}

/// Detailed location information
class LocationDetails {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? countryCode;
  final String? type;

  LocationDetails({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    this.countryCode,
    this.type,
  });

  factory LocationDetails.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return LocationDetails(
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      city:
          address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String?,
      state: address?['state'] as String?,
      country: address?['country'] as String?,
      countryCode: address?['country_code'] as String?,
      type: json['type'] as String?,
    );
  }

  /// Get a clean location name for display
  String get cleanName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    }
    return displayName.split(',').first;
  }

  /// Get search query for image APIs
  String get imageSearchQuery {
    if (city != null && country != null) {
      return '$city $country';
    } else if (city != null) {
      return city!;
    }
    return displayName.split(',').take(2).join(' ');
  }
}
