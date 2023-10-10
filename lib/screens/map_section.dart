import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '.api_keys.dart'; // Import the API keys file
class MapSection extends StatefulWidget {
  @override
  _MapSectionState createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = LatLng(37.77483, -122.41942);
  TextEditingController searchController = TextEditingController();

  // Make sure to replace 'YOUR_API_KEY' with your actual Places API key.
  final String apiKey = ApiKeys.googleMapsApiKey;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchLocation() async {
    final query = searchController.text;
    final request =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$query&inputtype=textquery&fields=geometry&key=$apiKey';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final LatLng location = LatLng(
        data['candidates'][0]['geometry']['location']['lat'],
        data['candidates'][0]['geometry']['location']['lng'],
      );

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 14),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Section'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search for location',
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
