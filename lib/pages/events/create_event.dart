import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';

class CreateEventPage extends StatefulWidget {
  final int teamId;

  const CreateEventPage({super.key, required this.teamId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _eventService = EventService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;

  Map<String, double> _parseLocation(String location) {
    final parts = location.split(',');
    if (parts.length != 2) {
      throw const FormatException('Invalid location format');
    }
    final latitude = double.parse(parts[0].trim());
    final longitude = double.parse(parts[1].trim());
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDateTimePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDateTimePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = context.pop;

    setState(() => _isLoading = true);

    if (mounted) {
      try {
        final event = Event(
          teamId: widget.teamId,
          title: _titleController.text,
          description: _descriptionController.text,
          datetimeStart: _startDate,
          datetimeEnd: _endDate,
        );

        await _eventService.createEvent(event);
        navigator(true);
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title:
            const Text('Create Event', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter an event title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a description'
                      : null,
                ),
                const SizedBox(height: 16),
                // TextFormField(
                //   controller: _locationController,
                //   decoration: const InputDecoration(
                //     labelText: 'Location',
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (value) => (value == null || value.isEmpty)
                //       ? 'Please enter a location'
                //       : null,
                // ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date & Time'),
                  subtitle: Text(
                    _startDate.toLocal().toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectStartDate(context),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('End Date & Time'),
                  subtitle: Text(
                    _endDate.toLocal().toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectEndDate(context),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
