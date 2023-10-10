import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteListWidget extends StatefulWidget {
  final Function(List<LatLng>) onRouteSelected;
  final Function onSaveRoute;
  RouteListWidget({required this.onRouteSelected, required this.onSaveRoute});
  

  @override
  _RouteListWidgetState createState() => _RouteListWidgetState();
}

class _RouteListWidgetState extends State<RouteListWidget> {
  final TextEditingController _routeNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Routes List'),
        ),
        TextField(
          controller: _routeNameController,
          decoration: InputDecoration(
            labelText: 'Name your Route',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSaveRoute();
          },
          child: Text('Save Current Route'),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('routes').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final routeData = doc.data() as Map<String, dynamic>;
                  final routeName = routeData['name'] ?? 'Unnamed Route';
      
                  final routeAddresses = (routeData['addresses'] as List<dynamic>? ??[]).map((address) {
                   final coords = address.split(','); 
                  try {
                    return LatLng(
                      double.parse(coords[0].trim()), 
                      double.parse(coords[1].trim())
                    );
                  } catch (e) {
                    print("Failed to parse coordinates from address: $address");
                    print("Error: $e");
                    throw e;  // rethrow the exception
                  } 
                  }).toList();

                  return ListTile(
                    title: Text(routeName),
                    onTap: () {
                      widget.onRouteSelected(routeAddresses);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
