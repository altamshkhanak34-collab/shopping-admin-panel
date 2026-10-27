
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_project/screens/top_categories_screen.dart';
import 'package:new_flutter_project/screens/top_products_screen.dart';
import 'package:new_flutter_project/widgets/profit_loss_card.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/admin_stats_provider.dart';
import '../widgets/revenue_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statsProvider = Provider.of<AdminStatsProvider>(context, listen: false);
      statsProvider.fetchAdminStats();
      statsProvider.fetchLowStockProducts();
      statsProvider.fetchRecentOrders();
      statsProvider.fetchSalesAnalytics();
      statsProvider.fetchOrderStatusAnalytics();
      statsProvider.fetchTopProducts();
      statsProvider.fetchTopCategories();
      statsProvider.fetchProfitAndLossAnalytics();
      statsProvider.fetchUserStats();
    });
  }


  void _showProductDetailsDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['thumbnail'] ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product['title'] ?? 'Product Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product['description'] != null) ...[
                Text('Description', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(product['description'], style: GoogleFonts.lexend(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailItem('Price', '₹${product['price'] ?? 0}'),
                  _detailItem('Original Price', '₹${product['originalPrice'] ?? 'N/A'}'),
                  _detailItem('Discount', '${product['discountPercentage'] ?? 0}%'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailItem('Stock Left', '${product['stock'] ?? 0}', isRed: true),
                  _detailItem('Category', '${product['categorySlug'] ?? 'N/A'}'),
                  _detailItem('SubCategory', '${product['subCategorySlug'] ?? 'N/A'}'),
                ],
              ),
              const SizedBox(height: 12),
              if (product['slug'] != null) ...[
                Text('Slug: ${product['slug']}', style: GoogleFonts.lexend(fontSize: 11, color: Colors.grey)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              final statsProvider = Provider.of<AdminStatsProvider>(context, listen: false);
              statsProvider.fetchAdminStats();
              statsProvider.fetchLowStockProducts();
              statsProvider.fetchRecentOrders();
              statsProvider.fetchOrderStatusAnalytics();
              statsProvider.fetchTopProducts();
              statsProvider.fetchTopCategories();
              statsProvider.fetchProfitAndLossAnalytics();
              statsProvider.fetchUserStats();

              // Active chart ke hisaab se analytics refresh karna
              if (statsProvider.isMonthlyChart) {
                statsProvider.fetchMonthlySalesAnalytics();
              } else {
                statsProvider.fetchSalesAnalytics();
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.stats['totalOrders'] == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.stats['totalOrders'] == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.error!,
                  style: GoogleFonts.lexend(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final stats = provider.stats;
          final lowStockList = provider.lowStockProducts;

          return RefreshIndicator(
            onRefresh: () async {
              final statsProvider = Provider.of<AdminStatsProvider>(context, listen: false);
              await statsProvider.fetchAdminStats();
              await statsProvider.fetchLowStockProducts();
              await statsProvider.fetchRecentOrders();
              await statsProvider.fetchOrderStatusAnalytics();
              await statsProvider.fetchTopProducts();
              await statsProvider.fetchTopCategories();
              await statsProvider.fetchProfitAndLossAnalytics();
              await statsProvider.fetchUserStats();

              // Active chart ke hisaab se analytics refresh karna
              if (statsProvider.isMonthlyChart) {
                await statsProvider.fetchMonthlySalesAnalytics();
              } else {
                await statsProvider.fetchSalesAnalytics();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Banner Card
                  _buildAnimatedSection(
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'STORE ONLINE • LIVE',
                                      style: GoogleFonts.lexend(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF34D399),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Welcome back, Admin 👋',
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Here is your live store performance & analytics overview.',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.insights_rounded,
                              color: Color(0xFFF59E0B),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    delayMs: 0,
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedSection(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Overview',
                            style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 1. Horizontal Scrollable Stats Cards
                        SizedBox(
                          height: 130, // Cards ki fix height
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              _buildHorizontalStatCard(
                                title: 'Total Revenue',
                                value: '₹${stats['totalRevenue'] ?? 0}',
                                icon: Icons.currency_rupee,
                                color: Colors.green,
                              ),
                              _buildHorizontalStatCard(
                                title: 'Total Orders',
                                value: '${stats['totalOrders'] ?? 0}',
                                icon: Icons.shopping_bag,
                                color: Colors.orange,
                              ),
                              _buildHorizontalStatCard(
                                title: 'Total Products',
                                value: '${stats['totalProducts'] ?? 0}',
                                icon: Icons.inventory_2,
                                color: Colors.blue,
                              ),
                              _buildHorizontalStatCard(
                                title: 'Total Users',
                                value: '${stats['totalUsers'] ?? 0}',
                                icon: Icons.people,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    delayMs: 0,
                  ),

                  const SizedBox(height: 20,),



                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 800;

                      Widget profitLossWidget = const ProfitLossCard();

                      Widget userActivityWidget = Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'User Activity Overview',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Line Chart
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey.shade500),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: 1, // 👈 Isse labels repeat nahi honge
                                        getTitlesWidget: (value, meta) {
                                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                days[value.toInt()],
                                                style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey.shade500),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: ((provider.activeUsersCount > 200 ? provider.activeUsersCount : 200)).toDouble(),
                                  lineBarsData: [
                                    // 🟢 Active Users Line (Gradient with Green)
                                    LineChartBarData(
                                      spots: [
                                        const FlSpot(0, 100),
                                        const FlSpot(1, 130),
                                        const FlSpot(2, 120),
                                        const FlSpot(3, 150),
                                        const FlSpot(4, 140),
                                        const FlSpot(5, 170),
                                        FlSpot(6, provider.activeUsersCount.toDouble()), // Dynamic Live Count
                                      ],
                                      isCurved: true,
                                      color: const Color(0xFF10B981),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF10B981).withOpacity(0.3),
                                            const Color(0xFF10B981).withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),

                                    // 🔴 Inactive Users Line (Gradient with Red)
                                    LineChartBarData(
                                      spots: [
                                        const FlSpot(0, 25),
                                        const FlSpot(1, 20),
                                        const FlSpot(2, 22),
                                        const FlSpot(3, 18),
                                        const FlSpot(4, 19),
                                        const FlSpot(5, 15),
                                        FlSpot(6, provider.inactiveUsersCount.toDouble()), // Dynamic Live Count
                                      ],
                                      isCurved: true,
                                      color: const Color(0xFFEF4444),
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFEF4444).withOpacity(0.2),
                                            const Color(0xFFEF4444).withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Legends Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendIndicator(
                                  color: const Color(0xFF10B981),
                                  text: 'Active Users (${provider.activeUsersCount})',
                                ),
                                const SizedBox(width: 24),
                                _buildLegendIndicator(
                                  color: const Color(0xFFEF4444),
                                  text: 'Inactive Users (${provider.inactiveUsersCount})',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: profitLossWidget),
                            const SizedBox(width: 16),
                            Expanded(child: userActivityWidget),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profitLossWidget,
                            const SizedBox(height: 16),
                            userActivityWidget,
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20,),



                  _buildAnimatedSection(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Low Stock Alerts Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Low Stock Alerts',
                                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              if (lowStockList.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${lowStockList.length} Items',
                                    style: GoogleFonts.lexend(fontSize: 12, color: Colors.red.shade800, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: lowStockList.isEmpty
                              ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: Text(
                                'All products have sufficient stock! 🎉',
                                style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 14),
                              ),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: lowStockList.length,
                            itemBuilder: (context, index) {
                              final product = lowStockList[index];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.red.shade100),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    // 👈 Product ki full details show karne ke liye Dialog / BottomSheet open hoga
                                    _showProductDetailsDialog(context, product);
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['thumbnail'] ?? '',
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                        backgroundColor: Colors.red.shade50,
                                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product['title'] ?? 'Unnamed Product',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Stock Left: ${product['stock'] ?? 0}',
                                    style: GoogleFonts.lexend(color: Colors.red, fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '₹${product['price'] ?? 0}',
                                    style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    delayMs: 200,
                  ),

                  const SizedBox(height: 24),

                  _buildAnimatedSection(
                    // 3. Recent Orders Section Header
                    // 3 & 4. Recent Orders & Sales Analytics Side-by-Side (Wide/Tablet View ya Row Layout)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Agar screen width 800 pixels se zyada hai (Tablet/Desktop), toh side-by-side dikhayein
                        bool isWideScreen = constraints.maxWidth > 800;

                        Widget recentOrdersSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Orders',
                                  style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                // TextButton(
                                //   onPressed: () {
                                //     // TODO: Navigate to All Orders Screen
                                //   },
                                //   child: Text(
                                //     'View All',
                                //     style: GoogleFonts.lexend(color: Colors.blue, fontWeight: FontWeight.w600),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            provider.recentOrders.isEmpty
                                ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Center(
                                child: Text(
                                  'No recent orders found.',
                                  style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.recentOrders.length,
                              itemBuilder: (context, index) {
                                final OrderModel order = provider.recentOrders[index];
                                final userName = order.userName ?? 'Guest User';
                                final totalAmount = order.finalAmount;
                                final orderStatus = order.orderStatus;

                                final firstItem = order.items.isNotEmpty ? order.items.first : null;
                                final productTitle = firstItem?.title ?? 'Order Item';
                                final productImage = firstItem?.thumbnail ?? '';
                                final quantity = firstItem?.quantity ?? 1;
                                final moreItemsCount = order.items.length > 1 ? order.items.length - 1 : 0;

                                Color statusColor = Colors.orange;
                                if (orderStatus == 'Delivered') statusColor = Colors.green;
                                if (orderStatus == 'Cancelled') statusColor = Colors.red;
                                if (orderStatus == 'Shipped') statusColor = Colors.blue;

                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Order #${order.id.length >= 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase()}',
                                              style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                orderStatus,
                                                style: GoogleFonts.lexend(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 16),
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade100,
                                                child: productImage.isNotEmpty
                                                    ? Image.network(
                                                  productImage,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                                )
                                                    : const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          productTitle,
                                                          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (moreItemsCount > 0)
                                                        Text(
                                                          ' +$moreItemsCount more',
                                                          style: GoogleFonts.lexend(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Qty: $quantity | Customer: $userName',
                                                    style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total: ₹$totalAmount',
                                              style: GoogleFonts.lexend(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: Text('Details', style: GoogleFonts.lexend(fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );

                        Widget salesAnalyticsSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'Sales Analytics',
                            //   style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            // ),
                            // const SizedBox(height: 12),
                            // 4. Sales Analytics Section Header
                            // 1. Chart Section Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    // Image ke anusar header badla gaya hai, isMonthlyChart condition ka upyog karte hue
                                    provider.isMonthlyChart
                                        ? 'Monthly Sales Overview (${DateTime.now().year})'
                                        : 'Sales Overview',
                                    style: GoogleFonts.lexend(
                                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  // Image ke anusar, yahan ek modernDropdown jaisa ToggleButton logic lagate hain
                                  Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.01),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButton<String>(
                                      value: provider.isMonthlyChart ? 'This Year' : 'Last 7 Days',
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                          size: 16, color: Colors.grey),
                                      elevation: 1,
                                      style: GoogleFonts.lexend(
                                          fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                                      underline: const SizedBox(),
                                      onChanged: (String? newValue) {
                                        bool isMonthly = newValue == 'This Year';
                                        provider.toggleChartType(isMonthly);
                                      },
                                      items: <String>['Last 7 Days', 'This Year']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),


                            const SizedBox(height: 12),

// 2. Sales Overview Card (Naya Modern Design)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
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
                                child: Column(
                                  children: [
                                    // Content Loading State
                                    if ((provider.isMonthlyChart && provider.monthlyAnalytics.isEmpty) ||
                                        (!provider.isMonthlyChart && provider.salesAnalytics.isEmpty))
                                      const SizedBox(
                                        height: 200,
                                        child: Center(child: CircularProgressIndicator()),
                                      ),

                                    // Chart with Points & Gradients
                                    if (!((provider.isMonthlyChart && provider.monthlyAnalytics.isEmpty) ||
                                        (!provider.isMonthlyChart && provider.salesAnalytics.isEmpty)))
                                      SizedBox(
                                        height: 200, // Height image ke anusar adjust ki gayi hai
                                        child: LineChart(
                                          LineChartData(
                                            minY: 0,
                                            // MaxY ko dynamic calculate karte hain aur image ke design ke liye headroom dete hain
                                            maxY: (() {
                                              final currentList = provider.isMonthlyChart
                                                  ? provider.monthlyAnalytics
                                                  : provider.salesAnalytics;
                                              double maxVal = 1000.0; // Minimal scaling
                                              for (var item in currentList) {
                                                double rev = (item['revenue'] as num?)?.toDouble() ?? 0.0;
                                                if (rev > maxVal) maxVal = rev;
                                              }
                                              return maxVal * 1.3; // Gradients aur points ke liye kafi headspace
                                            })(),
                                            // Interaction data - modern design
                                            lineTouchData: LineTouchData(
                                              handleBuiltInTouches: true,
                                              touchTooltipData: LineTouchTooltipData(
                                                getTooltipColor: (LineBarSpot touchedSpot) => Colors.black.withOpacity(0.85),
                                                tooltipRoundedRadius: 8,
                                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                                  return touchedSpots.map((LineBarSpot touchedSpot) {
                                                    final currentList = provider.isMonthlyChart
                                                        ? provider.monthlyAnalytics
                                                        : provider.salesAnalytics;
                                                    final data = currentList[touchedSpot.x.toInt()];
                                                    final label =
                                                    provider.isMonthlyChart ? data['month'] : data['day'];
                                                    return LineTooltipItem(
                                                      '$label\n₹${touchedSpot.y.toInt()}',
                                                      GoogleFonts.lexend(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                            // Axes titles & formatting - Clean look from image
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              // Image ke anusar Left titles ko numbers ke saath clean format me rakhte hain
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 32,
                                                  getTitlesWidget: (value, meta) {
                                                    // Image ke anusar, kuch select numbers hi dikhate hain
                                                    if (value % 1000 != 0 || value == 0) return const SizedBox();
                                                    return Text(
                                                      '${(value / 1000).toInt()}L', // For thousands, or adjust for millions if needed
                                                      style: GoogleFonts.lexend(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.grey.shade600),
                                                    );
                                                  },
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                  interval: 1, // Ensure every label is shown
                                                  getTitlesWidget: (double value, TitleMeta meta) {
                                                    final currentList = provider.isMonthlyChart
                                                        ? provider.monthlyAnalytics
                                                        : provider.salesAnalytics;
                                                    if (value.toInt() >= 0 &&
                                                        value.toInt() < currentList.length) {
                                                      final labelName = provider.isMonthlyChart
                                                          ? currentList[value.toInt()]['month'] ?? ''
                                                          : currentList[value.toInt()]['day'] ?? '';
                                                      return SideTitleWidget(

                                                        space: 8,
                                                        meta: meta,
                                                        child: Text(
                                                          labelName,
                                                          style: GoogleFonts.lexend(
                                                            fontSize: provider.isMonthlyChart ? 8 : 11,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.grey.shade700,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                ),
                                              ),
                                            ),
                                            // Grid details - Minimal from image
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              getDrawingHorizontalLine: (value) {
                                                return FlLine(
                                                  color: Colors.grey.shade200,
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            // Outer border - None for clean look
                                            borderData: FlBorderData(show: false),
                                            // Main Line Chart data points
                                            lineBarsData: [
                                              LineChartBarData(
                                                // Image design elements
                                                spots: (() {
                                                  final currentList = provider.isMonthlyChart
                                                      ? provider.monthlyAnalytics
                                                      : provider.salesAnalytics;
                                                  return currentList.asMap().entries.map((entry) {
                                                    int index = entry.key;
                                                    var data = entry.value;
                                                    double revenue =
                                                        (data['revenue'] as num?)?.toDouble() ?? 0.0;
                                                    return FlSpot(index.toDouble(), revenue);
                                                  }).toList();
                                                })(),
                                                isCurved: true, // Smooth Curves as in image
                                                color: const Color(0xff7F00FF), // Primary chart color from image
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: true, // Show dots as points in the line
                                                  getDotPainter: (spot, percent, barData, index) {
                                                    // All dots have points as seen in the image
                                                    return FlDotCirclePainter(
                                                      radius: 4,
                                                      color: const Color(0xff7F00FF),
                                                      strokeWidth: 2,
                                                      strokeColor: Colors.white,
                                                    );
                                                  },
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xff7F00FF).withOpacity(0.2), // Gradient from points down
                                                      const Color(0xff7F00FF).withOpacity(0.0), // Fades to zero
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(milliseconds: 1000), // 👈 swapAnimationDuration ki jagah duration use karein
                                          curve: Curves.easeInOutQuart,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
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
                                child: provider.isOrderStatusLoading
                                    ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Status',
                                      style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        // Donut Chart
                                        Expanded(
                                          flex: 5,
                                          child: SizedBox(
                                            height: 180,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                TweenAnimationBuilder<double>(
                                                  // Value key dene se jab bhi totalOrders badlega/refresh hoga, animation dubara chalega
                                                  key: ValueKey(provider.orderStatusData['totalOrders']),
                                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                                  duration: const Duration(milliseconds: 1200),
                                                  curve: Curves.easeOutBack, // Bouncy rotation effect
                                                  builder: (context, animValue, child) {
                                                    return Transform.scale(
                                                      scale: animValue, // Smooth Zoom-in Effect
                                                      child: Transform.rotate(
                                                        angle: (1 - animValue) * -3.14159, // Smooth 180-degree Rotation
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: PieChart(
                                                    PieChartData(
                                                      sectionsSpace: 2,
                                                      centerSpaceRadius: 55,
                                                      startDegreeOffset: 270,
                                                      sections: (() {
                                                        final List statuses = provider.orderStatusData['statusCounts'] ?? [];
                                                        if (statuses.isEmpty) {
                                                          return [
                                                            PieChartSectionData(color: Colors.grey.shade300, value: 100, radius: 22, showTitle: false)
                                                          ];
                                                        }

                                                        // Status ke hisaab se colors mapping
                                                        final colors = {
                                                          'Delivered': Colors.teal,
                                                          'Shipped': Colors.blue,
                                                          'Packed': Colors.amber,
                                                          'Confirmed': Colors.purple,
                                                          'Pending': Colors.pink,
                                                        };

                                                        return statuses.map((item) {
                                                          double count = (item['count'] as num).toDouble();
                                                          return PieChartSectionData(
                                                            color: colors[item['status']] ?? Colors.grey,
                                                            value: count == 0 ? 0.1 : count,
                                                            radius: 22,
                                                            showTitle: false,
                                                          );
                                                        }).toList();
                                                      })(),
                                                    ),

                                                  ),
                                                ),
                                                // Center Text (Total Orders)
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${provider.orderStatusData['totalOrders'] ?? 0}',
                                                      style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                                    ),
                                                    Text(
                                                      'Total Orders',
                                                      style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Side Legend List (Delivered, Shipped, etc.)
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: (() {
                                              final List statuses = provider.orderStatusData['statusCounts'] ?? [];
                                              final colors = {
                                                'Delivered': Colors.teal,
                                                'Shipped': Colors.blue,
                                                'Packed': Colors.amber,
                                                'Confirmed': Colors.purple,
                                                'Pending': Colors.pink,
                                              };

                                              if (statuses.isEmpty) {
                                                return [const Text('No data available', style: TextStyle(fontSize: 12, color: Colors.grey))];
                                              }

                                              return statuses.map<Widget>((item) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: colors[item['status']] ?? Colors.grey,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            item['status'],
                                                            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${item['count']} (${item['percentage']}%)',
                                                        style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList();
                                            })(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 4. Revenue Trends Card (Donut Chart ke theek neeche)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: RevenueTrendsCard(),
                            ),

                            const SizedBox(height: 20),

                          ],
                        );

                        // Agar screen wide hai (jaise tablet/desktop), toh side-by-side row layout, nahi toh vertical column layout
                        if (isWideScreen) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: recentOrdersSection),
                              const SizedBox(width: 16),
                              Expanded(child: salesAnalyticsSection),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrdersSection,
                              const SizedBox(height: 24),
                              salesAnalyticsSection,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  delayMs: 300,
                ),


                  _buildAnimatedSection(
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isWideScreen = constraints.maxWidth > 800;

                        Widget topProductsWidget = Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Selling Products',
                                  style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TopProductsScreen()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'View All',
                                        style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            provider.isTopProductsLoading
                                ? const SizedBox(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            )
                                : provider.topProducts.isEmpty
                                ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text('No products sold yet', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                            )
                                : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.topProducts.length > 5 ? 5 : provider.topProducts.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final product = provider.topProducts[index];
                                final int maxSold = provider.topProducts.isNotEmpty
                                    ? (provider.topProducts[0]['totalSold'] ?? 1)
                                    : 1;
                                final int currentSold = product['totalSold'] ?? 0;
                                double progress = maxSold > 0 ? (currentSold / maxSold).clamp(0.0, 1.0) : 0.0;

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              product['thumbnail'] ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.image_not_supported,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['title'] ?? 'Unknown Product',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$currentSold sold',
                                                style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '₹${product['price']?.toStringAsFixed(0) ?? product['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                                          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade100,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                                        minHeight: 3,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );

                      Widget topCategoriesWidget = Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Categories',
                                  style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TopCategoriesScreen()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'View All',
                                        style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            provider.isTopCategoriesLoading
                                ? const SizedBox(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            )
                                : provider.topCategories.isEmpty
                                ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text('No category data available', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                            )
                                : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.topCategories.length > 5 ? 5 : provider.topCategories.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final category = provider.topCategories[index];
                                final int maxSold = provider.topCategories.isNotEmpty
                                    ? (provider.topCategories[0]['totalSold'] ?? 1)
                                    : 1;
                                final int currentSold = category['totalSold'] ?? 0;
                                double progress = maxSold > 0 ? (currentSold / maxSold).clamp(0.0, 1.0) : 0.0;

                                // Image URL check kar rahe hain backend response ke hisaab se
                                final String imageUrl = category['image'] ?? '';

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            // Category Image Container
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: imageUrl.isNotEmpty
                                                    ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Icon(
                                                    Icons.category_outlined,
                                                    size: 18,
                                                    color: Colors.teal.shade700,
                                                  ),
                                                )
                                                    : Icon(
                                                  Icons.category_outlined,
                                                  size: 18,
                                                  color: Colors.teal.shade700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  category['name']?.toString().toUpperCase() ?? category['_id']?.toString().toUpperCase() ?? 'UNKNOWN',
                                                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '$currentSold items sold',
                                                  style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '₹${category['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                                          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade100,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                                        minHeight: 3,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );

                      if (isWideScreen) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: topProductsWidget),
                              const SizedBox(width: 16),
                              Expanded(child: topCategoriesWidget),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              topProductsWidget,
                              const SizedBox(height: 16),
                              topCategoriesWidget,
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  delayMs: 400,
                ),

                  // Dashboard UI ke andar:










                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _detailItem(String label, String value, {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isRed ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Modern Horizontal Scrollable Stat Card Widget
  Widget _buildHorizontalStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward, size: 10, color: Colors.green),
                    const SizedBox(width: 2),
                    Text(
                      '+12%',
                      style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Legend Helper Widget
  Widget _buildLegendIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Modern Staggered Entry Animation Helper Widget
  Widget _buildAnimatedSection(Widget child, {int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

}








