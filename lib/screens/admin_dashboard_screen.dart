import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../repositories/organization_repository.dart';
import '../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String orgId;

  const AdminDashboardScreen({super.key, required this.orgId});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  Organization? _organization;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  Future<void> _loadOrganization() async {
    try {
      final org = await _orgRepo.getOrganization(widget.orgId);
      setState(() {
        _organization = org;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading organization: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_organization == null) {
      return const Scaffold(
        body: Center(child: Text('Organization not found')),
      );
    }

    final isAdmin = _organization!.isAdmin(currentUser?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text('${_organization!.name} Dashboard'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _organization!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_organization!.createdAt.toString().split(' ')[0]}',
                    ),
                    Text('Members: ${_organization!.memberIds.length}'),
                    if (_organization!.pendingInvites.isNotEmpty)
                      Text(
                        'Pending invites: ${_organization!.pendingInvites.length}',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Members Section
            Text('Team Members', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Members List
            ..._organization!.memberIds.map(
              (memberId) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    memberId == _organization!.adminId ? 'Admin' : 'Member',
                  ),
                  subtitle: Text(memberId),
                  trailing: memberId == _organization!.adminId
                      ? const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pending Invites Section
            if (_organization!.pendingInvites.isNotEmpty) ...[
              Text(
                'Pending Invites',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ..._organization!.pendingInvites.map(
                (email) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.email)),
                    title: Text(email),
                    subtitle: const Text('Pending'),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _cancelInvite(email),
                    ),
                  ),
                ),
              ),
            ],

            // Admin Actions
            if (isAdmin) ...[
              const SizedBox(height: 24),
              Text(
                'Admin Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('Invite Member'),
                      onTap: () => _showInviteDialog(context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Manage Invites'),
                      onTap: () => _navigateToInvites(context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text('View Analytics'),
                      onTap: () => _navigateToAnalytics(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    // TODO: Implement organization settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Organization Settings'),
        content: const Text('Settings functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'user@company.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _sendInvite(email);
                  // Close dialog after successful invite
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  // Error is already handled in _sendInvite
                  // Keep dialog open so user can try again
                }
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvite(String email) async {
    try {
      await _orgRepo.addPendingInvite(widget.orgId, email);
      await _loadOrganization(); // Refresh data
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
    }
  }

  Future<void> _cancelInvite(String email) async {
    try {
      await _orgRepo.removePendingInvite(widget.orgId, email);
      await _loadOrganization(); // Refresh data
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invite cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cancelling invite: $e')));
      }
    }
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed('/organization-analytics', arguments: widget.orgId);
  }

  void _navigateToInvites(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed('/organization-invites', arguments: widget.orgId);
  }
}
