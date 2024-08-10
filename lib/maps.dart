// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// Widget build(BuildContext context) {
//   final MapController _mapController = MapController(); // Add a MapController

//   return Scaffold(
//     appBar: AppBar(title: Text('Lokasi')),
//     body: FutureBuilder<String>(
//       future: _getAddressFromMapbox(), // Replace with your function
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text("Error: ${snapshot.error}"));
//         } else {
//           return Column(
//             children: [
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController, // Assign the controller
//                   options: MapOptions(
//                     initialCenter: LatLng(
//                         _latitude!, _longitude!), // Replace with your variables
//                     initialZoom: 18.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken", // Replace with your Mapbox access token
//                       additionalOptions: {
//                         'accessToken': mapboxAccessToken,
//                         'id': 'mapbox.streets',
//                       },
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           width: 80.0,
//                           height: 80.0,
//                           point: LatLng(_latitude!,
//                               _longitude!), // Replace with your variables
//                           child: Container(
//                             child: Icon(
//                               Icons.location_on,
//                               color: Colors.red,
//                               size: 50,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // Add zoom buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       _mapController.move(
//                           _mapController.center, _mapController.zoom + 1);
//                     },
//                     child: Icon(Icons.zoom_in),
//                   ),
//                   SizedBox(width: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       _mapController.move(
//                           _mapController.center, _mapController.zoom - 1);
//                     },
//                     child: Icon(Icons.zoom_out),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         }
//       },
//     ),
//   );
// }
