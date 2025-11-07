import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Single Sign-On (SSO) authentication
/// Currently supports Google Workspace SSO
class SSOService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Google (Google Workspace SSO)
  ///
  /// For Google Workspace organizations:
  /// - Users can sign in with their organization Google Workspace accounts
  /// - The hosted domain can be restricted to specific organizations
  /// - Domain-based auto-join can be enabled in DomainService
  Future<UserCredential?> signInWithGoogle({String? hostedDomain}) async {
    try {
      // Configure Google Sign-In with optional hosted domain restriction
      // Include calendar scopes for seamless calendar integration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        hostedDomain:
            hostedDomain, // Restrict to specific domain (e.g., 'company.com')
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/calendar',
          'https://www.googleapis.com/auth/calendar.events',
        ],
      );

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  /// Check if user's email domain matches organization's allowed domains
  /// This should be called after successful SSO sign-in to trigger domain-based auto-join
  Future<bool> verifyDomainForSSO(
    String email,
    List<String> allowedDomains,
  ) async {
    if (allowedDomains.isEmpty) return true;

    final domain = _extractDomain(email);
    if (domain == null) return false;

    return allowedDomains.any(
      (allowed) => allowed.toLowerCase() == domain.toLowerCase(),
    );
  }

  /// Extract domain from email address
  String? _extractDomain(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return null;
    return parts[1].toLowerCase();
  }
}

/// Configuration for organization SSO settings
class SSOConfig {
  final String organizationId;
  final bool ssoEnabled;
  final SSOProvider provider;
  final String? hostedDomain; // For Google Workspace
  final Map<String, dynamic>? additionalConfig;

  const SSOConfig({
    required this.organizationId,
    required this.ssoEnabled,
    required this.provider,
    this.hostedDomain,
    this.additionalConfig,
  });

  factory SSOConfig.fromFirestore(Map<String, dynamic> data, String orgId) {
    return SSOConfig(
      organizationId: orgId,
      ssoEnabled: data['ssoEnabled'] ?? false,
      provider: SSOProvider.fromString(data['ssoProvider'] ?? 'none'),
      hostedDomain: data['hostedDomain'],
      additionalConfig: data['ssoConfig'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ssoEnabled': ssoEnabled,
      'ssoProvider': provider.toString().split('.').last,
      'hostedDomain': hostedDomain,
      'ssoConfig': additionalConfig,
      'updatedAt': DateTime.now(),
    };
  }
}

/// Supported SSO providers
enum SSOProvider {
  none,
  google, // Google Workspace
  microsoft, // Azure AD / Microsoft 365
  saml // Generic SAML 2.0
  ;

  static SSOProvider fromString(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return SSOProvider.google;
      case 'microsoft':
      case 'azure':
        return SSOProvider.microsoft;
      case 'saml':
        return SSOProvider.saml;
      default:
        return SSOProvider.none;
    }
  }
}

// NOTE: Azure AD / Microsoft 365 SSO Implementation
//
// For production Azure AD SSO, you would need to:
// 1. Register app in Azure Portal (Azure AD > App registrations)
// 2. Configure redirect URIs for your app
// 3. Add Microsoft Sign-In SDK (there's no official Flutter package yet)
// 4. Use OAuth 2.0 flow with Azure AD endpoints
//
// Alternative approaches:
// - Use firebase_ui_oauth with Microsoft provider
// - Implement custom OAuth 2.0 flow with http package
// - Use WebView for Azure AD sign-in flow
// - Wait for official Microsoft Auth SDK for Flutter
//
// Example Azure AD OAuth endpoints:
// - Authorization: https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize
// - Token: https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token
//
// This is marked as a TODO for Phase 5 completion
