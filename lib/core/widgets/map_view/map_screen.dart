import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'map_pin_data.dart';

class MapScreen extends StatefulWidget {
  // Inject the pins to render. The map doesn't know what they are.
  final List<MapPinData> pins;
  
  // Delegate the tap event back to the parent widget.
  final Function(String id)? onPinTapped;
  final String? selectedPinId;

  const MapScreen({
    super.key,
    required this.pins,
    this.selectedPinId,
    this.onPinTapped,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation({bool recenter = false}) async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      // 3. Try to get the cached location first for a fast response
      Position? position = await Geolocator.getLastKnownPosition();

      // 4. If cache is null, request the current position with a timeout using LocationSettings
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (!mounted) return;
      
      final location = LatLng(position.latitude, position.longitude);
      setState(() => _currentLocation = location);
      
      if (recenter) {
        _mapController.move(location, 14);
      }
    } catch (e) {
      // Log the error instead of swallowing it silently
      debugPrint('Error fetching location: $e');
    }
  }

  List<Marker> _buildMarkers(List<MapPinData> pins, String? selectedPinId) {
    return pins
        .map((pin) => Marker(
              point: pin.location,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  // Only delegate the tap event. No business logic here.
                  if (widget.onPinTapped != null) {
                    widget.onPinTapped!(pin.id);
                  }
                },
                child: Icon(
                  pin.iconData ?? Icons.location_pin,
                  // Handle selection highlight visually based on the ID.
                  color: selectedPinId == pin.id 
                      ? Colors.yellow 
                      : (pin.pinColor ?? Colors.red),
                  size: 40,
                ),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Generate markers using the pure UI data passed from the parent
    final markers = _buildMarkers(widget.pins, widget.selectedPinId);

    // Return a Stack directly to layer the map and the floating UI elements
    return Stack(
      children: [
        // Layer 1: The map itself
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(36.2048, 138.2529),
            initialZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.trip_planner',
            ),
            MarkerLayer(
              markers: markers,
              rotate: false,
            ),
            if (_currentLocation != null)
              MarkerLayer(
                rotate: false,
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Layer 2: Floating 'My Location' button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'my_location_btn_map_screen', // Prevent multiple FAB Hero tag conflicts
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: () => _fetchCurrentLocation(recenter: true),
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}