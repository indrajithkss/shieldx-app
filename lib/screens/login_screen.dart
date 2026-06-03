import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

late AnimationController _controller;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  _fadeAnimation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(_controller);

  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ),
  );

  _controller.forward();
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

 Future<void> login() async {
  try {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation(),),
    );

  } on FirebaseAuthException catch (e) {

    String message = "Login Failed";

    if (e.code == 'user-not-found') {
      message = "User not found";
    } else if (e.code == 'wrong-password') {
      message = "Wrong password";
    } else if (e.code == 'invalid-email') {
      message = "Invalid email format";
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

      /// 🔥 BACKGROUND GRADIENT
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
            AnimatedScale(
  scale: 1,
  duration: const Duration(milliseconds: 800),
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
                color: const Color(0xFFCD0202),
              borderRadius: BorderRadius.circular(20),
              ),
    child: const Icon(
      Icons.shield,
      color: Colors.white,
      size: 30,
    ),
  ),
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
              "Smart Rider Safety System",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 30),

            /// 🔥 CARD
            FadeTransition(
  opacity: _fadeAnimation,
  child: SlideTransition(
    position: _slideAnimation,
    child: Container(
      padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Sign in to continue",
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 25),

                  /// EMAIL FIELD
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.white54),
                      hintText: "Email address",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PASSWORD FIELD
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

    /// ✅ FIXED PART
    suffixIcon: IconButton(
      icon: Icon(
        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                  const SizedBox(height: 10),

                  /// FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFFE78905)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔴 LOGIN BUTTON
                  GestureDetector(
  onTapDown: (_) => setState(() {}),
  onTapUp: (_) => setState(() {}),
  onTap: isLoading ? null : login,
  child: AnimatedScale(
    scale: isLoading ? 0.95 : 1,
    duration: const Duration(milliseconds: 150),
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
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DIVIDER
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR", style: TextStyle(color: Colors.white54)),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SOCIAL BUTTONS (UI ONLY)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     _socialBox(Icons.g_mobiledata, () {
                    print("Google login clicked");}),

                   _socialBox(Icons.apple, () {
                   print("Apple login clicked");}),

                   _socialBox(Icons.close, () {
                   print("X login clicked");}),
                    ],
                  ),
                ],
              ),
            ),
),
),

            const SizedBox(height: 20),

            /// SIGNUP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white54),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Create Account",
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
}
InputDecoration _inputStyle(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  );
}
Widget _socialBox(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}