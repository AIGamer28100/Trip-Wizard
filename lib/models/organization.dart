import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String id;
  final String name;
  final String adminId;
  final List<String> memberIds;
  final List<String> pendingInvites;
  final List<String> allowedDomains;
  final bool domainAutoJoin;
  final bool ssoEnabled;
  final String ssoProvider; // 'none', 'google', 'microsoft', 'saml'
  final String? hostedDomain; // For Google Workspace
  final int creditPool; // Pooled AI credits for organization
  final Map<String, int>
  memberCreditLimits; // Per-member credit limits (userId: limit)
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.name,
    required this.adminId,
    required this.memberIds,
    this.pendingInvites = const [],
    this.allowedDomains = const [],
    this.domainAutoJoin = false,
    this.ssoEnabled = false,
    this.ssoProvider = 'none',
    this.hostedDomain,
    this.creditPool = 0,
    this.memberCreditLimits = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organization(
      id: doc.id,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      pendingInvites: List<String>.from(data['pendingInvites'] ?? []),
      allowedDomains: List<String>.from(data['allowedDomains'] ?? []),
      domainAutoJoin: data['domainAutoJoin'] ?? false,
      ssoEnabled: data['ssoEnabled'] ?? false,
      ssoProvider: data['ssoProvider'] ?? 'none',
      hostedDomain: data['hostedDomain'],
      creditPool: data['creditPool'] ?? 0,
      memberCreditLimits: Map<String, int>.from(
        data['memberCreditLimits'] ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'adminId': adminId,
      'memberIds': memberIds,
      'pendingInvites': pendingInvites,
      'allowedDomains': allowedDomains,
      'domainAutoJoin': domainAutoJoin,
      'ssoEnabled': ssoEnabled,
      'ssoProvider': ssoProvider,
      'hostedDomain': hostedDomain,
      'creditPool': creditPool,
      'memberCreditLimits': memberCreditLimits,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool isAdmin(String userId) => adminId == userId;
  bool isMember(String userId) => memberIds.contains(userId);
  bool hasPendingInvite(String email) => pendingInvites.contains(email);

  /// Get credit limit for a specific member (0 = no limit)
  int getMemberCreditLimit(String userId) => memberCreditLimits[userId] ?? 0;

  /// Check if member has credit limit set
  bool hasCreditLimit(String userId) => memberCreditLimits.containsKey(userId);
}
