# Google Maps API Setup for TripWizards

This document explains how to set up Google Maps API for location features in TripWizards.

## Features Using Google Maps API

The itinerary screen uses Google Maps Platform APIs to provide:

1. **Place Autocomplete** - Smart location suggestions as users type
2. **Travel Duration Calculation** - Automatic travel time and distance between stay location and activities
3. **Location Validation** - Ensures locations are real places with coordinates

## Required APIs

You need to enable the following APIs in Google Cloud Console:

1. **Places API** - For location autocomplete and place details
2. **Distance Matrix API** - For travel time and distance calculations

## Setup Steps

### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 2. Enable Required APIs

1. Navigate to **APIs & Services** > **Library**
2. Search for and enable:
   - Places API
   - Distance Matrix API

### 3. Create an API Key

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API Key**
3. Copy the generated API key
4. (Recommended) Click **Restrict Key** to secure it:
   - Under **API restrictions**, select "Restrict key"
   - Choose "Places API" and "Distance Matrix API"
   - Under **Application restrictions**, you can restrict by IP, HTTP referrer, etc.

### 4. Configure the App

1. Open `lib/services/maps_service.dart`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### 5. (Optional) Secure the API Key

For production apps, consider:

- Using environment variables
- Implementing backend proxy endpoints
- Setting up API key restrictions in Google Cloud Console

## Pricing Information

⚠️ **Important**: Google Maps APIs have usage costs after free tier

- **Places API**:
  - Autocomplete: $2.83 per 1,000 requests (first 100,000/month free)
  - Place Details: $17 per 1,000 requests

- **Distance Matrix API**:
  - $5 per 1,000 elements (first $200/month free)

### Cost Optimization Tips

1. **Debouncing**: The app already implements 500ms debouncing to reduce API calls
2. **Caching**: Consider caching frequently used place details
3. **Billing Alerts**: Set up billing alerts in Google Cloud Console
4. **API Quotas**: Consider setting daily quotas to prevent unexpected costs

## Testing Without API Key

If you haven't configured an API key yet:

- The app will show a warning message in the itinerary dialog
- Location autocomplete won't work, but users can still manually enter locations
- Travel duration calculation will be skipped
- All other app features work normally

## Troubleshooting

### API Key Not Working

1. Verify the API key is copied correctly (no extra spaces)
2. Check that Places API and Distance Matrix API are enabled
3. If using API restrictions, ensure both APIs are allowed
4. Check Google Cloud Console for quota/billing issues

### "API_KEY_INVALID" Error

- The API key might be restricted. Check restrictions in Google Cloud Console
- Ensure billing is enabled for your Google Cloud project

### No Results from Autocomplete

- Check internet connectivity
- Verify API key has Places API enabled
- Check Google Cloud Console logs for specific errors

## Alternative: Running Without Google Maps

If you prefer not to use Google Maps API, the app still functions:

- Users can manually type location names
- Travel duration won't be calculated automatically
- Location validation is skipped
- All other features (trip creation, itinerary management, etc.) work normally

To completely disable the features:
- Remove the API calls from `maps_service.dart`
- Hide the travel duration display
- Keep the basic text input fields

## Support

For Google Maps API issues:
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Distance Matrix API Documentation](https://developers.google.com/maps/documentation/distance-matrix)
