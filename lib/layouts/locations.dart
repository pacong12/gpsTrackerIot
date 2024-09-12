import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final DatabaseReference _vehicles = FirebaseDatabase.instance.ref();
  double? _latitude;
  double? _longitude;
  final String mapboxAccessToken =
      'pk.eyJ1IjoiZ3JpeWEiLCJhIjoiY2x6ajBveWhhMG1qbDJqcjEweWc1NzU3YSJ9.74E0NT1xFxGeMImcixubHQ';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _listenToLocationChanges();
  }

  void _listenToLocationChanges() {
    _vehicles.child('vehicles/vehicle1/location').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
            _latitude = double.parse(data['latitude'].toString());
            _longitude = double.parse(data['longitude'].toString());
        });
      }
    });
  }

  Future<String> _getAddressFromMapbox() async {
    if (_latitude == null || _longitude == null) {
      return "Koordinat tidak tersedia";
    }

    final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$_longitude,$_latitude.json?access_token=$mapboxAccessToken&language=id');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['features'].isNotEmpty
            ? data['features'][0]['place_name']
            : "Alamat tidak ditemukan";
      } else {
        throw Exception('Failed to load address: ${response.statusCode}');
      }
    } catch (e) {
      return "Gagal mengambil alamat: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi')),
      body: _latitude == null || _longitude == null
          ? const Center(child: CircularProgressIndicator())
          : _buildLocationContent(),
    );
  }

  Widget _buildLocationContent() {
    return FutureBuilder<String>(
      future: _getAddressFromMapbox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Column(
            children: [
              Expanded(child: _buildMap()),
              _buildLocationInfo(snapshot.data ?? "Alamat tidak tersedia"),
            ],
          );
        }
      },
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_latitude!, _longitude!),
            initialZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken',
              additionalOptions: {
                'accessToken': mapboxAccessToken,
                'id': 'mapbox.streets',
              },
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(_latitude!, _longitude!),
                  child: const Icon(
                    Icons.motorcycle,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildZoomButton(
                  Icons.add,
                  () => _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom + 1)),
              const SizedBox(height: 8),
              _buildZoomButton(
                  Icons.remove,
                  () => _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom - 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      mini: true,
      child: Icon(icon),
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  Widget _buildLocationInfo(String address) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on),
              SizedBox(width: 8),
              Text('Lokasi Saat Ini'),
            ],
          ),
          const SizedBox(height: 4),
          Text('Lat: $_latitude, Long: $_longitude'),
          const SizedBox(height: 8),
          Text('Alamat: $address'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
