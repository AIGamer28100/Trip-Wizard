import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/organization_repository.dart';
import '../organization/organization_admin_screen.dart';

/// Screen for accepting organization invites
class AcceptInviteScreen extends StatefulWidget {
  final String inviteEmail;
  final String organizationId;

  const AcceptInviteScreen({
    Key? key,
    required this.inviteEmail,
    required this.organizationId,
  }) : super(key: key);

  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInviteValidity();
  }

  Future<void> _checkInviteValidity() async {
    final org = await _orgRepo.getOrganization(widget.organizationId);
    if (org == null) {
      setState(() {
        _errorMessage = 'Organization not found';
      });
      return;
    }

    if (!org.hasPendingInvite(widget.inviteEmail)) {
      setState(() {
        _errorMessage = 'Invite not found or already accepted';
      });
      return;
    }

    // Check if user's email matches invite
    final currentUser = _auth.currentUser;
    if (currentUser?.email?.toLowerCase() != widget.inviteEmail.toLowerCase()) {
      setState(() {
        _errorMessage =
            'Please sign in with ${widget.inviteEmail} to accept this invite';
      });
    }
  }

  Future<void> _acceptInvite() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() => _errorMessage = 'You must be signed in to accept invites');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Add user to organization
      await _orgRepo.addMember(widget.organizationId, currentUser.uid);

      // Remove pending invite
      await _orgRepo.removePendingInvite(
        widget.organizationId,
        widget.inviteEmail,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrganizationAdminScreen(organizationId: widget.organizationId),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error accepting invite: $e';
      });
    }
  }

  Future<void> _declineInvite() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Invite'),
        content: const Text(
          'Are you sure you want to decline this invitation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orgRepo.removePendingInvite(
          widget.organizationId,
          widget.inviteEmail,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _errorMessage = 'Error declining invite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Organization Invite')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Organization Invite')),
      body: FutureBuilder(
        future: _orgRepo.getOrganization(widget.organizationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data;
          if (org == null) {
            return const Center(child: Text('Organization not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mail, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                Text(
                  'You\'re Invited!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve been invited to join',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  org.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(Icons.business, 'Name', org.name),
                        _buildDetailRow(
                          Icons.people,
                          'Members',
                          '${org.memberIds.length}',
                        ),
                        _buildDetailRow(
                          Icons.email,
                          'Invited as',
                          widget.inviteEmail,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptInvite,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Accept Invitation'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isProcessing ? null : _declineInvite,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(height: 24),
                Text(
                  'By accepting, you\'ll gain access to shared trips, pooled credits, and team collaboration features.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
