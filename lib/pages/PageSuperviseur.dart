import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/pages/AgentsPage.dart';
import 'package:flutter_application_1/helpers/DBHelper.dart';
import 'package:flutter_application_1/models/User.dart';
import 'package:flutter_application_1/models/Point.dart';
import 'dart:convert';

class PageSuperviseur extends StatefulWidget {
  @override
  _PageSuperviseurState createState() => _PageSuperviseurState();
}

class _PageSuperviseurState extends State<PageSuperviseur> {
  List<Marker> markers = []; // Markers created by the supervisor
  Future<List<Marker>>?
      dbMarkersFuture; // Future for markers fetched from the database
  bool createMode = false;

  @override
  void initState() {
    super.initState();
    dbMarkersFuture = _loadPoints();
  }

  Future<List<Marker>> _loadPoints() async {
    final points = await DBHelper.instance.readPointsOnline();
    return points.map((point) {
      final latLngData = jsonDecode(point.jsonData);
      final latLng = LatLng(latLngData['latitude'], latLngData['longitude']);
      return Marker(
        width: 50.0,
        height: 50.0,
        point: latLng,
        builder: (ctx) => Container(
          child: Icon(Icons.location_on,
              color: Color.fromARGB(255, 5, 33, 248), size: 50.0),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Superviseur'),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Marker>>(
            future: dbMarkersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                        33.589886, -7.603869), // Set the initial location
                    zoom: 13.0,
                    onTap: createMode ? _handleTap : null,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']),
                    MarkerLayerOptions(
                      markers: [
                        ...snapshot.data!,
                        ...markers
                      ], // Combine the two lists of markers
                    ),
                  ],
                );
              }
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      createMode = true;
                    });
                  },
                  child: Text('Create Point'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      createMode = false;
                    });
                  },
                  child: Text('Valider'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (markers.isNotEmpty) {
                        markers.removeLast();
                      }
                    });
                  },
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final User? agent = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AgentsPage()),
                    );
                    if (agent != null) {
                      for (var marker in markers) {
                        final point = Point(
                          jsonData: jsonEncode({
                            'latitude': marker.point.latitude,
                            'longitude': marker.point.longitude,
                          }),
                          idAgent: agent.id,
                          // Set the other fields as necessary
                        );
                        await DBHelper.instance.createPointOnline(point);
                      }
                      markers.clear(); // Clear the markers
                      createMode = false; // Stop the creation of points
                      dbMarkersFuture =
                          _loadPoints(); // Fetch the updated points from the database
                      setState(
                          () {}); // Rebuild the widget to reflect the changes
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Work has been successfully attributed!')),
                      );
                    }
                  },
                  child: Text('Agents'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      markers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: latlng,
          builder: (ctx) => Container(
            child: Icon(Icons.location_on, color: Colors.red, size: 50.0),
          ),
        ),
      );
    });
  }
}
