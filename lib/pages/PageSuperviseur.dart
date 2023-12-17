import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/pages/AgentsPage.dart';

class PageSuperviseur extends StatefulWidget {
  @override
  _PageSuperviseurState createState() => _PageSuperviseurState();
}

class _PageSuperviseurState extends State<PageSuperviseur> {
  List<Marker> markers = [];
  bool createMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Superviseur'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(51.5, -0.09), // Set the initial location
              zoom: 13.0,
              onTap: createMode ? _handleTap : null,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: markers,
              ),
            ],
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
                      markers.removeLast();
                    });
                  },
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AgentsPage()),
                    );
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
            child: FlutterLogo(),
          ),
        ),
      );
    });
  }
}
