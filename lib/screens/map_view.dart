// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lost_found_app/screens/show_item.dart';

// class MapViewPage extends StatefulWidget {
//   const MapViewPage({super.key});

//   @override
//   State<MapViewPage> createState() => _MapViewPageState();
// }

// class _MapViewPageState extends State<MapViewPage> {
//   GoogleMapController? mapController;

//   Set<Marker> markers = {};

//   static const CameraPosition initialPosition = CameraPosition(
//     target: LatLng(28.6139, 77.2090),
//     zoom: 12,
//   );

//   @override
//   void initState() {
//     super.initState();
//     loadMarkers();
//   }

//   Future<void> loadMarkers() async {
//     final snapshot = await FirebaseFirestore.instance.collection('items').get();

//     final Set<Marker> loadedMarkers = {};

//     for (var doc in snapshot.docs) {
//       final data = doc.data();

//       final lat = (data['lat'] ?? 0.0).toDouble();
//       final lng = (data['lng'] ?? 0.0).toDouble();
//       print("LAT: $lat, LNG: $lng");
//       if (lat.abs() > 90 || lng.abs() > 180) continue;

//       loadedMarkers.add(
//         Marker(
//           markerId: MarkerId(doc.id),
//           position: LatLng(lat, lng),

//           // 🔥 CLICK MARKER → OPEN DETAIL
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ItemDetailPage(
//                   title: data['title'] ?? '',
//                   description: data['description'] ?? '',
//                   location: data['location'] ?? '',
//                   imageUrl: data['imageUrl'],
//                   contact: data['contact'] ?? '',
//                   lat: lat,
//                   lng: lng,
//                   timestamp: data['createdAt'],
//                   type: data['type'] ?? '',
//                 ),
//               ),
//             );
//           },

//           infoWindow: InfoWindow(
//             title: data['title'] ?? '',
//             snippet: data['location'] ?? '',
//           ),
//         ),
//       );
//     }
//     print("TOTAL DOCS: ${snapshot.docs.length}");
//     setState(() {
//       markers = loadedMarkers;
//     });
//     if (loadedMarkers.isNotEmpty && mapController != null) {
//       final first = loadedMarkers.first.position;

//       mapController!.animateCamera(CameraUpdate.newLatLngZoom(first, 14));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Map View")),
//       body: GoogleMap(
//         initialCameraPosition: initialPosition,
//         markers: markers,
//         onMapCreated: (controller) {
//           mapController = controller;
//            loadMarkers();
//         },
//       ),
//     );
//   }
// }
