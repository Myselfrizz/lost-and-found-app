import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedLocation;

  static const LatLng initialPosition = LatLng(28.6139, 77.2090);
  GoogleMapController? mapController;
  LatLng? currentCenter;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),

            myLocationEnabled: true,
            myLocationButtonEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },
            onCameraMove: (position) {
              currentCenter = position.target;
            },

            onCameraIdle: () {
              if (currentCenter != null) {
                setState(() {
                  selectedLocation = currentCenter;
                });
              }
            },

            onTap: (LatLng position) {
              setState(() {
                selectedLocation = position;
              });
            },

            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: MarkerId("selected"),
                      position: selectedLocation!,
                    ),
                  },
          ),

          // Confirm button
          Positioned(
            bottom: 20,
            left: 60,
            right: 60,
            child: ElevatedButton(
              onPressed: selectedLocation == null
                  ? null
                  : () {
                      Navigator.pop(context, selectedLocation);
                    },
              child: Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
