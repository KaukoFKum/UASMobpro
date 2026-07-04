import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  static final LatLng goldenParkLocation = LatLng(
    -6.2635,
    106.6635,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps Golden Park"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: goldenParkLocation,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.goldenpark_smart_resident',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: goldenParkLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 46,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Golden Park Serpong\nLokasi area resident management",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
