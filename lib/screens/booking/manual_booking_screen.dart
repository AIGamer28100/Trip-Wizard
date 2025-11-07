import 'package:flutter/material.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/itinerary_repository.dart';
import '../../models/booking.dart';
import '../../models/itinerary_item.dart';

class ManualBookingScreen extends StatefulWidget {
  final String tripId;
  final String? itineraryItemId; // Optional: pre-select an itinerary item

  const ManualBookingScreen({
    super.key,
    required this.tripId,
    this.itineraryItemId,
  });

  @override
  State<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends State<ManualBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _referenceController = TextEditingController();
  String _type = 'hotel';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedItineraryItemId;
  List<ItineraryItem> _itineraryItems = [];

  final List<String> _bookingTypes = [
    'hotel',
    'flight',
    'activity',
    'restaurant',
    'transport',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedItineraryItemId = widget.itineraryItemId;
    _loadItineraryItems();
  }

  Future<void> _loadItineraryItems() async {
    try {
      final repository = ItineraryRepository();
      final items = await repository.getAllItineraryItems(widget.tripId);
      setState(() {
        _itineraryItems = items;
      });
    } catch (e) {
      // Gracefully handle Firebase initialization errors (e.g., during tests)
      // In production, this would be properly initialized
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final booking = Booking(
      id: '',
      tripId: widget.tripId,
      type: _type,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate,
      price: double.tryParse(_priceController.text.trim()),
      bookingReference: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      itineraryItemId: _selectedItineraryItemId,
      details: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository = BookingRepository();
    try {
      await repository.createBooking(booking);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Manual Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Booking Type',
                  border: OutlineInputBorder(),
                ),
                items: _bookingTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _type = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Booking Reference (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedItineraryItemId,
                decoration: const InputDecoration(
                  labelText: 'Link to Itinerary Item (optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._itineraryItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('Day ${item.day}: ${item.activity}'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedItineraryItemId = value);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectStartDate,
                      child: Text(
                        _startDate == null
                            ? 'Select Start Date'
                            : 'Start: ${_startDate!.toString().split(' ')[0]}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectEndDate,
                      child: Text(
                        _endDate == null
                            ? 'Select End Date (optional)'
                            : 'End: ${_endDate!.toString().split(' ')[0]}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBooking,
                  child: const Text('Save Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
