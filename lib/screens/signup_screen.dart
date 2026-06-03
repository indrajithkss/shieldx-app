import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'package:firebase_database/firebase_database.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {

      late AnimationController _controller;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

 Future<void> signup() async {
  try {
    setState(() => isLoading = true);

    final userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: emailController.text.trim(),
  password: passwordController.text.trim(),
);

String uid = userCredential.user!.uid;

/// 🔥 SAVE EXTRA DATA
await FirebaseDatabase.instance.ref("users/$uid").set({
  "firstName": firstNameController.text.trim(),
  "lastName": lastNameController.text.trim(),
  "phone": phoneController.text.trim(),
  "email": emailController.text.trim(),
});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup Successful")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation(),),
    );

  } on FirebaseAuthException catch (e) {

    String message = "Signup Failed";

    if (e.code == 'email-already-in-use') {
      message = "Email already exists";
    } else if (e.code == 'weak-password') {
      message = "Password must be at least 6 characters";
    } else if (e.code == 'invalid-email') {
      message = "Invalid email";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

  } catch (e) {
    print(e);
  }

  setState(() => isLoading = false);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
  body: SafeArea(
  child: Stack(
    children: [

      /// 🔥 BACKGROUND
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050505),
              Color(0xFF0D0F1A),
              Color(0xFF000000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),

      /// 🔥 CONTENT
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [

            /// 🔴 LOGO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCD0202),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 30),
            ),

            const SizedBox(height: 20),

            /// TITLE
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "SHIELD-",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  TextSpan(
                    text: "X",
                    style: TextStyle(
                      color: Color(0xFFCD0202),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Create your account",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 30),

            /// 🔥 CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [

                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// FIRST NAME
                  _inputField(firstNameController, "First Name", Icons.person),

                  const SizedBox(height: 10),

                  /// LAST NAME
                  _inputField(lastNameController, "Last Name", Icons.person_outline),

                  const SizedBox(height: 10),

                  /// PHONE
                  _inputField(phoneController, "Phone Number", Icons.phone),

                  const SizedBox(height: 10),

                  /// EMAIL
                  _inputField(emailController, "Email", Icons.email),

                  const SizedBox(height: 10),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),

                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔴 SIGNUP BUTTON
                  GestureDetector(
                    onTap: isLoading ? null : signup,
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFE78905), Color.fromARGB(255, 247, 182, 3)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LOGIN LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.white54),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Color(0xFFE78905)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
),
    );
  }
  Widget _inputField(
  TextEditingController controller,
  String hint,
  IconData icon,
) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white54),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
}