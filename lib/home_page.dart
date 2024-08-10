import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'layouts/sidebar.dart';
import 'layouts/locations.dart';
import 'layouts/changePassword.dart';

class AppBarExample extends StatefulWidget {
  const AppBarExample({Key? key}) : super(key: key);

  @override
  _AppBarExampleState createState() => _AppBarExampleState();
}

class _AppBarExampleState extends State<AppBarExample> {
  DatabaseReference? _vehicleRef;
  // MapboxMapController? _mapController;
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  int? timestamp;
  bool isEngineOn = true;
  String? address;
  final String mapboxAccessToken =
      'pk.eyJ1IjoiZ3JpeWEiLCJhIjoiY2x6ajBveWhhMG1qbDJqcjEweWc1NzU3YSJ9.74E0NT1xFxGeMImcixubHQ';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  void _initializeFirebase() {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    _vehicleRef = database.ref('vehicles/vehicle1');
    _vehicleRef!.child('location').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          latitude = data['latitude'];
          longitude = data['longitude'];
          altitude = data['altitude'];
          speed = data['speed'];
          timestamp = data['timestamp'];
        });
        _updateAddress();
      }
    });
    _vehicleRef!.child('command').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          isEngineOn =
              data['type'] == 'START_ENGINE' && data['executed'] == false;
        });
      }
    });
  }

  Future<void> _updateAddress() async {
    if (latitude != null && longitude != null) {
      String newAddress = await _getAddressFromMapbox();
      setState(() {
        address = newAddress;
      });
    }
  }

  Future<String> _getAddressFromMapbox() async {
    if (latitude == null || longitude == null) {
      return "Koordinat tidak tersedia";
    }

    final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$mapboxAccessToken&language=id');

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

  Future<void> _toggleEngine() async {
    final newState = !isEngineOn;
    try {
      await _vehicleRef!.child('command').set({
        'type': newState ? 'START_ENGINE' : 'STOP_ENGINE',
        'executed': newState ? false : true,
      });
      // We don't set the state here because the listener will update it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Engine command sent. Waiting for execution...')),
      );
    } catch (e) {
      print('Error toggling engine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle engine. Please try again.')),
      );
    }
  }

  void _showNotificationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notifikasi'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.power, color: Colors.green),
                  title: Text('Mesin 1 ON'),
                  subtitle: Text('2 menit yang lalu'),
                ),
                ListTile(
                  leading: Icon(Icons.power_off, color: Colors.red),
                  title: Text('Mesin 2 OFF'),
                  subtitle: Text('5 menit yang lalu'),
                ),
                ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text('Peringatan: Suhu Mesin 3 Tinggi'),
                  subtitle: Text('10 menit yang lalu'),
                ),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.red),
                  title: Text('AWAS: Terdeteksi Maling!'),
                  subtitle: Text('1 jam yang lalu'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                _showNotificationModal(context);
              },
            );
          },
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserDrawerHeader(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.key),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(
                    context, '/auth'); // Navigate to auth screen
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 320,
              color: Color.fromARGB(255, 240, 240, 240),
              child: latitude == null || longitude == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(latitude!, longitude!),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude!, longitude!),
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            // SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Saat ini',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(' $address'),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kontak:'),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed:
                                _toggleEngine, // Connect the button to the _toggleEngine function
                            child:
                                Text(isEngineOn ? 'Mesin : ON' : 'Mesin : OFF'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: isEngineOn
                                  ? Colors.green
                                  : const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keamanan:'),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Alarm : ON'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LocationPage()),
                        );
                      },
                      child: Text('Cek Lokasi'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDrawerHeader extends StatefulWidget {
  @override
  _UserDrawerHeaderState createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          userName = userData['name'] ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 201, 212, 221),
      ),
      child: Column(
        children: [
          Text(
            'Hai, $userName',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/user.png'),
          ),
        ],
      ),
    );
  }
}

class EngineControlButton extends StatefulWidget {
  @override
  _EngineControlButtonState createState() => _EngineControlButtonState();
}

class _EngineControlButtonState extends State<EngineControlButton> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isEngineOn = false;

  @override
  void initState() {
    super.initState();
    _listenToEngineState();
  }

  void _listenToEngineState() {
    _database.child('vehicles/vehicle1/command').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _isEngineOn =
              data['type'] == 'START_ENGINE' && data['executed'] == true;
        });
      }
    });
  }

  void _toggleEngine() async {
    final newState = !_isEngineOn;
    try {
      await _database.child('vehicles/vehicle1/command').set({
        'type': newState ? 'START_ENGINE' : 'STOP_ENGINE',
        'executed': false,
      });
      // Note: The state will be updated by the listener when the command is executed
    } catch (e) {
      print('Error toggling engine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle engine. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleEngine,
      child: Text(_isEngineOn ? 'Turn Engine OFF' : 'Turn Engine ON'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEngineOn ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
