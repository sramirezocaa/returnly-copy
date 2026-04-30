import 'package:flutter/material.dart';
import 'map_page.dart';

class MeetupPage extends StatefulWidget {
  final String itemTitle;

  const MeetupPage({
    super.key,
    required this.itemTitle,
  });

  @override
  State<MeetupPage> createState() => _MeetupPageState();
}

class _MeetupPageState extends State<MeetupPage> {
  final List<Map<String, dynamic>> policeStations = [
    {
      'name': 'Clinton Police Department',
      'latitude': 32.3415,
      'longitude': -90.3218,
    },
    {
      'name': 'Jackson Police Department',
      'latitude': 32.2988,
      'longitude': -90.1848,
    },
    {
      'name': 'Ridgeland Police Department',
      'latitude': 32.4285,
      'longitude': -90.1320,
    },
    {
      'name': 'Madison Police Department',
      'latitude': 32.4610,
      'longitude': -90.1151,
    },
  ];

  late Map<String, dynamic> selectedStation;

  @override
  void initState() {
    super.initState();
    selectedStation = policeStations[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Meetup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Arrange pickup for: ${widget.itemTitle}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedStation,
              items: policeStations.map((station) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: station,
                  child: Text(station['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStation = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Choose Police Station',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_police_outlined),
                title: Text(selectedStation['name']),
                subtitle: Text(
                  'Lat: ${selectedStation['latitude']}, Lng: ${selectedStation['longitude']}',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        stationName: selectedStation['name'],
                        latitude: selectedStation['latitude'],
                        longitude: selectedStation['longitude'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('View on Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}