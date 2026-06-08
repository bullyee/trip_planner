// File: lib/features/poi/screens/poi_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Import the pure UI map components
import '../../../core/widgets/map_view/map_screen.dart';
import '../../../core/widgets/map_view/map_pin_data.dart';
import '../../../core/widgets/map_view/map_notifier.dart';

// Import business logic models and UI components
import '../models/poi_model.dart';
import '../widgets/poi_bottom_sheet.dart';
import '../../roi/widgets/roi_filter_bar.dart';

class PoiMapScreen extends ConsumerWidget {
  const PoiMapScreen({super.key});

  /// Displays the bottom sheet for a specific POI.
  void _showPoiSheet(BuildContext context, WidgetRef ref, PoiModel poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PoiBottomSheet(poi: poi),
    ).whenComplete(
      () => ref.read(mapNotifierProvider.notifier).clearSelection(),
    );
  }

  /// Determines the pin color based on the ROI ID.
  /// Replace this with your actual color mapping logic.
  Color _colorForRoi(String? roiId) {
    if (roiId == null || roiId.isEmpty) return Colors.grey;
    // Example logic: you can restore your original _colorForRoi implementation here.
    return Colors.blue; 
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the map state containing business logic data (PoiModels)
    final mapState = ref.watch(mapNotifierProvider);
    
    // Adapter Pattern: Convert PoiModel (Business) -> MapPinData (UI)
    final pins = mapState.pois.map((p) => MapPinData(
      id: p.id,
      location: LatLng(p.lat, p.lng),
      title: p.name, 
      pinColor: _colorForRoi(p.roiId),
    )).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POI Map'),
        // You can add your AddSpeedDial or other actions here if needed
      ),
      body: Column(
        children: [
          // The filter bar handles business logic filtering
          RoiFilterBar(
            selectedRoiId: mapState.selectedRoiId,
            onChanged: (roiId) =>
                ref.read(mapNotifierProvider.notifier).loadPois(roiId: roiId),
          ),
          
          // Show clear button if a date filter is active
          if (mapState.selectedDate != null)
            Row(
              children: [
                TextButton(
                  onPressed: () => ref.read(mapNotifierProvider.notifier).loadPoisByDate(null),
                  child: const Text('Clear Date Filter'),
                ),
              ],
            ),

          // The pure UI map component
          Expanded(
            child: MapScreen(
              pins: pins,
              selectedPinId: mapState.selectedPoi?.id,
              onPinTapped: (String id) {
                // Find the corresponding POI and show its details
                try {
                  final tappedPoi = mapState.pois.firstWhere((p) => p.id == id);
                  ref.read(mapNotifierProvider.notifier).selectPoi(tappedPoi);
                  _showPoiSheet(context, ref, tappedPoi);
                } catch (e) {
                  // Fallback if the POI is not found
                  debugPrint('POI with id $id not found.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}