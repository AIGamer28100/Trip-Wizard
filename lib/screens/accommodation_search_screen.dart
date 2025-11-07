import 'package:flutter/material.dart';

class AccommodationSearchScreen extends StatefulWidget {
  const AccommodationSearchScreen({super.key});

  @override
  State<AccommodationSearchScreen> createState() =>
      _AccommodationSearchScreenState();
}

class _AccommodationSearchScreenState extends State<AccommodationSearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  int _guests = 1;
  String _accommodationType = 'Hotel';

  final List<String> _accommodationTypes = [
    'Hotel',
    'Apartment',
    'Hostel',
    'Resort',
    'Villa',
    'Guesthouse',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _performSearch() {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a location')));
      return;
    }

    // TODO: Implement actual search logic with backend API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching for ${_accommodationType.toLowerCase()}s in ${_locationController.text}...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // For now, show a placeholder results screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AccommodationResultsScreen(
          location: _locationController.text,
          checkIn: _checkInController.text,
          checkOut: _checkOutController.text,
          guests: _guests,
          type: _accommodationType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Accommodations')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'Where are you going?',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Check-in and Check-out dates
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkInController,
                    decoration: const InputDecoration(
                      labelText: 'Check-in',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _checkInController),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _checkOutController,
                    decoration: const InputDecoration(
                      labelText: 'Check-out',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _checkOutController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Guests
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                const Text('Guests:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _guests > 1
                      ? () => setState(() => _guests--)
                      : null,
                ),
                Text(
                  '$_guests',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _guests++),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Accommodation Type
            DropdownButtonFormField<String>(
              initialValue: _accommodationType,
              decoration: const InputDecoration(
                labelText: 'Accommodation Type',
                prefixIcon: Icon(Icons.hotel),
                border: OutlineInputBorder(),
              ),
              items: _accommodationTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _accommodationType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Search button
            ElevatedButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            // Info text
            const Text(
              'Popular Destinations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'Paris',
                    'Tokyo',
                    'New York',
                    'London',
                    'Barcelona',
                    'Dubai',
                  ].map((city) {
                    return ActionChip(
                      avatar: const Icon(Icons.location_city, size: 16),
                      label: Text(city),
                      onPressed: () {
                        _locationController.text = city;
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder results screen
class _AccommodationResultsScreen extends StatelessWidget {
  final String location;
  final String checkIn;
  final String checkOut;
  final int guests;
  final String type;

  const _AccommodationResultsScreen({
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Mock results
    final mockResults = List.generate(
      10,
      (index) => {
        'name': '$type ${index + 1} in $location',
        'price': '\$${(50 + index * 25)}',
        'rating': (3.5 + (index % 3) * 0.5).toStringAsFixed(1),
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text('Results for $location')),
      body: Column(
        children: [
          // Search summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$location • $guests guest${guests > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (checkIn.isNotEmpty && checkOut.isNotEmpty)
                  Text('$checkIn → $checkOut'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockResults.length,
              itemBuilder: (context, index) {
                final result = mockResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.hotel, size: 30),
                    ),
                    title: Text(result['name']!),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(result['rating']!),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          result['price']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('per night', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Viewing details for ${result['name']}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
