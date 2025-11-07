import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Google Maps API operations
/// Handles places autocomplete and distance matrix calculations
class MapsService {
  // TODO: Replace with your Google Maps API key
  // Get it from: https://console.cloud.google.com/apis/credentials
  static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  static const String _placesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _distanceMatrixUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json';
  static const String _placeDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Check if the API key is configured
  bool get isConfigured =>
      _apiKey != 'YOUR_GOOGLE_MAPS_API_KEY' && _apiKey.isNotEmpty;

  /// Get place predictions based on input text
  Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty || _apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_placesAutocompleteUrl?input=${Uri.encodeComponent(input)}&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
          return predictions;
        }
      }
      return [];
    } catch (e) {
      print('Error getting place predictions: $e');
      return [];
    }
  }

  /// Get place details including coordinates
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (_apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return null;
    }

    try {
      final url = Uri.parse('$_placeDetailsUrl?place_id=$placeId&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  /// Calculate travel duration and distance between two locations
  Future<TravelInfo?> getTravelInfo({
    required String origin,
    required String destination,
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    if (origin.isEmpty ||
        destination.isEmpty ||
        _apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return null;
    }

    try {
      final url = Uri.parse(
        '$_distanceMatrixUrl?origins=${Uri.encodeComponent(origin)}'
        '&destinations=${Uri.encodeComponent(destination)}'
        '&mode=$travelMode&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            return TravelInfo.fromJson(element);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting travel info: $e');
      return null;
    }
  }
}

/// Place prediction from autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String? secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'],
    );
  }
}

/// Detailed place information
class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'],
      formattedAddress: json['formatted_address'],
      latitude: location['lat'],
      longitude: location['lng'],
    );
  }
}

/// Travel information between two points
class TravelInfo {
  final String distance; // e.g., "5.2 km"
  final int distanceValue; // in meters
  final String duration; // e.g., "15 mins"
  final int durationValue; // in seconds

  TravelInfo({
    required this.distance,
    required this.distanceValue,
    required this.duration,
    required this.durationValue,
  });

  factory TravelInfo.fromJson(Map<String, dynamic> json) {
    return TravelInfo(
      distance: json['distance']['text'],
      distanceValue: json['distance']['value'],
      duration: json['duration']['text'],
      durationValue: json['duration']['value'],
    );
  }

  String get formattedDuration {
    final hours = durationValue ~/ 3600;
    final minutes = (durationValue % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? "$minutes min" : ""}';
    }
    return '$minutes min';
  }
}
