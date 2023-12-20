import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/helpers/DBHelper.dart';
import 'package:flutter_application_1/models/Point.dart';
import 'package:flutter_application_1/models/Construction.dart';
import 'dart:convert';

class AgentPage extends StatefulWidget {
  final String agentId;

  const AgentPage({Key? key, required this.agentId}) : super(key: key);

  @override
  _AgentPageState createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  List<LatLng> polygonPoints = [];
  bool isDrawing = false;
  String? selectedPointId;

  final _contactController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Page'),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              DBHelper.instance.readPointsOnlineByAgentId(widget.agentId),
              DBHelper.instance
                  .readConstructionsOnlineByAgentId(widget.agentId),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final points = snapshot.data![0] as List<Point>;
                final constructions = snapshot.data![1] as List<Construction>;

                final markers = points.map((point) {
                  final latLngData = jsonDecode(point.jsonData);
                  final latLng =
                      LatLng(latLngData['latitude'], latLngData['longitude']);
                  return Marker(
                    width: 50.0,
                    height: 50.0,
                    point: latLng,
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        if (!isDrawing && point.idConstruction == null) {
                          print('Point ID: ${point.id}');
                          setState(() {
                            selectedPointId = point.id;
                          });
                        }
                      },
                      child: Icon(Icons.location_on,
                          color: point.id == selectedPointId
                              ? Colors.yellow
                              : (point.idConstruction == null
                                  ? Colors.red
                                  : Colors.green),
                          size: 50.0),
                    ),
                  );
                }).toList();

                final constructionPolygons = constructions.map((construction) {
                  final pointsData = jsonDecode(construction.jsonData);
                  final points = (pointsData as List).map((pointData) {
                    return LatLng(pointData['lat'], pointData['lng']);
                  }).toList();
                  return Polygon(
                    points: points,
                    color: Colors.purple
                        .withOpacity(0.3), // Changed color to purple
                  );
                }).toList();

                return FlutterMap(
                  options: MapOptions(
                    center: LatLng(33.589886, -7.603869),
                    zoom: 13.0,
                    onTap: (latLng) {
                      if (isDrawing) {
                        setState(() {
                          polygonPoints.add(latLng);
                        });
                      }
                    },
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']),
                    PolygonLayerOptions(polygons: constructionPolygons),
                    if (isDrawing)
                      PolygonLayerOptions(
                        polygons: [
                          Polygon(
                            points: polygonPoints,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ],
                      ),
                    MarkerLayerOptions(markers: markers),
                  ],
                );
              }
            },
          ),
          if (isDrawing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isDrawing = false;
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Create Construction'),
                      content: Column(
                        children: [
                          TextField(
                            controller: _contactController,
                            decoration: InputDecoration(labelText: 'Contact'),
                          ),
                          TextField(
                            controller: _typeController,
                            decoration: InputDecoration(labelText: 'Type'),
                          ),
                          // Add more fields as necessary
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: _createConstruction,
                          child: Text('Create'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Finish Drawing'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedPointId != null) {
            setState(() {
              isDrawing = true;
              polygonPoints.clear();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select a point first.')),
            );
          }
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  void _createConstruction() async {
    final construction = Construction(
      contact: _contactController.text,
      type: _typeController.text,
      jsonData: jsonEncode(polygonPoints
          .map((e) => {'lat': e.latitude, 'lng': e.longitude})
          .toList()),
      idPoint: selectedPointId!,
      idAgent: widget.agentId,
    );

    // Save the construction object to the database
    await DBHelper.instance.createConstructionOnline(construction);

    // Get ConstrcutionId by PointId
    final constructionId =
        await DBHelper.instance.getConstructionIdByPointId(selectedPointId!);

    // Update the selected point with the ID of the newly created construction
    final point = await DBHelper.instance.readPointOnline(selectedPointId!);
    point.idConstruction = constructionId;
    await DBHelper.instance.updatePointOnline(selectedPointId!, point);

    // Clear the form and polygon points
    _contactController.clear();
    _typeController.clear();
    setState(() {
      polygonPoints.clear();
      selectedPointId = null;
    });

    // Close the dialog
    Navigator.pop(context);
  }
}
