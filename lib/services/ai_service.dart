import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/billing_service.dart';
import '../services/auth_service.dart';

class AiService {
  final String baseUrl =
      'http://localhost:8000'; // In production, use actual URL
  final BillingService _billingService = BillingService();
  final AuthService _authService = AuthService();

  // Check if user has credits before making AI request
  Future<bool> checkCredits() async {
    return await _billingService.hasCreditsAvailable();
  }

  Future<String> getTripSuggestion(String prompt) async {
    final user = _authService.currentUser;
    if (user == null) {
      return 'Please sign in to use AI features.';
    }

    // Check and consume credit
    final hasCredit = await _billingService.consumeCredit();
    if (!hasCredit) {
      return 'You\'ve used all your AI credits for this month. Upgrade to Pro for more credits!';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/suggest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['suggestion'];
      } else {
        return 'Sorry, I couldn\'t generate a suggestion right now.';
      }
    } catch (e) {
      return 'Error connecting to AI service: ${e.toString()}';
    }
  }

  Future<String> generateItinerary(String destination, int days) async {
    final user = _authService.currentUser;
    if (user == null) {
      return 'Please sign in to use AI features.';
    }

    // Check and consume credit
    final hasCredit = await _billingService.consumeCredit();
    if (!hasCredit) {
      return 'You\'ve used all your AI credits for this month. Upgrade to Pro for more credits!';
    }

    // For now, use mock - in production, add backend endpoint
    await Future.delayed(const Duration(seconds: 2));

    return '''
Day 1: Arrival and exploration
- Morning: Arrive at $destination
- Afternoon: Visit main attractions
- Evening: Dinner at local restaurant

Day 2: Cultural immersion
- Morning: Museum visit
- Afternoon: Local market shopping
- Evening: Cultural show

${days > 2 ? '... (additional days with similar activities)' : ''}
    '''
        .trim();
  }
}
