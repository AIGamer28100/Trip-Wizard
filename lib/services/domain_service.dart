import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/organization_repository.dart';

/// Service for handling domain-based organization features
class DomainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user's email domain matches any organization's allowed domains
  /// and automatically add them if domain auto-join is enabled
  Future<String?> checkDomainAutoJoin(String email) async {
    final domain = _extractDomain(email);
    if (domain == null) return null;

    try {
      // Query organizations with this domain in allowedDomains
      final querySnapshot = await _firestore
          .collection('organizations')
          .where('allowedDomains', arrayContains: domain)
          .where('domainAutoJoin', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final orgDoc = querySnapshot.docs.first;
      final orgId = orgDoc.id;
      final userId = _auth.currentUser?.uid;

      if (userId != null) {
        // Check if user is not already a member
        final org = await _orgRepo.getOrganization(orgId);
        if (org != null && !org.isMember(userId)) {
          // Auto-add user to organization
          await _orgRepo.addMember(orgId, userId);
          return orgId;
        }
      }

      return null;
    } catch (e) {
      print('Error checking domain auto-join: $e');
      return null;
    }
  }

  /// Add a domain to organization's allowed domains list
  Future<void> addAllowedDomain(String orgId, String domain) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'allowedDomains': FieldValue.arrayUnion([domain.toLowerCase()]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Remove a domain from organization's allowed domains list
  Future<void> removeAllowedDomain(String orgId, String domain) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'allowedDomains': FieldValue.arrayRemove([domain.toLowerCase()]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Enable or disable domain-based auto-join
  Future<void> setDomainAutoJoin(String orgId, bool enabled) async {
    await _firestore.collection('organizations').doc(orgId).update({
      'domainAutoJoin': enabled,
      'updatedAt': DateTime.now(),
    });
  }

  /// Get allowed domains for an organization
  Future<List<String>> getAllowedDomains(String orgId) async {
    try {
      final doc = await _firestore.collection('organizations').doc(orgId).get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['allowedDomains'] ?? []);
    } catch (e) {
      print('Error getting allowed domains: $e');
      return [];
    }
  }

  /// Check if domain auto-join is enabled
  Future<bool> isDomainAutoJoinEnabled(String orgId) async {
    try {
      final doc = await _firestore.collection('organizations').doc(orgId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      return data['domainAutoJoin'] ?? false;
    } catch (e) {
      print('Error checking domain auto-join status: $e');
      return false;
    }
  }

  /// Validate if an email domain is allowed for an organization
  Future<bool> isEmailDomainAllowedForOrg(String orgId, String email) async {
    final domain = extractDomain(email);
    if (domain.isEmpty) return false;

    final allowedDomains = await getAllowedDomains(orgId);
    return isEmailDomainAllowed(email, allowedDomains);
  }

  /// Check if email matches any allowed domains (public for testing)
  bool isEmailDomainAllowed(String email, List<String> allowedDomains) {
    if (allowedDomains.isEmpty) return true;

    final domain = extractDomain(email);
    if (domain.isEmpty) return false;

    return allowedDomains.any(
      (allowed) => allowed.toLowerCase() == domain.toLowerCase(),
    );
  }

  /// Extract domain from email address (public for testing)
  String extractDomain(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '';
    final domain = parts[1].trim();
    if (domain.isEmpty) return '';
    return domain.toLowerCase();
  }

  /// Validate domain format (public for testing)
  bool isValidDomain(String domain) {
    if (domain.isEmpty) return false;

    // Domain regex: alphanumeric, hyphens, dots
    // Must start and end with alphanumeric
    // Must have at least one dot
    // No consecutive dots
    final domainRegex = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    );

    return domainRegex.hasMatch(domain);
  }

  /// Extract domain from email address (deprecated - use extractDomain)
  String? _extractDomain(String email) {
    final domain = extractDomain(email);
    return domain.isEmpty ? null : domain;
  }

  /// Bulk add users with allowed domains
  Future<int> addUsersByDomain(String orgId) async {
    final allowedDomains = await getAllowedDomains(orgId);
    if (allowedDomains.isEmpty) return 0;

    int addedCount = 0;

    try {
      // Get all users (this is a simplified version - in production, you'd use
      // server-side logic or Cloud Functions for better performance)
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final email = userData['email'] as String?;

        if (email != null) {
          final domain = _extractDomain(email);
          if (domain != null && allowedDomains.contains(domain)) {
            // Check if user is not already a member
            final org = await _orgRepo.getOrganization(orgId);
            if (org != null && !org.isMember(userDoc.id)) {
              await _orgRepo.addMember(orgId, userDoc.id);
              addedCount++;
            }
          }
        }
      }

      return addedCount;
    } catch (e) {
      print('Error adding users by domain: $e');
      return addedCount;
    }
  }
}

/// Helper class for testable domain validation methods without Firebase dependencies
class DomainServiceHelper {
  /// Check if email matches any allowed domains
  bool isEmailDomainAllowed(String email, List<String> allowedDomains) {
    if (allowedDomains.isEmpty) return true;

    final domain = extractDomain(email);
    if (domain.isEmpty) return false;

    return allowedDomains.any(
      (allowed) => allowed.toLowerCase() == domain.toLowerCase(),
    );
  }

  /// Extract domain from email address
  String extractDomain(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '';
    final domain = parts[1].trim();
    if (domain.isEmpty) return '';
    return domain.toLowerCase();
  }

  /// Validate domain format
  bool isValidDomain(String domain) {
    if (domain.isEmpty) return false;

    // Domain regex: alphanumeric, hyphens, dots
    // Must start and end with alphanumeric
    // Must have at least one dot
    // No consecutive dots
    final domainRegex = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    );

    return domainRegex.hasMatch(domain);
  }
}
