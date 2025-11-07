import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/billing.dart';

class StripeService {
  // In production, these would be environment variables
  final String _backendUrl = 'http://localhost:8000'; // Backend URL

  // Create a payment intent for subscription
  Future<String?> createSubscriptionPaymentIntent(
    String userId,
    SubscriptionPlan plan,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/v1/billing/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'plan': plan.name,
          'amount': (plan.monthlyPrice * 100).toInt(), // Convert to cents
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['clientSecret'];
      }
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
    return null;
  }

  // Confirm payment and update subscription
  Future<bool> confirmPayment(
    String userId,
    SubscriptionPlan plan,
    String paymentIntentId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/v1/billing/confirm-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'plan': plan.name,
          'paymentIntentId': paymentIntentId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  // For mobile in-app purchases (iOS/Android)
  // This would integrate with store kit and Google Play Billing
  Future<bool> processInAppPurchase(
    String userId,
    SubscriptionPlan plan,
    String receiptData,
  ) async {
    // In production, validate receipt with Apple/Google servers
    // Then update subscription on backend
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/v1/billing/in-app-purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'plan': plan.name,
          'receiptData': receiptData,
          'platform': 'mobile', // or 'ios'/'android'
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to process in-app purchase: $e');
    }
  }

  // Webhook handler (server-side only)
  // This would be implemented in the backend to handle Stripe webhooks
  // for subscription lifecycle events (created, updated, canceled, etc.)
}
