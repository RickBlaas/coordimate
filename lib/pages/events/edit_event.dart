import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // final _locationController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event.title;
    _descriptionController.text = widget.event.description;
    _startDate = widget.event.datetimeStart;
    _endDate = widget.event.datetimeEnd;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = context.pop(true);

    setState(() => _isLoading = true);

    if (mounted) {
      try {
        final updatedEvent = Event(
          id: widget.event.id,
          teamId: widget.event.teamId,
          title: _titleController.text,
          description: _descriptionController.text,
          datetimeStart: _startDate,
          datetimeEnd: _endDate,
          location: widget.event.location, 
          metadata: widget.event.metadata, 
        );

        await EventService().updateEvent(updatedEvent);
        navigator;
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: ValueKey('back_button_${widget.event.id}'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Event', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
      ),
      body: Padding(
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
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date & Time'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_startDate),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('End Date & Time'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_endDate),
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
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
