import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization.dart';

/// Widget for configuring organization SSO settings
class SSOSettingsWidget extends StatefulWidget {
  final String organizationId;

  const SSOSettingsWidget({Key? key, required this.organizationId})
    : super(key: key);

  @override
  State<SSOSettingsWidget> createState() => _SSOSettingsWidgetState();
}

class _SSOSettingsWidgetState extends State<SSOSettingsWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _hostedDomainController = TextEditingController();

  bool _ssoEnabled = false;
  String _ssoProvider = 'none';
  String? _hostedDomain;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSSOSettings();
  }

  @override
  void dispose() {
    _hostedDomainController.dispose();
    super.dispose();
  }

  Future<void> _loadSSOSettings() async {
    setState(() => _isLoading = true);

    try {
      final doc = await _firestore
          .collection('organizations')
          .doc(widget.organizationId)
          .get();

      if (doc.exists) {
        final org = Organization.fromFirestore(doc);
        setState(() {
          _ssoEnabled = org.ssoEnabled;
          _ssoProvider = org.ssoProvider;
          _hostedDomain = org.hostedDomain;
          _hostedDomainController.text = _hostedDomain ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading SSO settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSSOSettings() async {
    try {
      final updates = <String, dynamic>{
        'ssoEnabled': _ssoEnabled,
        'ssoProvider': _ssoProvider,
        'hostedDomain': _hostedDomainController.text.trim().isNotEmpty
            ? _hostedDomainController.text.trim()
            : null,
        'updatedAt': DateTime.now(),
      };

      await _firestore
          .collection('organizations')
          .doc(widget.organizationId)
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('SSO settings saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving SSO settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SSO Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Single Sign-On (SSO)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enable SSO to allow organization members to sign in using their corporate identity provider. '
                    'Currently supports Google Workspace. Azure AD/Microsoft 365 support coming soon.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Enable SSO Switch
          Card(
            child: SwitchListTile(
              title: const Text('Enable SSO'),
              subtitle: const Text('Allow members to sign in with SSO'),
              value: _ssoEnabled,
              onChanged: (value) {
                setState(() => _ssoEnabled = value);
              },
            ),
          ),
          const SizedBox(height: 16),

          // SSO Provider Selection
          if (_ssoEnabled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SSO Provider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _ssoProvider,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Provider',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(
                          value: 'google',
                          child: Text('Google Workspace'),
                        ),
                        DropdownMenuItem(
                          value: 'microsoft',
                          child: Text('Azure AD / Microsoft 365 (Coming Soon)'),
                          enabled: false,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _ssoProvider = value ?? 'none');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Google Workspace Settings
          if (_ssoEnabled && _ssoProvider == 'google') ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Workspace Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hostedDomainController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Hosted Domain (Optional)',
                        hintText: 'example.com',
                        helperText:
                            'Restrict sign-in to this Google Workspace domain',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Note: Users will sign in using their @yourcompany.com Google Workspace account.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Azure AD Info (Coming Soon)
          if (_ssoEnabled && _ssoProvider == 'microsoft') ...[
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.construction, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Azure AD / Microsoft 365',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Azure AD SSO integration is coming in a future update. '
                      'This will allow users to sign in with their Microsoft 365 / Azure AD accounts.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSSOSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save SSO Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
