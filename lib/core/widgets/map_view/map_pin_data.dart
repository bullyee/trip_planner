import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapPinData {
  final String id;
  final LatLng location;
  final String? title;
  final Color? pinColor;
  final IconData? iconData;

  const MapPinData({
    required this.id,
    required this.location,
    this.title,
    this.pinColor,
    this.iconData,
  });
}