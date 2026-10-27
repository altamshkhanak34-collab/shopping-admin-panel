import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/admin_user_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Admin', 'User'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserProvider>().fetchAdminUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Modern Entry Animation Helper
  Widget _buildAnimatedSection(Widget child, {int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  // 📦 Bottom Sheet: Particular User ki Order History
  void _showUserOrdersSheet(BuildContext context, String userId, String userName) {
    context.read<AdminUserProvider>().fetchUserOrders(userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          height: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$userName\'s Orders',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<AdminUserProvider>(
                  builder: (context, provider, child) {
                    if (provider.isOrdersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.userOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No orders placed by $userName yet.',
                              style: GoogleFonts.lexend(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider.userOrders.length,
                      itemBuilder: (context, index) {
                        final order = provider.userOrders[index];
                        final String orderId = order['_id'] ?? '';
                        final String status = order['orderStatus'] ?? 'Pending';
                        final num totalAmount = order['finalAmount'] ?? order['totalAmount'] ?? 0;
                        final String date = order['createdAt'] != null
                            ? order['createdAt'].toString().substring(0, 10)
                            : '';

                        Color statusColor = Colors.orange;
                        if (status == 'Delivered') statusColor = Colors.green;
                        if (status == 'Cancelled') statusColor = Colors.red;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.receipt_long, color: statusColor, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId}',
                                      style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Date: $date • Status: $status',
                                      style: GoogleFonts.lexend(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹$totalAmount',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Date Format Helper
  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(isoString).toLocal();
      final List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final String month = months[dt.month - 1];
      final String hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
      final String minute = dt.minute.toString().padLeft(2, '0');
      final String period = dt.hour >= 12 ? 'PM' : 'AM';

      return '${dt.day} $month ${dt.year}, $hour:$minute $period';
    } catch (e) {
      return isoString.substring(0, 10);
    }
  }

  // Change Role Dialog
  void _showChangeRoleDialog(BuildContext context, String userId, String userName, String currentRole) {
    final String newRole = currentRole.toLowerCase() == 'admin' ? 'user' : 'admin';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change User Role', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to change $userName\'s role from "${currentRole.toUpperCase()}" to "${newRole.toUpperCase()}"?',
            style: GoogleFonts.lexend(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newRole == 'admin' ? Colors.red.shade600 : Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await context.read<AdminUserProvider>().updateUserRole(userId, newRole);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Role updated to ${newRole.toUpperCase()} successfully!'
                            : 'Failed to update role.',
                        style: GoogleFonts.lexend(),
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Make ${newRole.toUpperCase()}', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Users Management',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Refresh Users',
            onPressed: () {
              context.read<AdminUserProvider>().fetchAdminUsers();
            },
          ),
        ],
      ),
      body: Consumer<AdminUserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null && userProvider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    userProvider.error!,
                    style: GoogleFonts.lexend(color: Colors.grey[700], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => userProvider.fetchAdminUsers(),
                    icon: const Icon(Icons.refresh),
                    label: Text('Try Again', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          final allUsers = userProvider.users;
          final totalUsersCount = allUsers.length;
          final adminCount = allUsers.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'admin').length;
          final regularCount = totalUsersCount - adminCount;

          // Filtering users based on search & role filter
          final filteredUsers = allUsers.where((user) {
            final name = (user['name'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final role = (user['role'] ?? 'user').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();

            bool matchesSearch = name.contains(query) || email.contains(query);
            bool matchesFilter = true;
            if (_selectedFilter == 'Admin') {
              matchesFilter = role == 'admin';
            } else if (_selectedFilter == 'User') {
              matchesFilter = role != 'admin';
            }
            return matchesSearch && matchesFilter;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => userProvider.fetchAdminUsers(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stats Overview Cards
                  _buildAnimatedSection(
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Users',
                            count: '$totalUsersCount',
                            icon: Icons.people_outline,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Admins',
                            count: '$adminCount',
                            icon: Icons.admin_panel_settings_outlined,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Customers',
                            count: '$regularCount',
                            icon: Icons.person_outline,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    delayMs: 0,
                  ),

                  const SizedBox(height: 20),

                  // 2. Search & Filter Bar
                  _buildAnimatedSection(
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search user by name or email...',
                              hintStyle: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Role Filter Chips
                          Row(
                            children: [
                              Text('Filter:', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(width: 10),
                              _buildFilterChip('All', totalUsersCount),
                              const SizedBox(width: 8),
                              _buildFilterChip('Admin', adminCount),
                              const SizedBox(width: 8),
                              _buildFilterChip('User', regularCount),
                            ],
                          ),
                        ],
                      ),
                    ),
                    delayMs: 100,
                  ),

                  const SizedBox(height: 20),

                  // 3. User List / Table Section
                  _buildAnimatedSection(
                    filteredUsers.isEmpty
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? 'No users found.' : 'No users match your search.',
                            style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final String userId = user['_id'] ?? '';
                        final String name = user['name'] ?? 'No Name';
                        final String email = user['email'] ?? 'No Email';
                        final String role = user['role'] ?? 'user';
                        final String? profilePic = user['profilePic'];
                        final int totalOrders = user['totalOrders'] ?? 0;
                        final bool isAdmin = role.toLowerCase() == 'admin';
                        final String createdAt = user['createdAt'] ?? '';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar / Initials
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isAdmin ? Colors.red.shade50 : Colors.teal.shade50,
                                backgroundImage: profilePic != null && profilePic.isNotEmpty
                                    ? NetworkImage(profilePic)
                                    : null,
                                child: profilePic == null || profilePic.isEmpty
                                    ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isAdmin ? Colors.red.shade700 : Colors.teal.shade700,
                                  ),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.lexend(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Role Badge (Clickable to Edit)
                                        InkWell(
                                          onTap: () => _showChangeRoleDialog(context, userId, name, role),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isAdmin ? Colors.red.shade50 : Colors.teal.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isAdmin ? Colors.red.shade200 : Colors.teal.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  role.toUpperCase(),
                                                  style: GoogleFonts.lexend(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isAdmin ? Colors.red.shade700 : Colors.teal.shade700,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 10,
                                                  color: isAdmin ? Colors.red.shade700 : Colors.teal.shade700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      email,
                                      style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Joined: ${_formatDate(createdAt)}',
                                          style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Orders Count & View Orders Action Button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Text(
                                      '$totalOrders Orders',
                                      style: GoogleFonts.lexend(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () => _showUserOrdersSheet(context, userId, name),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      'View Orders',
                                      style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    delayMs: 200,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Filter Chip Widget
  Widget _buildFilterChip(String label, int count) {
    bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
