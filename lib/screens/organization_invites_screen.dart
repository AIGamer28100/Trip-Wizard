import 'package:flutter/material.dart';
import '../repositories/organization_repository.dart';

class OrganizationInvitesScreen extends StatefulWidget {
  final String orgId;

  const OrganizationInvitesScreen({super.key, required this.orgId});

  @override
  State<OrganizationInvitesScreen> createState() =>
      _OrganizationInvitesScreenState();
}

class _OrganizationInvitesScreenState extends State<OrganizationInvitesScreen> {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  List<String> _pendingInvites = [];

  @override
  void initState() {
    super.initState();
    _loadPendingInvites();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingInvites() async {
    try {
      final org = await _orgRepo.getOrganization(widget.orgId);
      if (org != null) {
        setState(() {
          _pendingInvites = org.pendingInvites;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading invites: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Invites')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invite new member section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Team Member',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'colleague@company.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Note: Only users with company domain emails can be invited.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendInvite,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Invite'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pending invites section
            Text(
              'Pending Invites',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (_pendingInvites.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending invites'),
                ),
              )
            else
              ..._pendingInvites.map(
                (email) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.email)),
                    title: Text(email),
                    subtitle: const Text('Pending'),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _cancelInvite(email),
                      tooltip: 'Cancel invite',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Domain restriction check (basic - in production, this would be more sophisticated)
    final domain = email.split('@').last.toLowerCase();
    final allowedDomains = [
      'company.com',
      'acme.com',
      'example.com',
    ]; // In production, this would come from org settings

    if (!allowedDomains.contains(domain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invites are restricted to company domains: ${allowedDomains.join(", ")}',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _orgRepo.addPendingInvite(widget.orgId, email);
      _emailController.clear();
      await _loadPendingInvites(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invite sent to $email')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending invite: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelInvite(String email) async {
    try {
      await _orgRepo.removePendingInvite(widget.orgId, email);
      await _loadPendingInvites(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invite cancelled for $email')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cancelling invite: $e')));
      }
    }
  }
}
