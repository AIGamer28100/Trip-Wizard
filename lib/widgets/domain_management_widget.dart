import 'package:flutter/material.dart';
import '../../services/domain_service.dart';

/// Widget for managing organization domain restrictions
class DomainManagementWidget extends StatefulWidget {
  final String organizationId;

  const DomainManagementWidget({Key? key, required this.organizationId})
    : super(key: key);

  @override
  State<DomainManagementWidget> createState() => _DomainManagementWidgetState();
}

class _DomainManagementWidgetState extends State<DomainManagementWidget> {
  final DomainService _domainService = DomainService();
  final TextEditingController _domainController = TextEditingController();

  List<String> _allowedDomains = [];
  bool _autoJoinEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDomainSettings();
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _loadDomainSettings() async {
    setState(() => _isLoading = true);

    try {
      final domains = await _domainService.getAllowedDomains(
        widget.organizationId,
      );
      final autoJoin = await _domainService.isDomainAutoJoinEnabled(
        widget.organizationId,
      );

      setState(() {
        _allowedDomains = domains;
        _autoJoinEnabled = autoJoin;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading domain settings: $e')),
        );
      }
    }
  }

  Future<void> _addDomain() async {
    final domain = _domainController.text.trim().toLowerCase();

    if (domain.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a domain')));
      return;
    }

    // Basic domain validation
    if (!RegExp(
      r'^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}$',
    ).hasMatch(domain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid domain (e.g., company.com)'),
        ),
      );
      return;
    }

    if (_allowedDomains.contains(domain)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Domain already added')));
      return;
    }

    try {
      await _domainService.addAllowedDomain(widget.organizationId, domain);
      _domainController.clear();
      await _loadDomainSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Domain $domain added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding domain: $e')));
      }
    }
  }

  Future<void> _removeDomain(String domain) async {
    try {
      await _domainService.removeAllowedDomain(widget.organizationId, domain);
      await _loadDomainSettings();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Domain $domain removed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing domain: $e')));
      }
    }
  }

  Future<void> _toggleAutoJoin(bool enabled) async {
    try {
      await _domainService.setDomainAutoJoin(widget.organizationId, enabled);
      await _loadDomainSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Auto-join enabled for allowed domains'
                  : 'Auto-join disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating auto-join: $e')));
      }
    }
  }

  Future<void> _addExistingUsers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Existing Users'),
        content: const Text(
          'This will add all users with email addresses matching the allowed domains to your organization. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Users'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding users...'),
            ],
          ),
        ),
      );

      try {
        final count = await _domainService.addUsersByDomain(
          widget.organizationId,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added $count users to organization')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding users: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Domain-Based Access',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Control who can join your organization based on email domains',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Auto-join toggle
        Card(
          child: SwitchListTile(
            title: const Text('Enable Domain Auto-Join'),
            subtitle: const Text(
              'Automatically add users with allowed email domains',
            ),
            value: _autoJoinEnabled,
            onChanged: _toggleAutoJoin,
          ),
        ),

        const SizedBox(height: 24),

        // Add domain form
        Text('Allowed Domains', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _domainController,
                decoration: const InputDecoration(
                  hintText: 'company.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.domain),
                ),
                onSubmitted: (_) => _addDomain(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addDomain, child: const Text('Add')),
          ],
        ),

        const SizedBox(height: 16),

        // Domain list
        if (_allowedDomains.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No domains added yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...(_allowedDomains.map(
            (domain) => Card(
              child: ListTile(
                leading: const Icon(Icons.domain),
                title: Text(domain),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDomain(domain),
                ),
              ),
            ),
          )),

        if (_allowedDomains.isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addExistingUsers,
            icon: const Icon(Icons.group_add),
            label: const Text('Add Existing Users with These Domains'),
          ),
        ],

        const SizedBox(height: 24),

        // Info card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Users with email addresses from allowed domains can join your organization ${_autoJoinEnabled ? "automatically" : "via invite"}.',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
