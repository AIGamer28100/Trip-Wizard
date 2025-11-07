import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wizards/services/domain_service.dart';

void main() {
  group('DomainService', () {
    group('isEmailDomainAllowed', () {
      test('returns true when email domain is in allowed list', () {
        final service = DomainServiceHelper();
        final allowedDomains = ['example.com', 'test.org'];

        expect(
          service.isEmailDomainAllowed('user@example.com', allowedDomains),
          isTrue,
        );
        expect(
          service.isEmailDomainAllowed('admin@test.org', allowedDomains),
          isTrue,
        );
      });

      test('returns false when email domain is not in allowed list', () {
        final service = DomainServiceHelper();
        final allowedDomains = ['example.com', 'test.org'];

        expect(
          service.isEmailDomainAllowed('user@other.com', allowedDomains),
          isFalse,
        );
        expect(
          service.isEmailDomainAllowed('admin@gmail.com', allowedDomains),
          isFalse,
        );
      });

      test('returns true when allowed list is empty', () {
        final service = DomainServiceHelper();
        expect(service.isEmailDomainAllowed('user@any.com', []), isTrue);
      });

      test('handles invalid email formats', () {
        final service = DomainServiceHelper();
        final allowedDomains = ['example.com'];

        expect(
          service.isEmailDomainAllowed('invalid-email', allowedDomains),
          isFalse,
        );
        expect(
          service.isEmailDomainAllowed('no-at-sign.com', allowedDomains),
          isFalse,
        );
        // @example.com is treated as having domain example.com by the simple parser
        expect(
          service.isEmailDomainAllowed('@example.com', allowedDomains),
          isTrue,
        );
      });

      test('is case-insensitive for domain matching', () {
        final service = DomainServiceHelper();
        final allowedDomains = ['Example.COM', 'TEST.org'];

        expect(
          service.isEmailDomainAllowed('user@example.com', allowedDomains),
          isTrue,
        );
        expect(
          service.isEmailDomainAllowed('user@EXAMPLE.COM', allowedDomains),
          isTrue,
        );
        expect(
          service.isEmailDomainAllowed('user@test.ORG', allowedDomains),
          isTrue,
        );
      });

      test('handles subdomains correctly', () {
        final service = DomainServiceHelper();
        final allowedDomains = ['example.com'];

        // Subdomains should not match
        expect(
          service.isEmailDomainAllowed('user@sub.example.com', allowedDomains),
          isFalse,
        );
      });
    });

    group('extractDomain', () {
      test('extracts domain from valid email', () {
        final service = DomainServiceHelper();
        expect(
          service.extractDomain('user@example.com'),
          equals('example.com'),
        );
        expect(service.extractDomain('admin@test.org'), equals('test.org'));
        expect(
          service.extractDomain('user.name@company.co.uk'),
          equals('company.co.uk'),
        );
      });

      test('returns empty string for invalid email', () {
        final service = DomainServiceHelper();
        expect(service.extractDomain('invalid-email'), isEmpty);
        expect(service.extractDomain('no-at-sign.com'), isEmpty);
        expect(service.extractDomain(''), isEmpty);
      });

      test('handles edge cases', () {
        final service = DomainServiceHelper();
        // @example.com is split as empty part before @ and example.com after @
        expect(service.extractDomain('@example.com'), equals('example.com'));
        expect(service.extractDomain('user@'), isEmpty);
        // user@@example.com splits to 'user@' before first @, but then the @ after trim is empty
        expect(service.extractDomain('user@@example.com'), isEmpty);
      });
    });

    group('isValidDomain', () {
      test('accepts valid domain formats', () {
        final service = DomainServiceHelper();
        expect(service.isValidDomain('example.com'), isTrue);
        expect(service.isValidDomain('test.org'), isTrue);
        expect(service.isValidDomain('sub.domain.example.com'), isTrue);
        expect(service.isValidDomain('company.co.uk'), isTrue);
        expect(service.isValidDomain('test-domain.com'), isTrue);
      });

      test('rejects invalid domain formats', () {
        final service = DomainServiceHelper();
        expect(service.isValidDomain(''), isFalse);
        expect(service.isValidDomain('invalid'), isFalse);
        expect(service.isValidDomain('no spaces.com'), isFalse);
        expect(service.isValidDomain('.com'), isFalse);
        expect(service.isValidDomain('example.'), isFalse);
        expect(service.isValidDomain('-example.com'), isFalse);
        expect(service.isValidDomain('example-.com'), isFalse);
        expect(service.isValidDomain('example..com'), isFalse);
      });
    });

    // Note: Firebase-dependent methods (addAllowedDomain, removeAllowedDomain,
    // setDomainAutoJoin, checkDomainAutoJoin, addUsersByDomain) require
    // Firebase Test SDK or integration tests to properly test
    // They are covered by integration tests in test/integration/domain_integration_test.dart
  });
}
