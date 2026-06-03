
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'landing_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/settings_page.dart';
import 'package:shieldx_app/screens/device_page.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  
  runApp(const ShieldXApp());
}

class ShieldXApp extends StatelessWidget {
  const ShieldXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       routes: {
    '/login': (context) => const LoginScreen(),
    '/signup': (context) => const SignupScreen(),
  },
      title: 'ShieldX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {

  int _currentIndex = 0;
  late AnimationController _bubbleController;
  late Animation<double> _slideAnim;
  double _bubbleFromX = 0;
  double _bubbleToX = 0;
  double _currentBubbleX = 0;
  bool _initialized = false;

  final List<Widget> screens = [
    HomePage(),
    DevicePage(),
    MapPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOutCubic,
    );
    _bubbleController.addListener(() {
      setState(() {
        _currentBubbleX =
            _bubbleFromX + (_bubbleToX - _bubbleFromX) * _slideAnim.value;
      });
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  double _getTargetX(int index, double navWidth) {
    final double itemWidth = navWidth / 4;
    return itemWidth * index + itemWidth / 2 - 30;
  }

  void _onNavTap(int index, double navWidth) {
    if (index == _currentIndex) return;

    // 🔥 START from wherever bubble currently IS (mid-animation safe)
    _bubbleFromX = _currentBubbleX;
    _bubbleToX = _getTargetX(index, navWidth);

    setState(() => _currentIndex = index);
    _bubbleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final double navWidth = MediaQuery.of(context).size.width - 40;

    // Initialize bubble position on first build
    if (!_initialized) {
      _currentBubbleX = _getTargetX(0, navWidth);
      _bubbleFromX = _currentBubbleX;
      _bubbleToX = _currentBubbleX;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.8,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
              ),
              child: Stack(
                children: [

                  // 🔥 SLIDING BUBBLE — tracks real pixel position
                  Positioned(
                    left: _currentBubbleX,
                    top: 10,
                    child: Container(
                      width: 60,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                             Colors.white.withOpacity(0.18),
                             Colors.white.withOpacity(0.06),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.12),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔥 ICONS ON TOP OF BUBBLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home_rounded, 0, navWidth),
                      _navItem(Icons.airplay, 1, navWidth),
                      _navItem(Icons.location_on_rounded, 2, navWidth),
                      _navItem(Icons.settings_rounded, 3, navWidth),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, double navWidth) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index, navWidth),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              scale: isActive ? 1.15 : 1.0,
              child: Icon(
                icon,
                color: isActive
                   ? Colors.white
                   : Colors.white.withOpacity(0.35),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.7),
borderRadius: BorderRadius.circular(2),
boxShadow: [
  BoxShadow(
    color: Colors.white.withOpacity(0.4),
    blurRadius: 6,
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
bool alertSent = false;
  final dbRef = FirebaseDatabase.instance.ref("deviceData");

  int bpm = 0;
  double lux = 0;
  int ledBrightness = 0;
  double latitude = 0;
  double longitude = 0;
  bool accident = false;
  bool previousAccident = false;

  String userName = "User";
  String userInitials = "U";
  int contactCount = 0;

  String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good Morning";
  if (hour < 17) return "Good Afternoon";
  return "Good Evening";
}
Future<void> loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // ✅ CORRECT PATH (IMPORTANT FIX)
  final snapshot = await FirebaseDatabase.instance
      .ref("users/${user.uid}/profile")
      .get();

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    setState(() {
      userName = data['fullName'] ?? user.email!.split('@')[0];

      List parts = userName.split(" ");
      userInitials =
          parts.length > 1 ? parts[0][0] + parts[1][0] : parts[0][0];
    });
  }

  // ✅ CONTACT COUNT (already correct)
  final contactsSnap = await FirebaseDatabase.instance
      .ref("users/${user.uid}/contacts")
      .get();

  if (contactsSnap.exists) {
    setState(() {
      contactCount = (contactsSnap.value as Map).length;
    });
  }
}
 
 // 🔥 ADD THIS AT TOP OF FILE

Future<void> sendSMS(String phone, String message) async {

  var response = await http.post(
    Uri.parse("https://www.fast2sms.com/dev/bulkV2"),
    headers: {
      "authorization": "cZs7ECog2xFUa0PLwN4VQf3urG6W8HKyOSehIYTBvMkzDbRtAqYv7Zebp6rmWRiHKzFBgNsL2DqfdkxQ",
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: {
      "message": message,
      "language": "english",
      "route": "v3",   // 🔥 VERY IMPORTANT
      "numbers": phone,
    },
  );

  print("SMS Response: ${response.body}");
}

  @override
void initState() {
  super.initState();
  loadUserData(); 

  // 🔥 IMPORTANT CHANGE
  dbRef.onValue.listen((event) async {
final data = event.snapshot.value as Map?;

if (data != null) {

  // ✅ STEP 1: UPDATE UI VALUES
  setState(() {
    bpm = data['bpm'] ?? 0;
    lux = (data['lux'] ?? 0).toDouble();
    ledBrightness = data['ledBrightness'] ?? 0;
    latitude = (data['latitude'] ?? 0).toDouble();
    longitude = (data['longitude'] ?? 0).toDouble();
    accident = data['accident'] ?? false;
  });

  // 🚨 STEP 2: SMS LOGIC (OUTSIDE setState)
   if (accident == true && previousAccident == false){

  print("🚨 ACCIDENT TRIGGERED"); // 🔥 ADD THIS

  alertSent = true;

    String url = "https://maps.google.com/?q=$latitude,$longitude";

    String message =
        "⚠️ ShieldX ALERT\n\nAccident detected!\n\nLocation:\n$url";

    try {

      final contactsSnapshot =
          await FirebaseDatabase.instance.ref("deviceData/contacts").get();

      if (contactsSnapshot.exists) {

        Map contacts = contactsSnapshot.value as Map;

        for (var entry in contacts.entries) {

          String phone = entry.value['phone'];

          await sendSMS(phone, message);
        }
      }

    } catch (e) {
      print("SMS Error: $e");
    }
  }
   previousAccident = accident;
}
    });  
  }   

 // home_page.dart — Premium UI rebuild
// Replace your existing HomePage widget body with this

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    extendBodyBehindAppBar: true,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF050505),
            Color(0xFF0D0F1A),
            Color(0xFF000000),],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildHeroCard(),
              const SizedBox(height: 20),
              _buildSectionLabel("Sensor Data"),
              const SizedBox(height: 10),
              _buildSensorGrid(),
              const SizedBox(height: 20),
              _buildSectionLabel("Emergency"),
              const SizedBox(height: 10),
              _buildSOSCard(),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── HEADER ─────────────────────────────────────────────
Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getGreeting(),
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                  letterSpacing: 1.5)),
          const SizedBox(height: 2),
          RichText(
            text:  TextSpan(
              style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5),
              children: [
                TextSpan(
                    text: "$userName",
                    style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          _iconBtn(Icons.notifications_outlined),
          const SizedBox(width: 10),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 241, 4, 4), Color.fromARGB(255, 245, 245, 245)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                  color: const Color(0xFFA0A0A0).withOpacity(0.4)),
            ),
            child:  Center(
              child: Text(userInitials,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _iconBtn(IconData icon) {
  return Container(
    width: 38, height: 38,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
      color: Colors.white.withOpacity(0.05),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Icon(icon, color: Colors.white.withOpacity(0.55), size: 18),
  );
}

// ── HERO CARD ──────────────────────────────────────────
Widget _buildHeroCard() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
     color: Colors.white.withOpacity(0.05),
      border: Border.all(color: const Color(0xFFA0A0A0).withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF292252).withOpacity(0.05),
            blurRadius: 24,
            spreadRadius: 2)
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LIVE DASHBOARD",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: const Color.fromARGB(255, 250, 250, 250).withOpacity(0.6))),
                  _liveBadge(),
                ],
              ),
              const SizedBox(height: 16),

              // Shield + status
              Row(
                children: [
                  _shieldIcon(),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rider Status",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.35))),
                      const SizedBox(height: 4),
                      Text(
                        accident ? "Accident!" : "All Safe",
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: accident
                              ? const Color(0xFFE82222)
                              : const Color.fromARGB(255, 17, 227, 77),
                        ),
                      ),
                      Text(
                        accident
                            ? "Alert sent to contacts"
                            : "No incidents detected · Shield active",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.3)),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 18),

              // Metric bars
              _metricBar("Heart Rate", "$bpm BPM", bpm / 200),
              
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _liveBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xFF60BC63).withOpacity(0.1),
      border: Border.all(color: const Color(0xFF60BC63).withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.from(alpha: 1, red: 0.298, green: 0.686, blue: 0.314),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.8), blurRadius: 5)
            ],
          ),
        ),
        const SizedBox(width: 6),
        const Text("STREAMING",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: Color.fromARGB(255, 235, 235, 235))),
      ],
    ),
  );
}

