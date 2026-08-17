import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'utils/responsive.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
  );

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: isWideScreen
            ? Row(
                children: [
                  // Left side hero branding for desktop/wide screens
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D1B3E),
                            Color(0xFF1E3A8A),
                            Color(0xFF2563EB),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              size: 40,
                              color: Color(0xFF0D1B3E),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Join NeuralWatt',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Supercharge your facility with intelligent energy telemetry.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF93C5FD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildHeroFeatureRow(
                            Icons.speed_rounded,
                            'Instant Telemetry Ingestion',
                            'Upload CSV or stream live energy metrics in seconds.',
                          ),
                          const SizedBox(height: 24),
                          _buildHeroFeatureRow(
                            Icons.auto_awesome,
                            'Automated Gap Resolution',
                            'AI fills missing historical consumption data seamlessly.',
                          ),
                          const SizedBox(height: 24),
                          _buildHeroFeatureRow(
                            Icons.query_stats,
                            'Precision Analytics',
                            'Gain operational insights for homes, office buildings & industrial plants.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side signup form
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(48.0),
                        child: ResponsiveCenter(
                          maxWidth: 460,
                          padding: EdgeInsets.zero,
                          child: _buildSignupForm(isWide: true),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: ResponsiveCenter(
                    maxWidth: 480,
                    padding: EdgeInsets.zero,
                    child: _buildSignupForm(isWide: false),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeroFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFFBFDBFE)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isWide) ...[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(
                Icons.dark_mode_outlined,
                color: Color(0xFF64748B),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 10),
          // Logo
          RepaintBoundary(
            child: Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 35,
                    color: Color(0xFF0D1B3E),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NeuralWatt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join the future of smart consumption intelligence.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),
        ] else ...[
          const Text(
            'Create Your Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get started with NeuralWatt energy intelligence today.',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),
        ],

        // Full Name Field
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Jane Doe',
              prefixIcon: Icon(Icons.person_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Work Email Field
        const Text(
          'Work Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'jane.doe@company.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Password Field
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Sign Up Button
        ElevatedButton(
          onPressed: _signup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Divider
        const Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Or sign up with',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 24),

        // Social Buttons
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
          label: const Text(
            'Google',
            style: TextStyle(color: Color(0xFF334155)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEEF2FF),
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.business, size: 20, color: Color(0xFF2563EB)),
          label: const Text(
            'Enterprise SSO',
            style: TextStyle(color: Color(0xFF334155)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEEF2FF),
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Log in link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Log in',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
