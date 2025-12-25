import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OsmLocationPicker extends StatefulWidget {
  final double? initLat;
  final double? initLng;
  final Function(double lat, double lng) onPicked;

  const OsmLocationPicker({
    Key? key,
    this.initLat,
    this.initLng,
    required this.onPicked,
  }) : super(key: key);

  @override
  State<OsmLocationPicker> createState() => _OsmLocationPickerState();
}

class _OsmLocationPickerState extends State<OsmLocationPicker> {
  late MapController _mapController;
  LatLng? _pickedPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initLat != null && widget.initLng != null) {
      _pickedPosition = LatLng(widget.initLat!, widget.initLng!);
    } else {
      _pickedPosition = const LatLng(16.047079, 108.20623); // Đà Nẵng
    }
  }

  // --- LOGIC MỚI: Lắng nghe thay đổi từ cha để cập nhật Map ---
  @override
  void didUpdateWidget(covariant OsmLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu cha truyền vào tọa độ mới khác với tọa độ cũ
    if (widget.initLat != oldWidget.initLat || widget.initLng != oldWidget.initLng) {
      if (widget.initLat != null && widget.initLng != null) {
        final newPos = LatLng(widget.initLat!, widget.initLng!);
        setState(() {
          _pickedPosition = newPos;
        });
        // Di chuyển camera map đến vị trí mới
        _mapController.move(newPos, 15.0);
      }
    }
  }
  // -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedPosition != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Tọa độ: ${_pickedPosition!.latitude.toStringAsFixed(5)}, ${_pickedPosition!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedPosition ?? const LatLng(16.047079, 108.20623),
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _pickedPosition = point;
                });
                // Gọi callback để báo cho cha biết
                widget.onPicked(point.latitude, point.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_pickedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}