/// Configuration constants for external APIs
class ApiConfig {
  // Unsplash API for location images (optional)
  // Get your free API key at: https://unsplash.com/developers
  // Instructions in docs/free-api-setup.md
  static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY';

  // Pexels API as fallback for images (optional)
  // Get your free API key at: https://www.pexels.com/api/
  static const String pexelsApiKey = 'YOUR_PEXELS_API_KEY';

  // Check if image services are configured
  static bool get hasUnsplashKey =>
      unsplashAccessKey != 'YOUR_UNSPLASH_ACCESS_KEY' &&
      unsplashAccessKey.isNotEmpty;

  static bool get hasPexelsKey =>
      pexelsApiKey != 'YOUR_PEXELS_API_KEY' && pexelsApiKey.isNotEmpty;

  static bool get hasAnyImageService => hasUnsplashKey || hasPexelsKey;

  // OpenStreetMap Nominatim (location services)
  // No API key required! Completely free.
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String userAgent = 'TripWizards/1.0';
}
