import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteSection extends StatefulWidget {
  @override
  _RouteSectionState createState() => _RouteSectionState();
}

class _RouteSectionState extends State<RouteSection> {
  List<LatLng> selectedAddresses = [];
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<Marker> markers = [];
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routes Section'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Address',
            ),
          ),
          ElevatedButton(
            onPressed: searchAddress,
            child: Text('Search'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: onMapCreated,
              markers: Set.from(markers),
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 10.0,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: Icon(Icons.add_location),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> searchAddress() async {
    String baseUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${_searchController.text}&key=YOUR_GOOGLE_MAPS_API_KEY';
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final LatLng latLng = LatLng(
          data['results'][0]['geometry']['location']['lat'],
          data['results'][0]['geometry']['location']['lng'],
        );

        setState(() {
          markers.add(
              Marker(markerId: MarkerId(latLng.toString()), position: latLng));
          selectedLocation = latLng;
        });

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 15.0)),
        );
      }
    }
  }

  void _addAddress() {
    if (selectedLocation != null) {
      setState(() {
        selectedAddresses.add(selectedLocation!);
        markers.add(Marker(
            markerId: MarkerId(selectedLocation.toString()),
            position: selectedLocation!));
      });
    }
  }
}
