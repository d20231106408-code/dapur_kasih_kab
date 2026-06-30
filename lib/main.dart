import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_page.dart';
import 'firebase_options.dart';
// import 'forgot_password_page.dart';

// --- NEW: Make main() async and initialize Firebase ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // This connects your app to your Firebase project
  // await Firebase.initializeApp();
  // This tells Firebase to use the specific settings for Web/Android/iOS
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DAPUR KASIH KAB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  String skrinSekarang = 'Home Page';
  bool sudahLogin = false;

  // --- NEW: Controllers to read what the user types ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clean up controllers when the widget is destroyed to save memory
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          skrinSekarang == 'Home Page' ? 'DAPUR KASIH KAB' : skrinSekarang,
        ),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.pink),
              accountName: Text(
                sudahLogin ? 'Pengguna Dapur Kasih' : 'Sila Log Masuk',
              ),
              // Dynamically show the logged-in user's email if available
              accountEmail: Text(
                sudahLogin
                    ? (FirebaseAuth.instance.currentUser?.email ??
                          'user@kab.com')
                    : 'Sistem Booking Dapur KAB',
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.restaurant, color: Colors.pink, size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Colors.pink),
              title: const Text('Home Page'),
              onTap: () {
                setState(() => skrinSekarang = 'Home Page');
                Navigator.pop(context);
              },
            ),

            if (!sudahLogin) ...[
              ListTile(
                leading: const Icon(Icons.login, color: Colors.pink),
                title: const Text('Login / Sign Up'),
                onTap: () {
                  setState(() => skrinSekarang = 'Login / Sign Up');
                  Navigator.pop(context);
                },
              ),
            ],

            if (sudahLogin) ...[
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.pink),
                title: const Text('Dashboard-Slot Page'),
                onTap: () {
                  setState(() => skrinSekarang = 'Dashboard-Slot Page');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.pink),
                title: const Text('Booking History'),
                onTap: () {
                  setState(() => skrinSekarang = 'Booking History');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem, color: Colors.pink),
                title: const Text('Report Damage'),
                onTap: () {
                  setState(() => skrinSekarang = 'Report Damage');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.pink),
                title: const Text('Profile'),
                onTap: () {
                  setState(() => skrinSekarang = 'Profile');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),

                // --- NEW: Real Firebase Logout Logic ---
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  setState(() {
                    sudahLogin = false;
                    skrinSekarang = 'Home Page';
                  });

                  // Clear the text fields so they are empty next time
                  _emailController.clear();
                  _passwordController.clear();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anda telah log keluar.')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: _jagaKandunganSkrin(),
    );
  }

  Widget _jagaKandunganSkrin() {
    switch (skrinSekarang) {
      case 'Home Page':
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.kitchen, size: 100, color: Colors.pink[300]),
                const SizedBox(height: 20),
                const Text(
                  'Selamat Datang ke DAPUR KASIH KAB',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sistem tempahan slot dapur kolej kediaman dengan mudah dan cepat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                if (!sudahLogin)
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => skrinSekarang = 'Login / Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Mula Tempah Sekarang',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );

      case 'Login / Sign Up':
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LOG MASUK AKAUN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 20),

              // --- NEW: Attached Controllers to TextFields ---
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Emel',
                ),
                keyboardType: TextInputType
                    .emailAddress, // Helps pull up the right keyboard
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Kata Laluan',
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                  },
                  child: const Text(
                    'Lupa Kata Laluan? (Forgot Password)',
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size.fromHeight(50),
                ),

                // --- NEW: Real Firebase Login Logic ---
                onPressed: () async {
                  try {
                    // Tell Firebase to try to sign in
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );

                    // If successful, update the screen!
                    setState(() {
                      sudahLogin = true;
                      skrinSekarang = 'Dashboard-Slot Page';
                    });
                  } on FirebaseAuthException catch (e) {
                    // If it fails (wrong password, etc.), show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Ralat semasa log masuk.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Log Masuk',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Belum ada akaun? Daftar (Sign Up) di sini',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        );

      // (The rest of your pages remain exactly the same...)
      case 'Dashboard-Slot Page':
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Slot Pilihan Dapur Hari Ini:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Slot A (8.00 Pagi - 12.00 Tengahari)'),
                subtitle: const Text('Kekosongan: 3 Orang'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BorangBookingPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Booking Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Slot B (2.00 Petang - 6.00 Petang)'),
                subtitle: Text('Kekosongan: Penuh'),
                trailing: ElevatedButton(onPressed: null, child: Text('Penuh')),
              ),
            ),
          ],
        );

      case 'Booking History':
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Sejarah Tempahan Anda:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.hourglass_empty,
                  color: Colors.orange,
                ),
                title: const Text('Slot A - 10 Jun 2026'),
                subtitle: const Text('Status: Pending'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tempahan berjaya di-delete!'),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Slot B - 01 Jun 2026'),
                subtitle: Text('Status: Approved'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('Slot A - 28 Mei 2026'),
                subtitle: Text('Status: Rejected'),
              ),
            ),
          ],
        );

      case 'Report Damage':
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Borang Laporan Kerosakan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jenis Fasiliti (cth: Dapur Gas)',
                ),
              ),
              const SizedBox(height: 15),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Keterangan Kerosakan',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan aduan telah dihantar!'),
                    ),
                  );
                },
                child: const Text(
                  'Hantar Laporan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

      case 'Profile':
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Maklumat Diri:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Card(
                child: ListTile(
                  title: Text('Nama: Ali bin Abu'),
                  subtitle: Text('ID: KAB12345'),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Update Profile',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text(
                  'Change Password',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        );

      default:
        return const Center(child: Text('Skrin tidak ditemui.'));
    }
  }
}

class BorangBookingPage extends StatelessWidget {
  const BorangBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borang Booking Slot'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isi Maklumat Tempahan Dapur:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tarikh Tempahan (DD/MM/YYYY)',
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tujuan Memasak',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tempahan berjaya dihantar! Sila semak History.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Hantar Tempahan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
