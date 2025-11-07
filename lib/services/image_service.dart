import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for fetching location images using Unsplash API
/// Unsplash provides free API access with 50 requests/hour
class ImageService {
  // Configuration from ApiConfig
  static String get _unsplashAccessKey => ApiConfig.unsplashAccessKey;
  static String get _pexelsApiKey => ApiConfig.pexelsApiKey;

  static const String _unsplashApiUrl = 'https://api.unsplash.com';
  static const String _pexelsApiUrl = 'https://api.pexels.com/v1';

  /// Check if Unsplash API is configured
  bool get isConfigured => ApiConfig.hasUnsplashKey;

  /// Get a location image URL from Unsplash
  /// Returns null if not configured or no image found
  Future<String?> getLocationImage(String location) async {
    if (!isConfigured || location.trim().isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '$_unsplashApiUrl/search/photos?query=${Uri.encodeComponent(location)}'
        '&per_page=1&orientation=landscape',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Client-ID $_unsplashAccessKey',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final photo = results[0];
          // Return the regular size image URL
          return photo['urls']['regular'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching location image: $e');
      return null;
    }
  }

  /// Get multiple location images for a destination
  /// Useful for gallery views
  Future<List<String>> getLocationImages(
    String location, {
    int count = 5,
  }) async {
    if (!isConfigured || location.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_unsplashApiUrl/search/photos?query=${Uri.encodeComponent(location)}'
        '&per_page=$count&orientation=landscape',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Client-ID $_unsplashAccessKey',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          return results
              .map((photo) => photo['urls']['regular'] as String?)
              .where((url) => url != null)
              .cast<String>()
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching location images: $e');
      return [];
    }
  }

  /// Alternative: Use Pexels API (also free)
  /// Pexels has 200 requests/hour on free tier

  /// Get location image from Pexels as fallback
  Future<String?> getLocationImageFromPexels(String location) async {
    if (!ApiConfig.hasPexelsKey || location.trim().isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '$_pexelsApiUrl/search?query=${Uri.encodeComponent(location)}'
        '&per_page=1&orientation=landscape',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['photos'] as List<dynamic>?;

        if (photos != null && photos.isNotEmpty) {
          return photos[0]['src']['large'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching image from Pexels: $e');
      return null;
    }
  }

  /// Get location image with fallback strategy
  /// Tries Unsplash first, then Pexels, then returns null
  Future<String?> getLocationImageWithFallback(String location) async {
    // Try Unsplash first
    final unsplashUrl = await getLocationImage(location);
    if (unsplashUrl != null) return unsplashUrl;

    // Fallback to Pexels
    final pexelsUrl = await getLocationImageFromPexels(location);
    return pexelsUrl;
  }
}
