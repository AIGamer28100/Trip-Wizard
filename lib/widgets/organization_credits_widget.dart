import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/organization_credit_usage.dart';
import '../repositories/organization_repository.dart';

/// Widget for managing organization credit pool and viewing usage reports
class OrganizationCreditsWidget extends StatefulWidget {
  final String organizationId;

  const OrganizationCreditsWidget({Key? key, required this.organizationId})
    : super(key: key);

  @override
  State<OrganizationCreditsWidget> createState() =>
      _OrganizationCreditsWidgetState();
}

class _OrganizationCreditsWidgetState extends State<OrganizationCreditsWidget> {
  final OrganizationRepository _orgRepo = OrganizationRepository();
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  Organization? _organization;
  List<MemberCreditSummary> _memberSummaries = [];
  String? _selectedMemberId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _creditsController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final org = await _orgRepo.getOrganization(widget.organizationId);
      final summaries = await _orgRepo.getMemberCreditSummaries(
        widget.organizationId,
      );

      setState(() {
        _organization = org;
        _memberSummaries = summaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _addCredits() async {
    final credits = int.tryParse(_creditsController.text);
    if (credits == null || credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of credits')),
      );
      return;
    }

    try {
      await _orgRepo.addCreditsToPool(widget.organizationId, credits);
      _creditsController.clear();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $credits credits to pool')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding credits: $e')));
      }
    }
  }

  Future<void> _setMemberLimit() async {
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    final limit = int.tryParse(_limitController.text);
    if (limit == null || limit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid credit limit (0 = no limit)'),
        ),
      );
      return;
    }

    try {
      if (limit == 0) {
        await _orgRepo.removeMemberCreditLimit(
          widget.organizationId,
          _selectedMemberId!,
        );
      } else {
        await _orgRepo.setMemberCreditLimit(
          widget.organizationId,
          _selectedMemberId!,
          limit,
        );
      }

      _limitController.clear();
      _selectedMemberId = null;
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              limit == 0
                  ? 'Removed credit limit'
                  : 'Set credit limit to $limit',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error setting limit: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _organization == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Pool Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.account_balance_wallet, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Organization Credit Pool',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_organization!.creditPool} credits',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Shared across all organization members',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add Credits Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Credits to Pool',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _creditsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Number of Credits',
                            hintText: '100',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addCredits,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Member Credit Limits Section
          const Text(
            'Member Credit Limits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    hint: const Text('Select Member'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Member',
                    ),
                    items: _memberSummaries
                        .map(
                          (summary) => DropdownMenuItem(
                            value: summary.userId,
                            child: Text(summary.userName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMemberId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Credit Limit (0 = no limit)',
                            hintText: '1000',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _setMemberLimit,
                        child: const Text('Set Limit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Member Usage Summary
          const Text(
            'Member Usage Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._memberSummaries.map(
            (summary) => _buildMemberSummaryCard(summary),
          ),
          const SizedBox(height: 24),

          // Recent Usage History
          const Text(
            'Recent Credit Usage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildUsageHistoryList(),
        ],
      ),
    );
  }

  Widget _buildMemberSummaryCard(MemberCreditSummary summary) {
    final hasLimit = summary.creditLimit > 0;
    final percentage = summary.getUsagePercentage();
    final isOverLimit = summary.hasExceededLimit();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverLimit ? Colors.red : Colors.blue,
          child: Text(
            summary.userName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(summary.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Credits Used: ${summary.totalCreditsUsed}'),
            if (hasLimit) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (percentage ?? 0) / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverLimit ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Limit: ${summary.creditLimit} (${percentage?.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverLimit ? Colors.red : Colors.grey,
                ),
              ),
            ] else
              const Text('No limit set', style: TextStyle(fontSize: 12)),
            if (summary.lastActivity != null)
              Text(
                'Last active: ${_formatDateTime(summary.lastActivity!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageHistoryList() {
    return StreamBuilder<List<OrganizationCreditUsage>>(
      stream: _orgRepo.getCreditUsageHistory(widget.organizationId, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading history: ${snapshot.error}'),
            ),
          );
        }

        final usageList = snapshot.data ?? [];

        if (usageList.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No credit usage recorded yet'),
            ),
          );
        }

        return Column(
          children: usageList.map((usage) => _buildUsageItem(usage)).toList(),
        );
      },
    );
  }

  Widget _buildUsageItem(OrganizationCreditUsage usage) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.orange),
        title: Text('${usage.userName} - ${usage.action}'),
        subtitle: Text(_formatDateTime(usage.timestamp)),
        trailing: Text(
          '${usage.creditsUsed} credits',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
