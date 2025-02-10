import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rosedine/url_config.dart';
import 'dart:convert';
import 'package:rosedine/widgets/custom_text_widget.dart' as custom_widget;
import 'package:rosedine/widgets/custom_button_widget.dart';
import 'package:rosedine/widgets/centered_error_overlay.dart'; // Our unified error overlay widget

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _verificationToken;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Error overlay state (only for server-side errors)
  String? _errorMessage;
  String _errorTitle = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Retrieve the field values.
    final fname = _fnameController.text;
    final lname = _lnameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final url = Uri.parse(Config.getUrl('register'));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fname': fname,
          'lname': lname,
          'email': email,
          'password': password
        }),
      );
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response body: $responseBody');

        // Extract the token from the response (assuming it contains "Token: ..." in its body)
        final tokenStartIndex =
            responseBody.indexOf('Token: ') + 'Token: '.length;
        _verificationToken = responseBody.substring(tokenStartIndex);
        print('Verification token: $_verificationToken');

        _showVerificationCodeDialog(email);
      } else {
        // Trigger the error overlay on server-side error.
        setState(() {
          _errorTitle = 'Registration Failed';
          _errorMessage = 'Registration failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorTitle = 'Registration Failed';
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _showVerificationCodeDialog(String email) {
    TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            'Verify Email',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A verification code has been sent to $email.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              custom_widget.CustomTextField(
                controller: _codeController,
                labelText: 'Enter your verification code',
                obscureText: false,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String code = _codeController.text;
                _verifyEmail(code);
                Navigator.of(context).pop();
              },
              child: Text(
                'Verify',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyEmail(String code) async {
    final url = Uri.parse(Config.getUrl('verifyEmail'));
    final fname = _fnameController.text;
    final lname = _lnameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': _verificationToken,
          'code': code,
          'fname': fname,
          'lname': lname,
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        // On successful verification, navigate to the login screen.
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        setState(() {
          _errorTitle = 'Verification Failed';
          _errorMessage = 'Verification failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorTitle = 'Verification Failed';
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFAB8532),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return RadialGradient(
                                    center: Alignment.center,
                                    radius: 0.8,
                                    colors: [Colors.white, Colors.white.withOpacity(0.0)],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: Image.asset(
                                  'assets/RoseDine.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // First and Last Name fields (optional)
                      custom_widget.CustomTextField(
                        controller: _fnameController,
                        labelText: 'First Name',
                      ),
                      const SizedBox(height: 20),
                      custom_widget.CustomTextField(
                        controller: _lnameController,
                        labelText: 'Last Name',
                      ),
                      const SizedBox(height: 20),
                      // Email field with validation.
                      custom_widget.CustomTextField(
                        controller: _emailController,
                        labelText: 'Email *',
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password field with validation.
                      custom_widget.CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password *',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      // Changed button text for registration.
                      MyButton(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                        text: 'Register Now',
                      ),
                      const SizedBox(height: 20),
                      // Changed button text for navigating to login.
                      MyButton(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/auth');
                        },
                        text: 'Back to Login',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Centered error overlay appears only on server-side errors.
          if (_errorMessage != null)
            CenteredErrorOverlay(
              title: _errorTitle,
              errorMessage: _errorMessage!,
              onDismiss: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
