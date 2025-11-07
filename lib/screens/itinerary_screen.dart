import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/itinerary_repository.dart';
import '../models/itinerary_item.dart';
import '../models/trip.dart';
import '../services/calendar_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../services/maps_service.dart';
import 'dart:async';

class ItineraryScreen extends StatefulWidget {
  final Trip trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final ItineraryRepository _itineraryRepo = ItineraryRepository();
  final CalendarService _calendarService = CalendarService();
  int _selectedDay = 1;
  String? _calendarId;
  bool _isCalendarSyncing = false;

  @override
  void initState() {
    super.initState();
    // Initialize sync service in repository
    final syncService = Provider.of<SyncService>(context, listen: false);
    _itineraryRepo.setSyncService(syncService);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip.title} - Itinerary'),
        actions: [
          // Connectivity indicator
          Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: connectivity.isOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Sync to Google Calendar',
            onPressed: _syncToCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          _buildDaySelector(),
          // Itinerary items for selected day
          Expanded(
            child: StreamBuilder<List<ItineraryItem>>(
              stream: _itineraryRepo.getDayItineraryItems(
                widget.trip.id,
                _selectedDay,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No activities planned for this day'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addItineraryItem,
                          child: const Text('Add Activity'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItineraryItemCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItineraryItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == _selectedDay;

          return Container(
            // width: 50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => setState(() => _selectedDay = day),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor
                    : null,
                foregroundColor: isSelected ? Colors.white : null,
              ),
              child: Text('Day $day'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItineraryItemCard(ItineraryItem item) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outlineVariant.withOpacity(0.4);

    // Calculate end time (default 2 hours duration)
    final timeRange = _getTimeRange(item.time, 2);

    return Card(
      color: surface,
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    item.time,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (timeRange != null) ...[
                    const SizedBox(height: 2),
                    Icon(
                      Icons.arrow_downward,
                      size: 12,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.activity,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.location != null)
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (item.cost != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${item.cost!.toStringAsFixed(2)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (item.aiSuggested) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Suggested',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Menu Button
            PopupMenuButton<String>(
              color: theme.colorScheme.surfaceContainerHigh,
              elevation: 3,
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editItineraryItem(item);
                    break;
                  case 'delete':
                    _deleteItineraryItem(item.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _getTimeRange(String startTime, int durationHours) {
    try {
      // Parse start time (format: "HH:mm")
      final parts = startTime.split(':');
      if (parts.length != 2) return null;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Add duration
      hour += durationHours;
      if (hour >= 24) hour -= 24;

      // Format end time
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return null;
    }
  }

  void _addItineraryItem() {
    showDialog(
      context: context,
      builder: (context) => _ItineraryItemDialog(
        tripId: widget.trip.id,
        day: _selectedDay,
        onSave: (item) async {
          try {
            await _itineraryRepo.addItineraryItem(item);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add activity: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _editItineraryItem(ItineraryItem item) {
    showDialog(
      context: context,
      builder: (context) => _ItineraryItemDialog(
        tripId: widget.trip.id,
        day: _selectedDay,
        existingItem: item,
        onSave: (updatedItem) async {
          try {
            await _itineraryRepo.updateItineraryItem(
              item.id,
              updatedItem.toFirestore(),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update activity: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteItineraryItem(String itemId) async {
    try {
      await _itineraryRepo.deleteItineraryItem(itemId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activity deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete activity: $e')),
        );
      }
    }
  }

  Future<void> _syncToCalendar() async {
    if (_isCalendarSyncing) return;

    setState(() => _isCalendarSyncing = true);

    try {
      // Initialize calendar service if not already done
      if (!_calendarService.isSignedIn) {
        final signedIn = await _calendarService.signIn();
        if (!signedIn) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please sign in to Google to sync calendar'),
              ),
            );
          }
          setState(() => _isCalendarSyncing = false);
          return;
        }
      }

      // Create or get calendar for this trip
      if (_calendarId == null) {
        _calendarId = await _calendarService.createTripCalendar(widget.trip);
        if (_calendarId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create trip calendar')),
            );
          }
          setState(() => _isCalendarSyncing = false);
          return;
        }
      }

      // Get all itinerary items for the trip
      final allItems = await _itineraryRepo
          .getTripItineraryItems(widget.trip.id)
          .first;

      // Sync all items to calendar
      final success = await _calendarService.syncAllItineraryItems(
        _calendarId!,
        allItems,
        widget.trip,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Itinerary synced to Google Calendar successfully!'
                  : 'Some items failed to sync to calendar',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sync calendar: $e')));
      }
    } finally {
      setState(() => _isCalendarSyncing = false);
    }
  }
}

// Dialog for adding/editing itinerary items
class _ItineraryItemDialog extends StatefulWidget {
  final String tripId;
  final int day;
  final ItineraryItem? existingItem;
  final Function(ItineraryItem) onSave;

  const _ItineraryItemDialog({
    required this.tripId,
    required this.day,
    this.existingItem,
    required this.onSave,
  });

  @override
  State<_ItineraryItemDialog> createState() => _ItineraryItemDialogState();
}

class _ItineraryItemDialogState extends State<_ItineraryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mapsService = MapsService();

  late TextEditingController _activityController;
  late TextEditingController _locationController;
  late TextEditingController _stayLocationController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  late TextEditingController _timeController;

  // Location autocomplete
  List<PlacePrediction> _locationPredictions = [];
  List<PlacePrediction> _stayLocationPredictions = [];
  Timer? _locationDebounce;
  Timer? _stayDebounce;

  // Selected places
  String? _selectedPlaceId;
  String? _selectedStayPlaceId;

  // Travel method
  String? _travelMethod;
  final List<String> _travelMethods = [
    'driving',
    'walking',
    'transit',
    'bicycling',
  ];

  // Travel info
  TravelInfo? _travelInfo;
  bool _calculatingTravel = false;

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController(
      text: widget.existingItem?.activity ?? '',
    );
    _locationController = TextEditingController(
      text: widget.existingItem?.location ?? '',
    );
    _stayLocationController = TextEditingController(
      text: widget.existingItem?.stayLocation ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _costController = TextEditingController(
      text: widget.existingItem?.cost?.toString() ?? '',
    );
    _timeController = TextEditingController(
      text: widget.existingItem?.time ?? '09:00',
    );

    _selectedPlaceId = widget.existingItem?.placeId;
    _selectedStayPlaceId = widget.existingItem?.stayPlaceId;
    _travelMethod = widget.existingItem?.travelMethod ?? 'driving';

    // Add listeners for location autocomplete
    _locationController.addListener(_onLocationChanged);
    _stayLocationController.addListener(_onStayLocationChanged);
  }

  @override
  void dispose() {
    _locationDebounce?.cancel();
    _stayDebounce?.cancel();
    _activityController.dispose();
    _locationController.dispose();
    _stayLocationController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    _locationDebounce?.cancel();
    _locationDebounce = Timer(const Duration(milliseconds: 500), () {
      _getLocationPredictions(_locationController.text);
    });
  }

  void _onStayLocationChanged() {
    _stayDebounce?.cancel();
    _stayDebounce = Timer(const Duration(milliseconds: 500), () {
      _getStayLocationPredictions(_stayLocationController.text);
    });
  }

  Future<void> _getLocationPredictions(String input) async {
    if (input.length < 3) {
      setState(() => _locationPredictions = []);
      return;
    }

    final predictions = await _mapsService.getPlacePredictions(input);
    if (mounted) {
      setState(() => _locationPredictions = predictions);
    }
  }

  Future<void> _getStayLocationPredictions(String input) async {
    if (input.length < 3) {
      setState(() => _stayLocationPredictions = []);
      return;
    }

    final predictions = await _mapsService.getPlacePredictions(input);
    if (mounted) {
      setState(() => _stayLocationPredictions = predictions);
    }
  }

  void _selectLocation(PlacePrediction prediction) {
    _locationController.text = prediction.description;
    _selectedPlaceId = prediction.placeId;
    setState(() {
      _locationPredictions = [];
    });
    _calculateTravelInfo();
  }

  void _selectStayLocation(PlacePrediction prediction) {
    _stayLocationController.text = prediction.description;
    _selectedStayPlaceId = prediction.placeId;
    setState(() {
      _stayLocationPredictions = [];
    });
    _calculateTravelInfo();
  }

  Future<void> _calculateTravelInfo() async {
    if (_stayLocationController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _travelMethod == null) {
      return;
    }

    setState(() {
      _calculatingTravel = true;
      _travelInfo = null;
    });

    try {
      final info = await _mapsService.getTravelInfo(
        origin: _stayLocationController.text,
        destination: _locationController.text,
        travelMode: _travelMethod!,
      );

      if (mounted) {
        setState(() {
          _travelInfo = info;
          _calculatingTravel = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _calculatingTravel = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingItem == null ? 'Add Activity' : 'Edit Activity',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _activityController,
                  decoration: const InputDecoration(
                    labelText: 'Activity *',
                    hintText: 'e.g., Visit Eiffel Tower',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an activity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    hintText: 'HH:MM (e.g., 09:00)',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a time';
                    }
                    final timeRegex = RegExp(
                      r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                    );
                    if (!timeRegex.hasMatch(value)) {
                      return 'Please enter time in HH:MM format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Stay Location with autocomplete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _stayLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Where are you staying?',
                        hintText: 'Hotel, Airbnb, etc.',
                        prefixIcon: Icon(Icons.hotel),
                        helperText: 'Where you\'ll be coming from',
                      ),
                    ),
                    if (_stayLocationPredictions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _stayLocationPredictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _stayLocationPredictions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on, size: 20),
                              title: Text(
                                prediction.mainText,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: prediction.secondaryText != null
                                  ? Text(
                                      prediction.secondaryText!,
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                              onTap: () => _selectStayLocation(prediction),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activity Location with autocomplete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Activity Location',
                        hintText: 'e.g., Champ de Mars, Paris',
                        prefixIcon: Icon(Icons.place),
                        helperText: 'Start typing to search places',
                      ),
                    ),
                    if (_locationPredictions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _locationPredictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _locationPredictions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on, size: 20),
                              title: Text(
                                prediction.mainText,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: prediction.secondaryText != null
                                  ? Text(
                                      prediction.secondaryText!,
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                              onTap: () => _selectLocation(prediction),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Travel Method
                DropdownButtonFormField<String>(
                  value: _travelMethod,
                  decoration: const InputDecoration(
                    labelText: 'Travel Method',
                    prefixIcon: Icon(Icons.directions),
                  ),
                  items: _travelMethods.map((method) {
                    IconData icon;
                    switch (method) {
                      case 'driving':
                        icon = Icons.directions_car;
                        break;
                      case 'walking':
                        icon = Icons.directions_walk;
                        break;
                      case 'transit':
                        icon = Icons.directions_transit;
                        break;
                      case 'bicycling':
                        icon = Icons.directions_bike;
                        break;
                      default:
                        icon = Icons.directions;
                    }
                    return DropdownMenuItem(
                      value: method,
                      child: Row(
                        children: [
                          Icon(icon, size: 20),
                          const SizedBox(width: 8),
                          Text(method[0].toUpperCase() + method.substring(1)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _travelMethod = value);
                    _calculateTravelInfo();
                  },
                ),

                // Travel Info Display
                if (_calculatingTravel)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Calculating travel time...'),
                      ],
                    ),
                  )
                else if (_travelInfo != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travel: ${_travelInfo!.formattedDuration}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Distance: ${_travelInfo!.distance}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Additional details...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost (optional)',
                    hintText: 'e.g., 25.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final cost = double.tryParse(value);
                      if (cost == null || cost < 0) {
                        return 'Please enter a valid cost';
                      }
                    }
                    return null;
                  },
                ),

                if (!_mapsService.isConfigured)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Configure Google Maps API key for location features',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveItem, child: const Text('Save')),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final item = ItineraryItem(
        id: widget.existingItem?.id ?? '',
        tripId: widget.tripId,
        day: widget.day,
        time: _timeController.text.trim(),
        activity: _activityController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        placeId: _selectedPlaceId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        cost: _costController.text.trim().isEmpty
            ? null
            : double.parse(_costController.text.trim()),
        aiSuggested: widget.existingItem?.aiSuggested ?? false,
        createdAt: widget.existingItem?.createdAt ?? now,
        updatedAt: now,
        stayLocation: _stayLocationController.text.trim().isEmpty
            ? null
            : _stayLocationController.text.trim(),
        stayPlaceId: _selectedStayPlaceId,
        travelMethod: _travelMethod,
        travelDuration: _travelInfo?.durationValue,
        travelDistance: _travelInfo?.distance,
      );

      widget.onSave(item);
      Navigator.of(context).pop();
    }
  }
}
