import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../repositories/organization_repository.dart';
import '../services/auth_service.dart';
import 'organization_analytics_screen.dart';
import 'organization_invites_screen.dart';

class OrganizationManagementScreen extends StatefulWidget {
  final String organizationId;

  const OrganizationManagementScreen({super.key, required this.organizationId});

  @override
  State<OrganizationManagementScreen> createState() =>
      _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState
    extends State<OrganizationManagementScreen> {
  final OrganizationRepository _orgRepo = OrganizationRepository();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final theme = Theme.of(context);

    return StreamBuilder<Organization?>(
      stream: _orgRepo.getOrganizationStream(widget.organizationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Organization')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Organization')),
            body: const Center(child: Text('Organization not found')),
          );
        }

        final org = snapshot.data!;
        final isAdmin = user?.uid == org.adminId;

        return Scaffold(
          appBar: AppBar(
            title: Text(org.name),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, org),
                  tooltip: 'Edit Organization',
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Organization Info Card
              Card(
                elevation: 2,
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Created ${_formatDate(org.createdAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.people,
                        'Members',
                        '${org.memberIds.length}',
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.mail_outline,
                        'Pending Invites',
                        '${org.pendingInvites.length}',
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.account_balance_wallet,
                        'Credit Pool',
                        '${org.creditPool}',
                        theme,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company Details Section (NEW)
              Card(
                elevation: 2,
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Company Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _showCompanyDetailsDialog(context, org),
                              tooltip: 'Edit Company Details',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (org.metadata.containsKey('website') &&
                          org.metadata['website'] != null)
                        _buildDetailRow(
                          Icons.language,
                          'Website',
                          org.metadata['website'] as String,
                          theme,
                        ),
                      if (org.metadata.containsKey('policies') &&
                          org.metadata['policies'] != null)
                        _buildDetailRow(
                          Icons.policy,
                          'Travel Policies',
                          org.metadata['policies'] as String,
                          theme,
                          maxLines: 5,
                        ),
                      if (!org.metadata.containsKey('website') &&
                          !org.metadata.containsKey('policies'))
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No company details added yet',
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showCompanyDetailsDialog(context, org),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Details'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SSO Configuration
              if (org.ssoEnabled)
                Card(
                  elevation: 2,
                  shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Single Sign-On',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.verified_user,
                          'Provider',
                          org.ssoProvider.toUpperCase(),
                          theme,
                        ),
                        if (org.hostedDomain != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.domain,
                            'Domain',
                            org.hostedDomain!,
                            theme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Quick Actions
              if (isAdmin) ...[
                Text(
                  'Admin Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.person_add,
                  title: 'Manage Invites',
                  subtitle: 'Invite members or manage pending invitations',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrganizationInvitesScreen(
                          orgId: widget.organizationId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.analytics,
                  title: 'View Analytics',
                  subtitle: 'See organization usage and statistics',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrganizationAnalyticsScreen(
                          orgId: widget.organizationId,
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) {
      return 'Today';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else {
      return '${(diff.inDays / 365).floor()} years ago';
    }
  }

  void _showEditDialog(BuildContext context, Organization org) {
    final nameController = TextEditingController(text: org.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Organization Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  await _orgRepo.updateOrganization(org.id, {
                    'name': nameController.text.trim(),
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Organization updated successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }

  void _showCompanyDetailsDialog(BuildContext context, Organization org) {
    final websiteController = TextEditingController(
      text: org.metadata['website'] as String? ?? '',
    );
    final policiesController = TextEditingController(
      text: org.metadata['policies'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Company Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: websiteController,
                decoration: const InputDecoration(
                  labelText: 'Company Website',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: policiesController,
                decoration: const InputDecoration(
                  labelText: 'Travel Policies',
                  hintText:
                      'Enter travel policies, guidelines, or requirements',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.policy),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final metadata = Map<String, dynamic>.from(org.metadata);
                metadata['website'] = websiteController.text.trim();
                metadata['policies'] = policiesController.text.trim();

                await _orgRepo.updateOrganization(org.id, {
                  'metadata': metadata,
                });

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Company details updated successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      websiteController.dispose();
      policiesController.dispose();
    });
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
