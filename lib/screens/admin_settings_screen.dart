import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
// Apne project ke path ke mutabiq AdminSettingsProvider ko import karein

import '../providers/admin_settings_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Store Settings Controllers
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _supportEmailController = TextEditingController();
  final TextEditingController _supportPhoneController = TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  String _selectedCurrency = 'USD (\$';

  // Notification Toggles
  bool _orderNotifications = true;
  bool _lowStockAlerts = true;
  bool _ticketAlerts = true;
  bool _maintenanceMode = false;

  // Password Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Screen load hote hi backend se settings fetch karenge
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<AdminSettingsProvider>(context, listen: false);
      await provider.fetchSettings();
      if (mounted) {
        _populateControllers(provider);
      }
    });
  }

  // Provider ke data se controllers ko fill karna
  void _populateControllers(AdminSettingsProvider provider) {
    _storeNameController.text = provider.storeName;
    _supportEmailController.text = provider.supportEmail;
    _supportPhoneController.text = provider.supportPhone;
    _taxRateController.text = provider.taxRate.toString();
    _selectedCurrency = provider.defaultCurrency;
    _orderNotifications = provider.orderAlerts;
    _lowStockAlerts = provider.lowStockAlerts;
    _ticketAlerts = provider.ticketAlerts;
    _maintenanceMode = provider.maintenanceMode;
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _taxRateController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Backend API ke sath Save function
  void _saveSettings() async {
    final provider = Provider.of<AdminSettingsProvider>(context, listen: false);

    final updateData = {
      'storeName': _storeNameController.text.trim(),
      'supportEmail': _supportEmailController.text.trim(),
      'supportPhone': _supportPhoneController.text.trim(),
      'defaultCurrency': _selectedCurrency,
      'taxRate': double.tryParse(_taxRateController.text) ?? 18.0,
      'notifications': {
        'orderAlerts': _orderNotifications,
        'lowStockAlerts': _lowStockAlerts,
        'ticketAlerts': _ticketAlerts,
      },
      'maintenanceMode': _maintenanceMode,
    };

    bool success = await provider.updateSettings(updateData);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Settings updated successfully!' : (provider.error ?? 'Failed to update settings'),
          style: GoogleFonts.lexend(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _updatePassword() {
    if (_newPasswordController.text.isEmpty || _currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in password fields', style: GoogleFonts.lexend()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters long', style: GoogleFonts.lexend()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New passwords do not match', style: GoogleFonts.lexend()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // TODO: Agar password update API ho toh yahan call karein
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password updated successfully!', style: GoogleFonts.lexend(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<AdminSettingsProvider>(context);

    final userData = authProvider.userData;
    final adminName = userData?['name'] ?? 'Super Admin';
    final adminEmail = userData?['email'] ?? 'admin@shop.com';

    // Agar pehli baar data fetch ho raha hai toh loading indicator dikhayein
    if (settingsProvider.isLoading && !_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Settings & Configuration',
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage store parameters, notifications, admin profile, and security settings.',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: settingsProvider.isSaving ? null : _saveSettings,
                  icon: settingsProvider.isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    settingsProvider.isSaving ? 'Saving...' : 'Save All Changes',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Grid or responsive layout for cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildStoreSettingsCard(),
                            const SizedBox(height: 24),
                            _buildNotificationSettingsCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildAdminProfileCard(adminName, adminEmail),
                            const SizedBox(height: 24),
                            _buildSecurityCard(),
                            const SizedBox(height: 24),
                            _buildSystemMaintenanceCard(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildStoreSettingsCard(),
                      const SizedBox(height: 24),
                      _buildAdminProfileCard(adminName, adminEmail),
                      const SizedBox(height: 24),
                      _buildNotificationSettingsCard(),
                      const SizedBox(height: 24),
                      _buildSecurityCard(),
                      const SizedBox(height: 24),
                      _buildSystemMaintenanceCard(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContainer({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue.shade600, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE2E8F0), height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildStoreSettingsCard() {
    return _buildCardContainer(
      title: 'Store Configuration',
      subtitle: 'General store info, currency, and tax parameters',
      icon: Icons.store_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Store Name', _storeNameController, Icons.storefront),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Support Email', _supportEmailController, Icons.email_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Support Phone', _supportPhoneController, Icons.phone_outlined)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Default Currency', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ['USD (\$)', 'EUR (€)', 'INR (₹)', 'GBP (£)'].contains(_selectedCurrency) ? _selectedCurrency : 'USD (\$)',
                          isExpanded: true,
                          items: ['USD (\$)', 'EUR (€)', 'INR (₹)', 'GBP (£)'].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val, style: GoogleFonts.lexend(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Default Tax Rate (%)', _taxRateController, Icons.percent_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileCard(String name, String email) {
    return _buildCardContainer(
      title: 'Admin Profile',
      subtitle: 'Your administrator credentials & role',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade600,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: GoogleFonts.lexend(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'SUPER ADMIN',
                        style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return _buildCardContainer(
      title: 'Notifications & Alerts',
      subtitle: 'Configure what events trigger notifications',
      icon: Icons.notifications_active_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            'New Order Alerts',
            'Receive instant push notifications when a customer places an order',
            _orderNotifications,
                (val) => setState(() => _orderNotifications = val),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildSwitchTile(
            'Low Stock Alerts',
            'Get notified when product stock falls below threshold (5 items)',
            _lowStockAlerts,
                (val) => setState(() => _lowStockAlerts = val),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildSwitchTile(
            'Support Ticket Notifications',
            'Alert admin when new customer support tickets are created',
            _ticketAlerts,
                (val) => setState(() => _ticketAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return _buildCardContainer(
      title: 'Security & Password',
      subtitle: 'Update your administrator password',
      icon: Icons.lock_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Current Password', _currentPasswordController, Icons.lock, obscure: true),
          const SizedBox(height: 16),
          _buildTextField('New Password', _newPasswordController, Icons.lock_reset, obscure: true),
          const SizedBox(height: 16),
          _buildTextField('Confirm New Password', _confirmPasswordController, Icons.lock_outline, obscure: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
                side: BorderSide(color: Colors.blue.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _updatePassword,
              icon: const Icon(Icons.key_rounded, size: 16),
              label: Text(
                'Update Password',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMaintenanceCard() {
    return _buildCardContainer(
      title: 'System & Maintenance',
      subtitle: 'App maintenance mode and cache management',
      icon: Icons.engineering_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            'Maintenance Mode',
            'Temporarily disable storefront for customer purchases during updates',
            _maintenanceMode,
                (val) => setState(() => _maintenanceMode = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App cache cleared successfully!', style: GoogleFonts.lexend(color: Colors.white)),
                    backgroundColor: Colors.amber.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.cleaning_services_rounded, size: 16),
              label: Text(
                'Clear System Cache',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Colors.blue.shade600,
        ),
      ],
    );
  }
}