import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/trip.dart';
import '../repositories/booking_repository.dart';
import 'package:logging/logging.dart';

class TripBookingsScreen extends StatefulWidget {
  final Trip trip;

  const TripBookingsScreen({super.key, required this.trip});

  @override
  State<TripBookingsScreen> createState() => _TripBookingsScreenState();
}

class _TripBookingsScreenState extends State<TripBookingsScreen> {
  final BookingRepository _bookingRepo = BookingRepository();
  final _log = Logger('TripBookingsScreen');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingRepo.getTripBookings(widget.trip.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_online_outlined,
                    size: 64,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Add bookings to organize your trip'),
                ],
              ),
            );
          }

          final linkedBookings = bookings
              .where((b) => b.itineraryItemId != null)
              .toList();
          final unlinkedBookings = bookings
              .where((b) => b.itineraryItemId == null)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unlinkedBookings.isNotEmpty) ...[
                Text(
                  'Bookings Not in Itinerary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...unlinkedBookings.map(
                  (booking) => _buildBookingCard(
                    booking,
                    theme,
                    dateFormat,
                    isLinked: false,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (linkedBookings.isNotEmpty) ...[
                Text(
                  'Bookings in Itinerary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...linkedBookings.map(
                  (booking) => _buildBookingCard(
                    booking,
                    theme,
                    dateFormat,
                    isLinked: true,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookingDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Booking'),
      ),
    );
  }

  Widget _buildBookingCard(
    Booking booking,
    ThemeData theme,
    DateFormat dateFormat, {
    required bool isLinked,
  }) {
    IconData icon;
    switch (booking.type.toLowerCase()) {
      case 'flight':
        icon = Icons.flight;
        break;
      case 'hotel':
      case 'accommodation':
        icon = Icons.hotel;
        break;
      case 'restaurant':
        icon = Icons.restaurant;
        break;
      case 'activity':
        icon = Icons.local_activity;
        break;
      default:
        icon = Icons.confirmation_number;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLinked
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          child: Icon(
            icon,
            color: isLinked
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
          ),
        ),
        title: Text(
          booking.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.description),
            const SizedBox(height: 4),
            Text('📅 ${dateFormat.format(booking.startDate)}'),
            if (booking.price != null)
              Text('💰 \$${booking.price!.toStringAsFixed(2)}'),
            if (booking.bookingReference != null)
              Text('Ref: ${booking.bookingReference}'),
          ],
        ),
        trailing: isLinked
            ? IconButton(
                icon: const Icon(Icons.link_off),
                onPressed: () => _unlinkFromItinerary(booking),
                tooltip: 'Remove from itinerary',
              )
            : IconButton(
                icon: const Icon(Icons.add_to_photos),
                onPressed: () => _showAddToItineraryDialog(booking),
                tooltip: 'Add to itinerary',
              ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _showAddToItineraryDialog(Booking booking) async {
    final tripDuration =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    int selectedDay = 1;
    final timeController = TextEditingController(text: '09:00');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add to Itinerary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add "${booking.title}" to your itinerary'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  tripDuration,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Day ${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedDay = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 09:00 AM',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await _bookingRepo.createItineraryItemFromBooking(
          booking,
          selectedDay,
          timeController.text.trim(),
        );

        messenger.showSnackBar(
          const SnackBar(content: Text('Added to itinerary')),
        );
      } catch (e) {
        _log.severe('Failed to add booking to itinerary', e);
        messenger.showSnackBar(SnackBar(content: Text('Failed to add: $e')));
      }
    }

    timeController.dispose();
  }

  Future<void> _unlinkFromItinerary(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Itinerary'),
        content: Text(
          'Remove "${booking.title}" from the itinerary? The booking will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await _bookingRepo.linkBookingToItinerary(booking.id, '');

        messenger.showSnackBar(
          const SnackBar(content: Text('Removed from itinerary')),
        );
      } catch (e) {
        _log.severe('Failed to unlink booking', e);
        messenger.showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
      }
    }
  }

  Future<void> _showAddBookingDialog(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final referenceController = TextEditingController();
    String selectedType = 'hotel';
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                    DropdownMenuItem(value: 'flight', child: Text('Flight')),
                    DropdownMenuItem(
                      value: 'restaurant',
                      child: Text('Restaurant'),
                    ),
                    DropdownMenuItem(
                      value: 'activity',
                      child: Text('Activity'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (optional)',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Booking Reference (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: widget.trip.startDate,
                      lastDate: widget.trip.endDate,
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      try {
        final booking = Booking(
          id: '',
          tripId: widget.trip.id,
          type: selectedType,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          startDate: selectedDate,
          price: priceController.text.isNotEmpty
              ? double.tryParse(priceController.text)
              : null,
          bookingReference: referenceController.text.trim().isEmpty
              ? null
              : referenceController.text.trim(),
          details: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _bookingRepo.createBooking(booking);

        messenger.showSnackBar(const SnackBar(content: Text('Booking added')));
      } catch (e) {
        _log.severe('Failed to add booking', e);
        messenger.showSnackBar(SnackBar(content: Text('Failed to add: $e')));
      }
    }

    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    referenceController.dispose();
  }
}
