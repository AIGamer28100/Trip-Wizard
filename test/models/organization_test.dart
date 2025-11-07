import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wizards/models/organization.dart';

void main() {
  group('Organization Model', () {
    test('should create organization from valid data', () {
      final now = DateTime.now();
      final org = Organization(
        id: 'org_001',
        name: 'Test Organization',
        adminId: 'admin_123',
        memberIds: ['admin_123', 'member_456'],
        pendingInvites: ['user@example.com'],
        createdAt: now,
        updatedAt: now,
      );

      expect(org.id, 'org_001');
      expect(org.name, 'Test Organization');
      expect(org.adminId, 'admin_123');
      expect(org.memberIds.length, 2);
      expect(org.pendingInvites.length, 1);
    });

    test('isAdmin should return true for admin user', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.isAdmin('admin_123'), true);
      expect(org.isAdmin('other_user'), false);
    });

    test('isMember should return true for member user', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123', 'member_456'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.isMember('admin_123'), true);
      expect(org.isMember('member_456'), true);
      expect(org.isMember('non_member'), false);
    });

    test('hasPendingInvite should return true for invited email', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        pendingInvites: ['invited@example.com'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.hasPendingInvite('invited@example.com'), true);
      expect(org.hasPendingInvite('notinvited@example.com'), false);
    });

    test('toFirestore should serialize correctly', () {
      final now = DateTime.now();
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        pendingInvites: [],
        createdAt: now,
        updatedAt: now,
      );

      final data = org.toFirestore();

      expect(data['name'], 'Test Org');
      expect(data['adminId'], 'admin_123');
      expect(data['memberIds'], ['admin_123']);
      expect(data['pendingInvites'], []);
      expect(data['createdAt'], now);
      expect(data['updatedAt'], now);
    });
  });

  group('Organization Admin Operations', () {
    test('should validate admin permissions before operations', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123', 'member_456'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Only admin should be able to perform certain operations
      expect(org.isAdmin('admin_123'), true);
      expect(org.isAdmin('member_456'), false);
    });

    test('should handle multiple members correctly', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123', 'member_1', 'member_2', 'member_3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.memberIds.length, 4);
      expect(org.isMember('member_1'), true);
      expect(org.isMember('member_2'), true);
      expect(org.isMember('member_3'), true);
    });

    test('should handle empty pending invites', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.pendingInvites.length, 0);
      expect(org.hasPendingInvite('any@example.com'), false);
    });

    test('should handle multiple pending invites', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        pendingInvites: [
          'user1@example.com',
          'user2@example.com',
          'user3@example.com',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.pendingInvites.length, 3);
      expect(org.hasPendingInvite('user1@example.com'), true);
      expect(org.hasPendingInvite('user2@example.com'), true);
      expect(org.hasPendingInvite('user3@example.com'), true);
      expect(org.hasPendingInvite('user4@example.com'), false);
    });
  });

  group('Organization Validation', () {
    test('should require admin to be a member', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Org',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.isMember(org.adminId), true);
    });

    test('should handle organization name correctly', () {
      final org = Organization(
        id: 'org_001',
        name: 'Test Organization With Long Name',
        adminId: 'admin_123',
        memberIds: ['admin_123'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(org.name.length, greaterThan(3));
      expect(org.name, 'Test Organization With Long Name');
    });
  });
}
