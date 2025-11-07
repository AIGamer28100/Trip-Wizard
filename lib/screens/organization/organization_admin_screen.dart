import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/organization.dart';
import '../../repositories/organization_repository.dart';
import '../../widgets/domain_management_widget.dart';
import '../../widgets/sso_settings_widget.dart';
import '../../widgets/organization_credits_widget.dart';

/// Admin dashboard for organization management
class OrganizationAdminScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationAdminScreen({Key? key, required this.organizationId})
    : super(key: key);

  @override
  State<OrganizationAdminScreen> createState() =>
      _OrganizationAdminScreenState();
}

class _OrganizationAdminScreenState extends State<OrganizationAdminScreen>
    with SingleTickerProviderStateMixin {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TabController _tabController;
  Organization? _organization;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadOrganization();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    setState(() => _isLoading = true);

    try {
      final org = await _orgRepo.getOrganization(widget.organizationId);
      final currentUserId = _auth.currentUser?.uid;

      setState(() {
        _organization = org;
        _isAdmin = org?.isAdmin(currentUserId ?? '') ?? false;
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_organization == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Organization Not Found')),
        body: const Center(
          child: Text('Organization not found or you don\'t have access'),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(_organization!.name)),
        body: const Center(
          child: Text('Only administrators can access this dashboard'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_organization!.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.email), text: 'Invites'),
            Tab(icon: Icon(Icons.domain), text: 'Domains'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Credits'),
            Tab(icon: Icon(Icons.security), text: 'SSO'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMembersTab(),
          _buildInvitesTab(),
          _buildDomainsTab(),
          _buildCreditsTab(),
          _buildSSOTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Members',
                  '${_organization!.memberIds.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Invites',
                  '${_organization!.pendingInvites.length}',
                  Icons.mail_outline,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Trips',
                  '0', // TODO: Implement trip count
                  Icons.card_travel,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Credits Used',
                  '0', // TODO: Implement from billing
                  Icons.credit_card,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text('No recent activity'),
                  // TODO: Implement activity feed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _orgRepo.getOrganizationMembers(widget.organizationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return const Center(child: Text('No members yet'));
        }

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isAdmin = member['isAdmin'] as bool;

            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  (member['displayName'] as String)
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),
              title: Text(member['displayName'] as String),
              subtitle: Text(member['email'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdmin)
                    const Chip(
                      label: Text('Admin'),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  if (!isAdmin)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMemberOptions(member),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMemberOptions(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Make Admin'),
              onTap: () {
                Navigator.pop(context);
                _makeAdmin(member['id'] as String);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              title: const Text('Remove from Organization'),
              onTap: () {
                Navigator.pop(context);
                _removeMember(member['id'] as String);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeAdmin(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Admin Rights'),
        content: const Text(
          'Are you sure you want to transfer admin rights to this user? You will lose admin access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orgRepo.transferAdmin(widget.organizationId, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin rights transferred')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _removeMember(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orgRepo.removeMember(widget.organizationId, userId);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Member removed')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Widget _buildInvitesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Send Invite'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _organization!.pendingInvites.length,
            itemBuilder: (context, index) {
              final email = _organization!.pendingInvites[index];
              return ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(email),
                subtitle: const Text('Pending'),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _cancelInvite(email),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'user@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _sendInvite(emailController.text.trim());
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
      await _orgRepo.addPendingInvite(widget.organizationId, email);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invite sent to $email')));
        _loadOrganization(); // Refresh
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
      await _orgRepo.removePendingInvite(widget.organizationId, email);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invite cancelled')));
        _loadOrganization(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildSettingsTab() {
    final nameController = TextEditingController(text: _organization!.name);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organization Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Organization Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => _updateName(nameController.text),
            child: const Text('Save Changes'),
          ),

          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Danger Zone',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _deleteOrganization,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete Organization'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    if (newName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization name cannot be empty')),
      );
      return;
    }

    try {
      await _orgRepo.updateOrganization(widget.organizationId, {
        'name': newName.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization name updated')),
        );
        _loadOrganization(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating name: $e')));
      }
    }
  }

  Future<void> _deleteOrganization() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organization'),
        content: const Text(
          'This action cannot be undone. All organization data, members, and settings will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orgRepo.deleteOrganization(widget.organizationId);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Organization deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting organization: $e')),
          );
        }
      }
    }
  }

  Widget _buildDomainsTab() {
    if (_organization == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DomainManagementWidget(organizationId: widget.organizationId);
  }

  Widget _buildCreditsTab() {
    if (_organization == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return OrganizationCreditsWidget(organizationId: widget.organizationId);
  }

  Widget _buildSSOTab() {
    if (_organization == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SSOSettingsWidget(organizationId: widget.organizationId);
  }
}
