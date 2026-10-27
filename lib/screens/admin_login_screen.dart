import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final bool success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        final adminName = authProvider.userData?['name'] ?? 'Admin';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome back, $adminName! Logging in...',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        String errorMessage = authProvider.error ?? 'Login failed. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return Row(
              children: [
                // Left Branding Panel
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF090D16)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 48,
                            color: Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Shopping Admin Suite',
                          style: GoogleFonts.lexend(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Manage your e-commerce ecosystem with real-time analytics, order tracking, inventory control, and advanced administrative capabilities.',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: Colors.grey[400],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildFeatureItem(Icons.security_rounded, 'Enterprise Grade Security', 'End-to-end encrypted admin access'),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.analytics_rounded, 'Real-Time Insights', 'Monitor sales, stats and user activity instantly'),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.inventory_2_rounded, 'Seamless Control', 'Effortlessly update products, orders & categories'),
                      ],
                    ),
                  ),
                ),
                // Right Login Form Panel
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _buildLoginForm(authProvider),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile / Tablet layout
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 40,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLoginForm(authProvider),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: const Color(0xFF60A5FA), size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.lexend(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: GoogleFonts.lexend(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your details to sign in to the admin portal.',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Email Field
            Text(
              'Email Address',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !authProvider.isLoading,
              style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF0F172A)),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!val.contains('@')) return 'Please enter a valid email';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'admin@example.com',
                hintStyle: GoogleFonts.lexend(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.email_outlined, size: 20, color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Text(
              'Password',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              enabled: !authProvider.isLoading,
              style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF0F172A)),
              onFieldSubmitted: (_) => _handleLogin(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your password';
                }
                if (val.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: GoogleFonts.lexend(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey[500]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                  onPressed: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Remember me & Forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please contact super admin to reset your password.', style: GoogleFonts.lexend()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Sign In to Portal',
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