Widget _shieldIcon() {
  return Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color.fromARGB(255, 250, 4, 4).withOpacity(0.12),
      border: Border.all(color: const Color(0xFFA0A0A0).withOpacity(0.3)),
    ),
    child: const Icon(Icons.shield, color: Color(0xFFE82222), size: 28),
  );
}

Widget _metricBar(String label, String value, double pct) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withOpacity(0.5))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: pct.clamp(0.0, 1.0),
          minHeight: 4,
          backgroundColor: Colors.white.withOpacity(0.07),
          valueColor: const AlwaysStoppedAnimation(Color(0xFFE82222)),
        ),
      ),
    ],
  );
}

// ── SENSOR GRID ────────────────────────────────────────
Widget _buildSectionLabel(String title) {
  return Text(title.toUpperCase(),
      style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
          color: const Color.fromARGB(255, 236, 166, 4).withOpacity(0.65)));
}

// FIND THIS (lines ~starting with Widget _buildSensorGrid)
Widget _buildSensorGrid() {
  return Column(
    children: [
      SizedBox(
  height: 130,
  child: Row(
    children: [
      Expanded(
        child: _sensorCard(
          "Heart Rate", "$bpm BPM",
          Icons.favorite_rounded,
          isAccent: true, badgeGreen: false,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _sensorCard(
          "LED Brightness", "$ledBrightness lx",
          Icons.light_mode,
          isAccent: false, badgeGreen: true,
        ),
      ),
    ],
  ),
),
      const SizedBox(height: 10),
      _buildGPSCard(),
    ],
  );
}

Widget _sensorCard(String label, String value, IconData icon,
    {bool isAccent = false, bool badgeGreen = true}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.05),
      border: Border.all(
          color: const Color(0xFFA0A0A0)
              .withOpacity(isAccent ? 0.28 : 0.13)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.white.withOpacity(0.08),

border: Border.all(
  color: Colors.white.withOpacity(0.15),
),
                    ),
                    child: Icon(icon,
                        color: const Color(0xFFE05050)
                            .withOpacity(isAccent ? 0.95 : 0.8),
                        size: 16),
                  ),
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeGreen ? Colors.green : const Color(0xFF474747),
                      boxShadow: [
                        BoxShadow(
                            color: (badgeGreen ? Colors.green : const Color(0xFFE82222))
                                .withOpacity(0.8),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isAccent
                        ? const Color(0xFFE82222)
                        : Colors.white,
                  )),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4))),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildGPSCard() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white.withOpacity(0.05),
      border: Border.all(
          color: const Color(0xFFA0A0A0).withOpacity(0.13)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Color(0xFFE05050), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GPS Tracking",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 0.4)),
                  const SizedBox(height: 3),
                  Text(
                    "${latitude.toStringAsFixed(2)}°N  ·  ${longitude.toStringAsFixed(2)}°E",
                    style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 2),
                  Text("Real-time location · SHIELDX device",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.25))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.withOpacity(0.08),
                border: Border.all(
                    color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: [BoxShadow(
                          color: Colors.green.withOpacity(0.8),
                          blurRadius: 5)],
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text("LIVE",
                      style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Color(0xFF4CD25A))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// ── SOS CARD ──────────────────────────────────────────
Widget _buildSOSCard() {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xFF0E0606).withOpacity(0.9),
      border: Border.all(
          color: const Color.fromARGB(255, 236, 166, 4).withOpacity(0.25)),
    ),
    child: Row(
      children: [
        GestureDetector(
          onLongPress: () {
            print("SOS ACTIVATED");
            // your SOS logic here
          },
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 100, 5, 5), Color.fromARGB(255, 117, 7, 7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF292252).withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 3)
              ],
            ),
            child: const Center(
              child: Text("SOS",
                  style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hold to Activate",
                  style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 252, 252, 252),
                      letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                "Long press to send emergency alert to all contacts instantly.",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                    height: 1.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green.withOpacity(0.08),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child:  Text("$contactCount CONTACTS READY",
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: Color(0xFF4CD25A))),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
 with SingleTickerProviderStateMixin{

  final dbRef = FirebaseDatabase.instance.ref("deviceData");

  double latitude = 0;
  double longitude = 0;

  bool accident = false;
  bool isGpsActive = false;
  GoogleMapController? mapController;
  Set<Marker> markers = {}; 
late AnimationController _controller;
late Animation<double> _animation;
void shareLocation() {

    String url =
        "https://maps.google.com/?q=$latitude,$longitude";

    String message =
        "⚠️ ShieldX Location\n\n$url";

    Share.share(message);
  }
  Future<void> openGoogleMaps() async {

  final url =
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw "Could not open Google Maps";
  }
}
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 1),
);

_animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

_controller.repeat(reverse: true);

    dbRef.onValue.listen((event) {

      final data = event.snapshot.value as Map?;

      if (data != null) {
        setState(() {

  latitude = (data['latitude'] ?? 0).toDouble();
  longitude = (data['longitude'] ?? 0).toDouble();

  accident = data['accident'] ?? false;
  isGpsActive = latitude != 0 && longitude != 0; ///  GPS ACTIVE CHECK    

  /// 🔥 CLEAR OLD MARKER
  markers.clear();

  /// 🔥 ADD NEW MARKER
  markers.add(
    Marker(
      markerId: const MarkerId("rider"),
      position: LatLng(latitude, longitude),

      /// 👆 WHEN USER CLICKS DOT
      onTap: () {
        openGoogleMaps(); // opens real Google Maps
      },
    ),
  );

});
      }

    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [

        /// 🗺️ GOOGLE MAP (TOP)
       SizedBox(
  height: MediaQuery.of(context).size.height * 0.55,
  child: Stack(
    children: [

      /// 🗺️ MAP IMAGE
      Positioned.fill(
        child: Image.asset(
          "assets/images/map_bg.png",
          fit: BoxFit.cover,
        ),
      ),

      /// 📍 RED LOCATION DOT (CENTER)
 SizedBox(
  height: MediaQuery.of(context).size.height * 0.55,
  child: Stack(
    children: [

      /// 🗺️ MAP BACKGROUND
      Positioned.fill(
        child: Image.asset(
          "assets/images/map_bg.jpg",
          fit: BoxFit.cover,
        ),
      ),

      /// 🌑 DARK OVERLAY (REALISTIC EFFECT)
      Positioned.fill(
        child: Container(
          color: const Color(0xFF0A0F1C).withOpacity(0.3),
        ),
      ),

      /// 🔴 LIVE LOCATION DOT (CENTER)
Positioned(
  top: MediaQuery.of(context).size.height * 0.25,
  left: MediaQuery.of(context).size.width * 0.45,
  child: GestureDetector(
    onTap: openGoogleMaps,
    child: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [

            /// 🔴 PULSING GLOW
            Container(
  width: 20,
  height: 20,
  decoration: BoxDecoration(
    color: const Color(0xFFCD0202).withOpacity(_animation.value),
    shape: BoxShape.circle,
  ),
),

            /// 🔴 CENTER DOT
            Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Color(0xFFCD0202),
                shape: BoxShape.circle,
              ),
            ),

          ],
        );
      },
    ),
  ),
),
    ]
),
 ),
    ],
  ),
),

        /// 🔝 TOP BAR
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// LIVE
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 10),
                    SizedBox(width: 6),
                    Text("LIVE", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              /// LOGO
              const Text(
                "SHIELD-X",
                style: TextStyle(
                  color: Color(0xFFCD0202),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),

        /// 📦 BOTTOM CARD
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// LOCATION
                const Text(
                  "YOU ARE HERE",
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 6),

                Text(
                  "$latitude , $longitude",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    _statusBox(
                      isGpsActive ? "GPS Active" : "GPS offline" , 
                      isGpsActive ? Icons.navigation : Icons.gps_off,
                      isGpsActive ? Colors.red : Colors.green),

                    _statusBox(
                        accident ? "Accident" : "Safe Ride",
                        accident ?  Icons.warning : Icons.shield,
                        accident ? Colors.red : Colors.green),

                    _statusBox("Now", Icons.access_time, Colors.white),
                  ],
                ),

                const SizedBox(height: 20),

                /// BUTTONS
                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        onPressed: openGoogleMaps,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE78905),
                          padding: const EdgeInsets.all(14),       
                        ),
                        child: const Text("Open in Maps", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
                      
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: shareLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE78905),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Text("Share", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Real-time GPS tracking from SHIELDX device",
                  style: TextStyle(color: Colors.white38),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _statusBox(String text, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white.withOpacity(0.05),
    ),
    child: Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12),
        )
      ],
    ),
  );
}
@override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
