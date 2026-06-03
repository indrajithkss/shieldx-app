import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _dbRef = FirebaseDatabase.instance.ref("deviceData/profile");
  final user = FirebaseAuth.instance.currentUser;

  // Profile data state
  String _fullName = '';
  String _dob = '';
  String _age = '';
  String _gender = '';
  String _bloodGroup = '';
  String _height = '';
  String _weight = '';
  String _allergies = '';
  String _medicalDescription = '';
  bool _hasData = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _fullName = data['fullName'] ?? '';
          _dob = data['dob'] ?? '';
          _age = data['age'] ?? '';
          _gender = data['gender'] ?? '';
          _bloodGroup = data['bloodGroup'] ?? '';
          _height = data['height'] ?? '';
          _weight = data['weight'] ?? '';
          _allergies = data['allergies'] ?? '';
          _medicalDescription = data['medicalDescription'] ?? '';
          _hasData = _fullName.isNotEmpty || _bloodGroup.isNotEmpty;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _fullName = user?.email?.split('@')[0] ?? 'User';
        });
      }
    });
  }

  void _openEditDialog() {
    final nameCtrl = TextEditingController(text: _fullName);
    final dobCtrl = TextEditingController(text: _dob);
    final ageCtrl = TextEditingController(text: _age);
    final heightCtrl = TextEditingController(text: _height);
    final weightCtrl = TextEditingController(text: _weight);
    final allergyCtrl = TextEditingController(text: _allergies);
    final medCtrl = TextEditingController(text: _medicalDescription);
    String selectedGender = _gender;
    String selectedBlood = _bloodGroup;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111).withOpacity(0.97),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              _hasData ? "Edit Health Details" : "Add Health Details",
                              style: const TextStyle(
                                color: Color(0xFFE78905),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _dialogLabel("FULL NAME"),
                          _dialogInput("Your full name", nameCtrl),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("DATE OF BIRTH"),
                                    _dialogInput("DD/MM/YYYY", dobCtrl),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("AGE"),
                                    _dialogInput("e.g. 24", ageCtrl,
                                        inputType: TextInputType.number),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _dialogLabel("GENDER"),
                          _dialogDropdown(
                            value: selectedGender.isEmpty ? null : selectedGender,
                            hint: "Select gender",
                            items: ["Male", "Female", "Other", "Prefer not to say"],
                            onChanged: (val) =>
                                setDialogState(() => selectedGender = val ?? ''),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("BLOOD GROUP"),
                                    _dialogDropdown(
                                      value: selectedBlood.isEmpty ? null : selectedBlood,
                                      hint: "Select",
                                      items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
                                      onChanged: (val) =>
                                          setDialogState(() => selectedBlood = val ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("HEIGHT (cm)"),
                                    _dialogInput("e.g. 175", heightCtrl,
                                        inputType: TextInputType.number),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("WEIGHT (kg)"),
                                    _dialogInput("e.g. 70", weightCtrl,
                                        inputType: TextInputType.number),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("ALLERGIES"),
                                    _dialogInput("e.g. Peanuts", allergyCtrl),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _dialogLabel("MEDICAL DESCRIPTION"),
                          TextField(
                            controller: medCtrl,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText:
                                  "Conditions, medications, or important notes for emergency responders...",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2), fontSize: 12),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: Color(0xFFCD1205)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.06),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                  ),
                                  child: const Text("Cancel",
                                      style: TextStyle(color: Colors.white54)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _saveProfile(
                                      name: nameCtrl.text.trim(),
                                      dob: dobCtrl.text.trim(),
                                      age: ageCtrl.text.trim(),
                                      gender: selectedGender,
                                      blood: selectedBlood,
                                      height: heightCtrl.text.trim(),
                                      weight: weightCtrl.text.trim(),
                                      allergies: allergyCtrl.text.trim(),
                                      medical: medCtrl.text.trim(),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE78905),
                                    elevation: 8,
                                    shadowColor:
                                        const Color(0xFFE78905).withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                  ),
                                  child: const Text("Save Details",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveProfile({
    required String name,
    required String dob,
    required String age,
    required String gender,
    required String blood,
    required String height,
    required String weight,
    required String allergies,
    required String medical,
  }) {
    _dbRef.set({
      "fullName": name,
      "dob": dob,
      "age": age,
      "gender": gender,
      "bloodGroup": blood,
      "height": height,
      "weight": weight,
      "allergies": allergies,
      "medicalDescription": medical,
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _fullName.isNotEmpty
        ? _fullName
        : user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE78905)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "My Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openEditDialog,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE78905).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE78905).withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: Color(0xFFE78905), size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── AVATAR SECTION ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD1205).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                  color: const Color(0xFFCD1205).withOpacity(0.3),
                                  width: 2),
                            ),
                            child: const Icon(Icons.person,
                                color: Color(0xFFCD1205), size: 44),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          if (_hasData)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D9E75).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF1D9E75).withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Color(0xFF1D9E75), size: 12),
                                  SizedBox(width: 5),
                                  Text(
                                    "HEALTH INFO SAVED",
                                    style: TextStyle(
                                      color: Color(0xFF1D9E75),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const Text(
                              "No health details added yet",
                              style: TextStyle(color: Colors.white24, fontSize: 12),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── PERSONAL INFO ──
                    _sectionLabel("PERSONAL INFO"),
                    const SizedBox(height: 8),
                    _glassCard(
                      child: Column(
                        children: [
                          _infoRow(Icons.person_outline, const Color(0xFFE78905),
                              "FULL NAME", displayName),
                          _divider(),
                          _infoRow(Icons.calendar_today_outlined,
                              const Color(0xFFE78905), "DATE OF BIRTH",
                              _dob.isEmpty ? "Not set" : _dob,
                              empty: _dob.isEmpty),
                          _divider(),
                          _infoRow(Icons.access_time_outlined,
                              const Color(0xFFE78905), "AGE",
                              _age.isEmpty ? "Not set" : "$_age yrs",
                              empty: _age.isEmpty),
                          _divider(),
                          _infoRow(Icons.shield_outlined, const Color(0xFFE78905),
                              "GENDER", _gender.isEmpty ? "Not set" : _gender,
                              empty: _gender.isEmpty),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── HEALTH DETAILS ──
                    _sectionLabel("HEALTH DETAILS"),
                    const SizedBox(height: 8),
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                          children: [
                            _healthChip("BLOOD GROUP", _bloodGroup,
                                valueColor: const Color(0xFFe84040)),
                            _healthChip("HEIGHT",
                                _height.isEmpty ? "—" : "$_height cm"),
                            _healthChip("WEIGHT",
                                _weight.isEmpty ? "—" : "$_weight kg"),
                            _healthChip("ALLERGIES",
                                _allergies.isEmpty ? "—" : _allergies),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── MEDICAL DESCRIPTION ──
                    _sectionLabel("MEDICAL DESCRIPTION"),
                    const SizedBox(height: 8),
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _medicalDescription.isEmpty
                              ? 'No medical notes added. Tap "Add Details" to add important medical information.'
                              : _medicalDescription,
                          style: TextStyle(
                            color: _medicalDescription.isEmpty
                                ? Colors.white24
                                : Colors.white70,
                            fontSize: 13,
                            height: 1.6,
                            fontStyle: _medicalDescription.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── ADD / EDIT BUTTON ──
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "QUICK ACTION",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openEditDialog,
                              child: Container(
                                width: double.infinity,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE78905).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                      color: const Color(0xFFE78905).withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _hasData ? Icons.edit_outlined : Icons.add,
                                      color: const Color(0xFFE78905),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _hasData ? "Edit Details" : "Add Details",
                                      style: const TextStyle(
                                        color: Color(0xFFE78905),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ── HELPER WIDGETS ──

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _glassCard({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: child,
      );

  Widget _divider() => Divider(
        color: Colors.white.withOpacity(0.06),
        height: 1,
        indent: 16,
        endIndent: 16,
      );

  Widget _infoRow(IconData icon, Color iconColor, String label, String value,
      {bool empty = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: empty ? Colors.white24 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: empty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthChip(String label, String value, {Color? valueColor}) {
    final isEmpty = value == '—' || value.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              color: isEmpty
                  ? Colors.white24
                  : (valueColor ?? Colors.white),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
      );

  Widget _dialogInput(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFCD1205)),
        ),
      ),
    );
  }

  Widget _dialogDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFCD1205)),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
