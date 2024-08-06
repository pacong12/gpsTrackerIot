import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppBarExample extends StatelessWidget {
  const AppBarExample({super.key});

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
        // backgroundColor: Colors.blue,
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
        // title: Text('AppBar Example'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  SizedBox(height: 10),
                  Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Goggle Maps',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Saat ini',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('2972 Wesheher 07 Santa area'),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kontak:'),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Mesin : ON'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.grey[300],
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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  String address = '';
  String numberPolice = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          username = userData['name'] ?? '';
          address = userData['address'] ?? '';
          numberPolice = userData['licenseNumber'] ?? '';
        });
      }
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempUsername = username;
        String tempAddress = address;
        String tempNumberPolice = numberPolice;

        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Username'),
                  onChanged: (value) => tempUsername = value,
                  controller: TextEditingController(text: username),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(labelText: 'Address'),
                  onChanged: (value) => tempAddress = value,
                  controller: TextEditingController(text: address),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(labelText: 'Number Police'),
                  onChanged: (value) => tempNumberPolice = value,
                  controller: TextEditingController(text: numberPolice),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    'name': tempUsername,
                    'address': tempAddress,
                    'licenseNumber': tempNumberPolice,
                  });
                  _loadUserData();
                  Navigator.of(context).pop();
                }
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
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
              ),
              SizedBox(height: 20),
              ProfileInfoItem(title: 'Username', value: username),
              ProfileInfoItem(title: 'Address', value: address),
              ProfileInfoItem(title: 'Number Police', value: numberPolice),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Edit Profile'),
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Goggle Maps',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Text('Lokasi Saat ini'),
                  ],
                ),
                SizedBox(height: 4),
                Text('2972 Weslehamer 07 Santa area'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('Koordinat'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('Lat: xxxx'),
                    SizedBox(width: 16),
                    Text('Long: xxxx'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final String title;
  final String value;

  const ProfileInfoItem({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility(String field) {
    setState(() {
      switch (field) {
        case 'old':
          _obscureOldPassword = !_obscureOldPassword;
          break;
        case 'new':
          _obscureNewPassword = !_obscureNewPassword;
          break;
        case 'confirm':
          _obscureConfirmPassword = !_obscureConfirmPassword;
          break;
      }
    });
  }

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically send the new password to your backend
      // For this example, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOldPassword,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => _togglePasswordVisibility('old'),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => _togglePasswordVisibility('new'),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => _togglePasswordVisibility('confirm'),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Text('Save New Password'),
                  onPressed: _savePassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
