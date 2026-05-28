import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/database/database.dart';
import '../../core/widgets/add_speed_dial.dart';
import '../poi/screens/poi_browse_screen.dart';
import 'map_notifier.dart';
import 'poi_bottom_sheet.dart';
import 'roi_filter_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  static const List<Color> _roiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];
  static const Color _orphanRoiColor = Colors.grey;

  Color _colorForRoi(String? roiId) {
    if (roiId == null) return _orphanRoiColor;
    return _roiColors[roiId.hashCode.abs() % _roiColors.length];
  }

  List<Marker> _buildMarkers(List<Poi> pois, Poi? selected) {
    return pois
        .map((p) => Marker(
              point: LatLng(p.lat, p.lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  ref.read(mapNotifierProvider.notifier).selectPoi(p);
                  _showPoiSheet(p);
                },
                child: Icon(
                  Icons.location_pin,
                  color: selected?.id == p.id
                      ? Colors.yellow
                      : _colorForRoi(p.roiId),
                  size: 40,
                ),
              ),
            ))
        .toList();
  }

  void _showPoiSheet(Poi poi) {
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

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final markers = _buildMarkers(mapState.pois, mapState.selectedPoi);

    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RoiFilterBar(
                  selectedRoiId: mapState.selectedRoiId,
                  onChanged: (roiId) =>
                      ref.read(mapNotifierProvider.notifier).loadPois(roiId: roiId),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Filter by date',
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(DateTime.now().year + 20),
                  );
                  if (picked != null) {
                    final dateStr = DateFormat('yyyy-MM-dd').format(picked);
                    ref
                        .read(mapNotifierProvider.notifier)
                        .loadPoisByDate(dateStr);
                  }
                },
              ),
              if (mapState.selectedDate != null)
                TextButton(
                  onPressed: () =>
                      ref.read(mapNotifierProvider.notifier).loadPoisByDate(null),
                  child: const Text('Clear'),
                ),
            ],
          ),
          Expanded(
            child: FlutterMap(
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
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (ctx) => AddSpeedDial(
          actions: buildDefaultAddActions(ctx),
        ),
      ),
    );
  }
}
