import 'package:e_learning_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Ensure LoginPage is created
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCheckboxChecked = false;
  bool _isFormValid = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Method to validate the form
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      // Email validation
      if (email.isEmpty) {
        _emailError = "Email is required.";
      } else if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(email)) {
        _emailError = "Enter a valid email.";
      } else {
        _emailError = null;
      }

      // Password validation
      if (password.isEmpty) {
        _passwordError = "Password is required.";
      } else if (password.length < 6) {
        _passwordError = "Password must be at least 6 characters.";
      } else {
        _passwordError = null;
      }

      // Confirm Password validation
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = "Please confirm your password.";
      } else if (password != confirmPassword) {
        _confirmPasswordError = "Passwords do not match.";
      } else {
        _confirmPasswordError = null;
      }

      // Enable the "Create account" button only if all fields are valid and the checkbox is checked
      _isFormValid = _emailError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _isCheckboxChecked;
    });
  }

  // Method to create an account using Firebase Authentication
  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Create a new user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful sign-up, navigate to the Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginPage()), // Navigating to LoginPage
      );

      // Show a success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully!')),
      );

      print('User created successfully: ${userCredential.user?.email}');
    } catch (error) {
      print('Sign up failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $error')),
      );
    }
  }

  // Google Sign-In method
  Future<void> _handlegoogleSignIn() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Obtain the authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // After successful sign-in, navigate to the home page or wherever you want
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedIndex: 0,
          ), // You can navigate to your desired page here
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In successful!')),
      );
    } catch (error) {
      print('Google Sign-In failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $error')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6FF),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Enter your details below & free sign up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorText: _emailError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Create Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            errorText: _passwordError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            errorText: _confirmPasswordError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _isCheckboxChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isCheckboxChecked = value!;
                                });
                                _validateForm();
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'By creating an account you agree to our terms & conditions.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isFormValid
                                ? _createAccount // Calls Firebase sign-up method
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFormValid ? Colors.blue : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Or Sign Up with',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                                  _handlegoogleSignIn, // Google Sign-In method
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/google.png'),
                              ),
                            ),
                            const SizedBox(
                                width: 20), // Space between Google and Facebook
                            GestureDetector(
                              onTap: () {
                                // Add Facebook Sign-in logic here
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/facebook.png'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          selectedIndex: 0,
                                        )),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}
