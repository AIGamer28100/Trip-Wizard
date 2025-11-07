import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/community_repository.dart';
import '../services/auth_service.dart';
import '../models/community_trip.dart';

class CommunityTripDetailScreen extends StatefulWidget {
  final String communityTripId;

  const CommunityTripDetailScreen({super.key, required this.communityTripId});

  @override
  State<CommunityTripDetailScreen> createState() =>
      _CommunityTripDetailScreenState();
}

class _CommunityTripDetailScreenState extends State<CommunityTripDetailScreen> {
  final CommunityRepository _repo = CommunityRepository();
  bool _isEditing = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<CommunityTrip?> _load() async {
    return await _repo.getCommunityTrip(widget.communityTripId);
  }

  Future<void> _save(String communityId) async {
    final updates = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'publishedAt': DateTime.now(),
    };
    try {
      await _repo.updateCommunityTrip(communityId, updates);
      if (context.mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Community Trip')),
      body: FutureBuilder<CommunityTrip?>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final trip = snapshot.data;
          if (trip == null) return const Center(child: Text('Not found'));

          final isAuthor = user != null && user.uid == trip.authorId;

          if (_isEditing) {
            _titleController.text = trip.title;
            _descriptionController.text = trip.description;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing) ...[
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _save(trip.id),
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          if (context.mounted)
                            setState(() => _isEditing = false);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          trip.authorName.isNotEmpty
                              ? trip.authorName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (isAuthor)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            if (context.mounted)
                              setState(() => _isEditing = true);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(trip.description),
                  const SizedBox(height: 12),
                  Text('Destination: ${trip.destination}'),
                  const SizedBox(height: 8),
                  Text(
                    'Dates: ${trip.startDate.toString().split(' ')[0]} - ${trip.endDate.toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 12),
                  Text('Likes: ${trip.likes}'),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
