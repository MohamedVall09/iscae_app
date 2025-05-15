import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



class LocalisationScreen extends StatelessWidget {
  const LocalisationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(18.089101, -15.966677), // Université de Nouakchott
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(18.089101, -15.966677), // Université de Nouakchott
              child: const Icon(Icons.location_on, size: 40.0, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
