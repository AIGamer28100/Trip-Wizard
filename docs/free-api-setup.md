# Free API Setup for TripWizards

TripWizards uses completely free APIs for location services and images. No billing or credit card required!

## Location Services - OpenStreetMap Nominatim

**Cost:** 100% FREE forever
**Limits:** Reasonable usage (1 request per second recommended)
**No API Key Required!**

### What it provides

- Location search and autocomplete
- Address geocoding (convert address to coordinates)
- Reverse geocoding (convert coordinates to address)
- Location validation

### Usage Guidelines

- Include a valid User-Agent header (already configured in the app as "TripWizards/1.0")
- Limit to 1 request per second
- For heavy usage, consider setting up your own Nominatim instance

### Documentation

<https://nominatim.org/release-docs/latest/api/Overview/>

---

## Location Images - Unsplash API (Optional)

**Cost:** FREE
**Limits:** 50 requests/hour on free tier
**API Key:** Required (but free to get)

### Setup Instructions

1. **Create an Unsplash Account:**
   - Visit <https://unsplash.com/join>
   - Sign up with your email

2. **Register Your Application:**
   - Go to <https://unsplash.com/oauth/applications>
   - Click "New Application"
   - Accept the API terms
   - Fill in application details:
     - Application name: "TripWizards"
     - Description: "Trip planning app with AI assistance"

3. **Get Your Access Key:**
   - After creating the app, you'll see your "Access Key"
   - Copy this key

4. **Add to Your App:**
   - Open `lib/services/image_service.dart`
   - Replace `YOUR_UNSPLASH_ACCESS_KEY` with your actual key:

     ```dart
     static const String _unsplashAccessKey = 'YOUR_ACCESS_KEY_HERE';
     ```

### Alternative: Pexels API (Backup Option)

If you prefer Pexels or want a fallback:

**Cost:** FREE
**Limits:** 200 requests/hour

1. Visit <https://www.pexels.com/api/>
2. Sign up and get your API key
3. Add to `lib/services/image_service.dart`:

   ```dart
   static const String _pexelsApiKey = 'YOUR_PEXELS_KEY_HERE';
   ```

---

## Running Without Image APIs

If you don't configure image APIs, the app will still work perfectly! It will show:

- Gradient backgrounds on trip cards (Material You colors)
- Travel icons as placeholders
- All other functionality remains intact

---

## Features Using These APIs

### Location Service (Nominatim)

- ✅ Trip destination autocomplete with validation
- ✅ Itinerary location search
- ✅ Stay location search
- ✅ Location validation on all forms

### Image Service (Unsplash/Pexels)

- ✅ Destination images on trip cards (home screen)
- ✅ Destination images on community trip cards
- ✅ Beautiful location photos in trip headers

---

## Benefits of This Approach

### Compared to Google Maps/Places

| Feature              | Google Maps/Places          | Our Solution               |
| -------------------- | --------------------------- | -------------------------- |
| **Cost**             | Requires billing setup      | 100% FREE                  |
| **API Key**          | Required                    | Optional (only for images) |
| **Credit Card**      | Required                    | Not required               |
| **Free Tier**        | Limited ($200/month credit) | Unlimited (reasonable use) |
| **Location Search**  | ✅ Excellent                 | ✅ Very Good                |
| **Image Quality**    | ✅ High                      | ✅ High (Unsplash)          |
| **Setup Complexity** | Medium                      | Very Easy                  |

### Why This Is Better

1. **No Billing Concerns:** Never worry about unexpected charges
2. **Privacy Friendly:** OpenStreetMap doesn't track users like Google
3. **Open Source:** Support open-source mapping projects
4. **Simpler Setup:** No Google Cloud Console configuration needed
5. **Better Images:** Unsplash provides professional photography, often better than Google Street View

---

## Troubleshooting

### Location Search Not Working

- Check internet connection
- Verify you're not making more than 1 request per second
- Check console for error messages

### Images Not Loading

- Verify your Unsplash API key is correctly added
- Check you haven't exceeded 50 requests/hour
- Images are optional - app works fine without them

### Need Higher Limits?

For production apps with heavy usage:

1. **Location Service:**
   - Host your own Nominatim instance
   - Use commercial alternatives like Mapbox (still much cheaper than Google)

2. **Image Service:**
   - Upgrade Unsplash plan ($10/month for 5000 requests/month)
   - Use Pexels as fallback (automatic in the app)
   - Cache images in Firebase Storage after first fetch

---

## Questions?

- OpenStreetMap Nominatim: <https://nominatim.org/>
- Unsplash API Docs: <https://unsplash.com/documentation>
- Pexels API Docs: <https://www.pexels.com/api/documentation/>

---

**Last Updated:** November 2025
