import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_project/screens/admin_banners_screen.dart';
import 'package:new_flutter_project/screens/admin_dashboard_screen.dart';
import 'package:new_flutter_project/screens/admin_offers_screen.dart';
import 'package:new_flutter_project/screens/admin_quiz_screen.dart';
import 'package:new_flutter_project/screens/admin_support_screen.dart';
import 'package:new_flutter_project/screens/admin_users_screen.dart';
import 'package:new_flutter_project/screens/brand_management_screen.dart';
import 'package:new_flutter_project/screens/products/category_list_screen.dart';
import 'package:new_flutter_project/screens/products/products_screen.dart';
import 'package:new_flutter_project/screens/products/sub_category_list_screen.dart';
import 'package:new_flutter_project/screens/admin_orders_screen.dart';
import 'package:new_flutter_project/screens/admin_returns_screen.dart';
import 'package:provider/provider.dart';

import '../providers/admin_auth_provider.dart';
import 'admin_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    "Dashboard Overview",        // Index 0
    "Products Management",       // Index 1
    "Categories Management",     // Index 2
    "Orders Management",         // Index 3
    "Settings",                  // Index 4
    "Sub Categories Management", // Index 5
    "Returns & Refunds",         // Index 6
    "Support Tickets",           // Index 7
    "Banners Management",        // Index 8
    "Offers Management",         // Index 9
    "Users Management",          // Index 10
    "Brands Management",         // Index 11
    "Quiz & Fun Zone",           // Index 12
  ];

  final List<Widget> _pages = [
    const AdminDashboardScreen(),   // 0
    const ProductsScreen(),         // 1
    const CategoryListScreen(),     // 2
    const AdminOrdersScreen(),      // 3
    const AdminSettingsScreen(),    // 4
    const SubCategoryListScreen(),  // 5
    const AdminReturnsScreen(),     // 6
    const AdminSupportScreen(),     // 7
    const AdminBannersScreen(),     // 8
    const AdminOffersScreen(),      // 9
    const AdminUsersScreen(),       // 10
    const BrandManagementScreen(),  // 11
    const AdminQuizScreen(),        // 12
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = (_selectedIndex < _pages.length && _selectedIndex < _titles.length)
        ? _selectedIndex
        : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: !isDesktop
              ? Drawer(
                  backgroundColor: const Color(0xFF0F172A),
                  child: _buildSidebarContent(context, isDrawer: true),
                )
              : null,
          body: Row(
            children: [
              // 1. Permanent Sidebar Navigation (Desktop / Wide screens)
              if (isDesktop)
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A), // Slate 900
                    border: Border(
                      right: BorderSide(color: Color(0xFF1E293B), width: 1),
                    ),
                  ),
                  child: _buildSidebarContent(context, isDrawer: false),
                ),

              // 2. Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Modern Top Header Bar
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (!isDesktop) ...[
                                IconButton(
                                  icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
                                  onPressed: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  tooltip: 'Open Menu',
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _titles[safeIndex],
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Super Admin',
                                      style: GoogleFonts.lexend(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                                onPressed: () {},
                                tooltip: 'Notifications',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Active Page Content
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        padding: EdgeInsets.all(constraints.maxWidth < 600 ? 12.0 : 24.0),
                        child: IndexedStack(
                          index: safeIndex,
                          children: _pages,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool isDrawer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Logo / Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHOPPING',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Admin Portal',
                    style: GoogleFonts.lexend(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF1E293B), height: 1),

        // Sidebar Navigation Items (Grouped)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: [
              _buildSectionHeader('OVERVIEW'),
              _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0, isDrawer),

              const SizedBox(height: 16),
              _buildSectionHeader('CATALOG'),
              _buildNavItem(Icons.inventory_2_rounded, "Products", 1, isDrawer),
              _buildNavItem(Icons.category_rounded, "Categories", 2, isDrawer),
              _buildNavItem(Icons.grid_view_rounded, "Sub Categories", 5, isDrawer),
              _buildNavItem(Icons.branding_watermark_rounded, "Brands", 11, isDrawer),

              const SizedBox(height: 16),
              _buildSectionHeader('OPERATIONS'),
              _buildNavItem(Icons.shopping_bag_rounded, "Orders", 3, isDrawer),
              _buildNavItem(Icons.assignment_return_rounded, "Returns & Refunds", 6, isDrawer),
              _buildNavItem(Icons.support_agent_rounded, "Support Tickets", 7, isDrawer),

              const SizedBox(height: 16),
              _buildSectionHeader('MARKETING & USERS'),
              _buildNavItem(Icons.view_carousel_rounded, "Banners", 8, isDrawer),
              _buildNavItem(Icons.local_offer_rounded, "Offers", 9, isDrawer),
              _buildNavItem(Icons.people_alt_rounded, "Users", 10, isDrawer),

              const SizedBox(height: 16),
              _buildSectionHeader('SYSTEM'),
              _buildNavItem(Icons.settings_rounded, "Settings", 4, isDrawer),
              _buildNavItem(Icons.sports_esports_rounded, "Quiz & Fun Zone", 12, isDrawer),
            ],
          ),
        ),

        const Divider(color: Color(0xFF1E293B), height: 1),

        // Logged-in Admin Profile Card & Logout in Sidebar
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final userData = authProvider.userData;
                  final name = userData?['name'] ?? 'Admin User';
                  final email = userData?['email'] ?? 'admin@shop.com';
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'A',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GoogleFonts.lexend(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    if (isDrawer) Navigator.pop(context);
                    _handleLogout(context);
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          color: Colors.grey.shade500,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index, bool isDrawer) {
    return _HoverableNavItem(
      icon: icon,
      title: title,
      isSelected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        if (isDrawer) {
          Navigator.pop(context);
        }
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/admin-login',
      (route) => false,
    );
  }
}

class _HoverableNavItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverableNavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.blue.shade600
              : _isHovered
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? Colors.white
                      : _isHovered
                      ? Colors.white
                      : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.lexend(
                      color: widget.isSelected
                          ? Colors.white
                          : _isHovered
                          ? Colors.white
                          : Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
