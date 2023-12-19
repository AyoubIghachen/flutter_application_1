import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/helpers/DBHelper.dart';
import 'package:flutter_application_1/models/Point.dart';
import 'dart:convert';

class AgentPage extends StatelessWidget {
  final String agentId;

  const AgentPage({Key? key, required this.agentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Page'),
      ),
      body: FutureBuilder<List<Point>>(
        future: DBHelper.instance.readPointsOnlineByAgentId(agentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final points = snapshot.data!;
            final markers = points.map((point) {
              final latLngData = jsonDecode(point.jsonData);
              final latLng =
                  LatLng(latLngData['latitude'], latLngData['longitude']);
              return Marker(
                width: 50.0,
                height: 50.0,
                point: latLng,
                builder: (ctx) => Container(
                  child: Icon(Icons.location_on, color: Colors.red, size: 50.0),
                ),
              );
            }).toList();
            return FlutterMap(
              options: MapOptions(
                center:
                    LatLng(33.589886, -7.603869), // Set the initial location
                zoom: 13.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(markers: markers),
              ],
            );
          }
        },
      ),
    );
  }
}
