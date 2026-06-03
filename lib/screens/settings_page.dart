import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'profile_page.dart';



bool smsAlerts = true;
bool autoAlert = true;
bool darkMode = true;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

late DatabaseReference dbRef;


String userName = "User";
bool isLoadingUser = true;

void loadUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final ref = FirebaseDatabase.instance.ref("users/${user.uid}/profile");

  final snapshot = await ref.get();

  if (snapshot.value != null) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    setState(() {
      userName = data['fullName'] ?? user.email!.split('@')[0];
      isLoadingUser = false;
    });
  } else {
    setState(() {
      userName = user.email!.split('@')[0];
      isLoadingUser = false;
    });
  }
}



@override
void initState() {
  super.initState();

  final user = FirebaseAuth.instance.currentUser;

  dbRef = FirebaseDatabase.instance
      .ref("users/${user!.uid}/contacts");

  loadUserProfile();
}
 
void addContactDialog() {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  showDialog(
  context: context,
  builder: (context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔥 TITLE
                const Text(
                  "Add Emergency Contact",
                  style: TextStyle(
                    color: Color(0xFFE78905),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _inputField("Full Name", nameController),
                const SizedBox(height: 12),

                _inputField("Relation", relationController),
                const SizedBox(height: 12),

                _inputField("Phone Number", phoneController),
                const SizedBox(height: 25),

                /// 🔥 BUTTONS
                Row(
                  children: [

                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          dbRef.push().set({
                            "name": nameController.text,
                            "relation": relationController.text,
                            "phone": phoneController.text,
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE78905),
                          elevation: 10,
                          shadowColor: const Color(0xFFE78905).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}
Widget _inputField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color.fromARGB(255, 208, 7, 4)),
      ),
    ),
  );
}
void editContactDialog(String key, Map contact) {
  TextEditingController nameController =
      TextEditingController(text: contact['name']);

  TextEditingController relationController =
      TextEditingController(text: contact['relation']);

  TextEditingController phoneController =
      TextEditingController(text: contact['phone']);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// 🔥 TITLE
                  const Text(
                    "Edit Contact",
                    style: TextStyle(
                      color: Color(0xFFE78905),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _inputField("Full Name", nameController),
                  const SizedBox(height: 12),

                  _inputField("Relation", relationController),
                  const SizedBox(height: 12),

                  _inputField("Phone Number", phoneController),
                  const SizedBox(height: 25),

                  /// 🔥 BUTTONS
                  Row(
                    children: [

                      /// CANCEL
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),

                      /// UPDATE
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            dbRef.child(key).update({
                              "name": nameController.text,
                              "relation": relationController.text,
                              "phone": phoneController.text,
                            });

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE78905),
                            elevation: 10,
                            shadowColor:
                                const Color(0xFFE78905).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Update"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HEADER
            const Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Manage your SHIELD-X preferences",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 20),

            /// 👤 PROFILE CARD
            _glassCard(
              
  child: ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    },

    leading: CircleAvatar(
      radius: 28,
      backgroundColor: Colors.red.withOpacity(0.2),
      child: const Icon(Icons.person, color: Colors.red),
    ),

    title: Text(
  isLoadingUser ? "Loading..." : userName,
  style: const TextStyle(color: Colors.white),
),

    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user?.email ?? "No Email",
            style: TextStyle(color: Colors.white54)),
        Text("Tap to view profile",
            style: TextStyle(color: Colors.white38)), // optional improvement
      ],
    ),
  ),
),

            const SizedBox(height: 25),

            /// 🚨 EMERGENCY
            const Text("EMERGENCY",
                style: TextStyle(color: Colors.white54)),

            const SizedBox(height: 10),

            _glassCard(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.white),
                    title: const Text(
  "Emergency Contacts",
  style: TextStyle(
    color: Color.fromARGB(255, 182, 3, 3),
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white54),
                    onTap: () {
                       showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    isScrollControlled: true,
    builder: (_) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _contactsUI(),
      );
    },
  );
                    },
                  ),

                  const Divider(color: Colors.white12),

              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  child: ElevatedButton.icon(
    onPressed: () {
      print("Test Emergency Alert");
    },
    icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
    label: const Text(
      "Test Emergency Alert",
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 205, 18, 5),
      minimumSize: const Size(double.infinity, 46),
      elevation: 6,
      shadowColor: Colors.red.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 🔔 ALERTS
            const Text("ALERTS",
                style: TextStyle(color: Colors.white54)),

            const SizedBox(height: 10),

            _glassCard(
              child: Column(
                children: [

                  SwitchListTile(
  value: smsAlerts,
  onChanged: (val) async {
    setState(() {
      smsAlerts = val;
    });

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseDatabase.instance
        .ref("users/${user!.uid}/settings/smsAlerts")
        .set(val);
  },
                    title: const Text("SMS Alerts",
                        style: TextStyle(color: Colors.white)),
                    secondary:
                        const Icon(Icons.sms, color: Colors.white),
                    activeColor: const Color(0xFFE78905),
                  ),

                  SwitchListTile(
                    value: autoAlert,
                    onChanged: (val) {
                     setState(() {
                       autoAlert = val;
                        });
                       },
                    title: const Text("Auto Accident Alert",
                        style: TextStyle(color: Colors.white)),
                    secondary:
                        const Icon(Icons.warning, color: Colors.white),
                    activeColor: const Color(0xFFE78905),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ⚙️ APP SETTINGS
            const Text("APP SETTINGS",
                style: TextStyle(color: Colors.white54)),

            const SizedBox(height: 10),

            _glassCard(
              child: SwitchListTile(
                value: darkMode,
                onChanged: (val) {
                  setState(() {
                    darkMode = val;
                  });
                },
                title: const Text("Dark Mode",
                    style: TextStyle(color: Colors.white)),
                secondary:
                    const Icon(Icons.dark_mode, color: Colors.white),
                activeColor: const Color(0xFFE78905),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔓 LOGOUT
            Center(
             child:GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: Container(
                height: 48,
                width: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE78905), Color.fromARGB(255, 247, 182, 3)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _contactsUI() {
  return Column(
    children: [

      /// HEADER
      const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Emergency Contacts",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),

      /// ADD BUTTON
     ElevatedButton(
  onPressed: addContactDialog,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE78905),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: const Text(
    "Add Contact",
    style: TextStyle(color: Colors.white),
  ),
),

      /// LIST
      Expanded(
        child: StreamBuilder(
          stream: dbRef.onValue,
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
  child: Text(
    "No contacts added",
    style: TextStyle(color: Colors.white54),
  ),
);
            }

          final event = snapshot.data as DatabaseEvent;
          final data = event.snapshot.value;

            if (data == null) {
              return const Center(child: Text("No contacts"));
            }

            Map contacts = data as Map;

            return ListView(
              children: contacts.entries.map<Widget>((entry) {

                var contact = entry.value;

               return Container(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white12),
  ),
  child: Row(
    children: [

      /// ICON
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(255, 79, 2, 2).withOpacity(0.2),
        ),
        child: const Icon(Icons.person, color: Color.fromARGB(255, 235, 2, 2)),
      ),

      const SizedBox(width: 12),

      /// TEXT INFO
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact['name'],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              "${contact['relation']} • ${contact['phone']}",
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),

      /// ACTIONS
      Row(
        children: [

          IconButton(
            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              editContactDialog(entry.key, contact);
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 242, 1, 1)),
            onPressed: () {
              dbRef.child(entry.key).remove();
            },
          ),
        ],
      )
    ],
  ),
);

              }).toList(),
            );
          },
        ),
      ),
    ],
  );
}
}
Widget _glassCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    ),
    child: child,
  );
}


Widget sensorCard(String title, String value, IconData icon) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 88, 2, 2).withOpacity(0.2),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 241, 31, 3), size: 28),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}