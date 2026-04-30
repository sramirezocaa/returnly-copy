import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final String stationName;
  final double latitude;
  final double longitude;

  const MapPage({
    super.key,
    required this.stationName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  late LatLng stationLocation;

  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    stationLocation = LatLng(widget.latitude, widget.longitude);
  }

  Future<void> getUserLocationAndRoute() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final Position position = await Geolocator.getCurrentPosition();

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        userLocation = currentLocation;
      });

      fitMapToRoute(currentLocation, stationLocation);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoadingLocation = false;
    });
  }

  void fitMapToRoute(LatLng start, LatLng end) {
    final double southWestLat =
        start.latitude < end.latitude ? start.latitude : end.latitude;
    final double southWestLng =
        start.longitude < end.longitude ? start.longitude : end.longitude;

    final double northEastLat =
        start.latitude > end.latitude ? start.latitude : end.latitude;
    final double northEastLng =
        start.longitude > end.longitude ? start.longitude : end.longitude;

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  Future<void> openGoogleMapsDirections() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${stationLocation.latitude},${stationLocation.longitude}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Set<Marker> get markers {
    final Set<Marker> mapMarkers = {
      Marker(
        markerId: const MarkerId('police_station'),
        position: stationLocation,
        infoWindow: InfoWindow(title: widget.stationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (userLocation != null) {
      mapMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return mapMarkers;
  }

  Set<Polyline> get polylines {
    if (userLocation == null) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route_line'),
        points: [
          userLocation!,
          stationLocation,
        ],
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Meetup Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: stationLocation,
                zoom: 14,
              ),
              markers: markers,
              polylines: polylines,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_police_outlined),
                    title: Text(widget.stationName),
                    subtitle: const Text('Safe meetup location'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoadingLocation ? null : getUserLocationAndRoute,
                    icon: isLoadingLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.route_outlined),
                    label: const Text('Show Route in App'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: openGoogleMapsDirections,
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Open in Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}