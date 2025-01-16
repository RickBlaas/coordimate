import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(event.description),
                    const SizedBox(height: 16),
                    Text(
                      'Date & Time',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Start: ${DateFormat('yyyy-MM-dd HH:mm').format(event.datetimeStart.toLocal())}'),
                    Text('End: ${DateFormat('yyyy-MM-dd HH:mm').format(event.datetimeEnd.toLocal())}'),
                    if (event.location.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Latitude: ${event.location['latitude']}'),
                      Text('Longitude: ${event.location['longitude']}'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}