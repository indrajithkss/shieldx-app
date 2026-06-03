import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage>
    with SingleTickerProviderStateMixin {

  final dbRef = FirebaseDatabase.instance.ref("deviceData");

  late AnimationController _ecgController;

  int bpm = 0;
  double latitude = 0;
  double longitude = 0;
  bool accident = false;
  int ledBrightness = 0;

  bool ledOn = true;
  bool buzzerOn = true;
  double brightness = 0.7;

  @override
  void initState() {
    super.initState();

    _ecgController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1200),
)..repeat();

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data != null) {
        setState(() {
          bpm = data['bpm'] ?? 0;
          latitude = (data['latitude'] ?? 0).toDouble();
          longitude = (data['longitude'] ?? 0).toDouble();
          accident = data['accident'] ?? false;
          ledBrightness = data['ledBrightness'] ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _ecgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 15),
                _buildControlBar(),
                const SizedBox(height: 5),
                _buildJacket(),
                const SizedBox(height: 5),
                _buildCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌌 BACKGROUND
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF050505),
            Color(0xFF0D0F1A),
            Color(0xFF000000),
          ],
        ),
      ),
    );
  }

  // 🔝 HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.arrow_back, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("ShieldX Device",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 4),
              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Colors.green),
                  SizedBox(width: 6),
                  Text("Connected",
                      style: TextStyle(color: Colors.green)),
                ],
              )
            ],
          ),
          const Spacer(),
          const Icon(Icons.shield, color: Colors.cyan),
        ],
      ),
    );
  }

  // 🎛 CONTROL BAR
  Widget _buildControlBar() {
    return _glassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Text("LEDs", style: TextStyle(color: Colors.white)),
          Switch(
            value: ledOn,
            activeColor: const Color(0xFF00DDFF),
            onChanged: (val) => setState(() => ledOn = val),
          ),
          Expanded(
            child: Slider(
              value: brightness,
              onChanged: (val) => setState(() => brightness = val),
              activeColor: const Color(0xFF00DDFF),
            ),
          ),
          const Text("Buzzer", style: TextStyle(color: Colors.white)),
          Switch(
            value: buzzerOn,
            activeColor: const Color(0xFF00DDFF),
            onChanged: (val) => setState(() => buzzerOn = val),
          ),
        ],
      ),
    );
  }

  // 🧥 JACKET
  Widget _buildJacket() {
    return Center(
      child: Image.asset(
        'assets/images/jacket.png',
        height: 320,
      ),
    );
  }

  // 📊 CARDS
  Widget _buildCards() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.35,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCard("LED Strips",
                ledOn ? "Active" : "Off",
                Colors.green,
                "Brightness: $ledBrightness"),

            _buildCard("Accident Sensor",
                accident ? "Detected" : "Standby",
                accident ? Colors.red : Colors.orange,
                "Auto-SOS"),

            _buildCard("GPS",
                "Active",
                Colors.green,
                "$latitude , $longitude"),

            _buildCard("Heart Rate",
                "$bpm BPM",
                Colors.red,
                "Live"),
          ],
        ),
      ),
    );
  }

  // 🧊 CARD
  Widget _buildCard(String title, String value, Color color, String sub) {
    if (title == "Heart Rate") {
      return _buildHeartBeatCard(title, value, color, sub);
    }

    return _glassContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  // ❤️ HEART + ECG
  Widget _buildHeartBeatCard(
      String title, String value, Color color, String sub) {

    int durationMs = bpm > 0 ? (60000 ~/ bpm) : 800;

    return _glassContainer(
      padding: const EdgeInsets.all(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.1),
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Icon(Icons.favorite, color: color, size: 20),

                const SizedBox(height: 6),

                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),

                Text(value,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold)),

                const SizedBox(height: 4),

                _buildECGWave(color),

                const SizedBox(height: 4),

                Text(sub,
                    style: const TextStyle(color: Colors.white54)),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📈 ECG WAVE
  Widget _buildECGWave(Color color) {
    return SizedBox(
      height: 22,
      child: AnimatedBuilder(
        animation: _ecgController,
        builder: (context, child) {
          return CustomPaint(
            painter: ECGPainter(_ecgController.value, color, bpm),
            size: const Size(double.infinity, 30),
          );
        },
      ),
    );
  }

  // 🧊 GLASS
  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// 🔥 ECG PAINTER (OUTSIDE CLASS)
class ECGPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int bpm;

  ECGPainter(this.progress, this.color, this.bpm);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final path = Path();

    double width = size.width;
    double height = size.height;
    double mid = height / 2;

    // 🔥 realistic spacing based on BPM
    double beatWidth = bpm > 0 ? width / (bpm / 20) : width / 2;

    // 🔥 moving offset
    double offset = progress * width;

    path.moveTo(0, mid);

    for (double i = 0; i < width; i++) {
      double x = (i + offset) % beatWidth;

      double y = mid;

      // 🔥 ECG SHAPE (P-QRS-T)
      if (x < beatWidth * 0.1) {
        y = mid - 3; // P wave
      } else if (x < beatWidth * 0.15) {
        y = mid + 2;
      } else if (x < beatWidth * 0.2) {
        y = mid - 20; // Q spike
      } else if (x < beatWidth * 0.22) {
        y = mid + 25; // R spike (main peak)
      } else if (x < beatWidth * 0.25) {
        y = mid - 10; // S dip
      } else if (x < beatWidth * 0.35) {
        y = mid + 5;
      } else if (x < beatWidth * 0.5) {
        y = mid - 6; // T wave
      }

      // 🔥 slight randomness for realism
      y += (i % 7 == 0) ? 0.5 : 0;

      path.lineTo(i, y);
    }

    // 🔥 draw glow first
    canvas.drawPath(path, glowPaint);

    // 🔥 draw main ECG line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}