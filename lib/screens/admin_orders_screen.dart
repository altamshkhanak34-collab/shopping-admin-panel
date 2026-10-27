import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_order_provider.dart';
import '../models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatusFilter = 'All';

  final List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Packed',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
    'Return Requested',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<AdminOrderProvider>(context, listen: false).fetchAllOrders();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Confirmed':
        return const Color(0xFF3B82F6);
      case 'Packed':
        return const Color(0xFF8B5CF6);
      case 'Shipped':
        return const Color(0xFF6366F1);
      case 'Out for Delivery':
        return const Color(0xFFEC4899);
      case 'Delivered':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      case 'Return Requested':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showTrackingDialog(BuildContext context, OrderModel order) {
    final courierController = TextEditingController(text: order.courierPartner ?? '');
    final trackingIdController = TextEditingController(text: order.trackingId ?? '');
    final trackingUrlController = TextEditingController(text: order.trackingUrl ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: Icon(Icons.local_shipping_rounded, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Text('Tracking Info', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierController,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Courier Partner',
                hintText: 'e.g. BlueDart, Delhivery',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: trackingIdController,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Tracking ID / AWB Number',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: trackingUrlController,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Tracking URL',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              final provider = Provider.of<AdminOrderProvider>(context, listen: false);
              final success = await provider.updateTrackingInfo(
                orderId: order.id,
                courierPartner: courierController.text.trim(),
                trackingId: trackingIdController.text.trim(),
                trackingUrl: trackingUrlController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      success ? 'Tracking details updated!' : 'Failed to update tracking',
                      style: GoogleFonts.lexend(),
                    ),
                    backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                  ),
                );
              }
            },
            child: Text('Save Details', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }


  // 🗓️ Date & Time Format Helper
  String _formatDateTime(dynamic createdAt) {
    if (createdAt == null) return 'N/A';

    try {
      DateTime dt;
      if (createdAt is String) {
        dt = DateTime.parse(createdAt).toLocal();
      } else if (createdAt is DateTime) {
        dt = createdAt.toLocal();
      } else {
        return 'N/A';
      }

      // Example Output: 24 Oct 2026, 03:45 PM
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[dt.month - 1];
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';

      return '$day $month ${dt.year}, $hour:$minute $period';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Manage Orders',
          style: GoogleFonts.lexend(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1F2937)),
            onPressed: () => Provider.of<AdminOrderProvider>(context, listen: false).fetchAllOrders(),
          )
        ],
      ),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {

          // 🔴 ADD THIS BLOCK HERE: Real-time order notification trigger
          if (provider.hasNewOrderAlert && provider.latestIncomingOrder != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final newOrder = provider.latestIncomingOrder!;

              // 🟢 Pehle item ka name aur thumbnail nikal lein (agar items available hain)
              final firstItem = newOrder.items.isNotEmpty ? newOrder.items.first : null;
              final productName = firstItem?.title ?? 'New Product';
              final productImage = firstItem?.thumbnail ?? '';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      // 🖼️ Product Thumbnail Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          productImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 📦 Product Name & Amount Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎉 Naya Order Aaya Hai!',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              productName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Amount: ₹${newOrder.finalAmount}',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981), // Success Green
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );

              // Alert clear kar dein taaki dobara rebuild par popup na aaye
              provider.clearNewOrderAlert();
            });
          }


          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error loading orders', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(provider.error!, style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            );
          }

          List<OrderModel> displayedOrders = provider.orders;
          if (_selectedStatusFilter != 'All') {
            displayedOrders = displayedOrders.where((o) => o.orderStatus == _selectedStatusFilter).toList();
          }

          return Column(
            children: [
              // 🏷️ Status Filter Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['All', ..._statusOptions].map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      final count = status == 'All'
                          ? provider.orders.length
                          : provider.orders.where((o) => o.orderStatus == status).length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('$status ($count)'),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedStatusFilter = status),
                          selectedColor: const Color(0xFF111827),
                          backgroundColor: const Color(0xFFF3F4F6),
                          labelStyle: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 📦 Orders List
              Expanded(
                child: displayedOrders.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No orders found',
                          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedOrders.length,
                  itemBuilder: (context, index) {
                    final order = displayedOrders[index];
                    final statusColor = _getStatusColor(order.orderStatus);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Order ID & Status Dropdown
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 600;

                                final orderInfo = Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 18,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Order ID + Date
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${order.id.length >= 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id}',
                                          style: GoogleFonts.lexend(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDateTime(order.createdAt),
                                              style: GoogleFonts.lexend(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );

                                // Status Selector
                                final statusSelector = Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _statusOptions.contains(order.orderStatus)
                                          ? order.orderStatus
                                          : null,

                                      hint: Text(
                                        order.orderStatus,
                                        style: GoogleFonts.lexend(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),

                                      icon: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: statusColor,
                                      ),

                                      items: _statusOptions.map((st) {
                                        return DropdownMenuItem(
                                          value: st,
                                          child: Text(
                                            st,
                                            style: GoogleFonts.lexend(
                                              color: _getStatusColor(st),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),

                                      onChanged: (newStatus) async {
                                        if (newStatus != null &&
                                            newStatus != order.orderStatus) {

                                          final success =
                                          await provider.updateOrderStatus(
                                            order.id,
                                            newStatus,
                                          );

                                          if (context.mounted && !success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Status update failed!'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );

                                // 📱 Mobile
                                if (isMobile) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      orderInfo,
                                      const SizedBox(height: 12),
                                      statusSelector,
                                    ],
                                  );
                                }

                                // 💻 Tablet / Desktop
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    orderInfo,
                                    statusSelector,
                                  ],
                                );
                              },
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                            ),

                            // 🛍️ PRODUCT ITEMS DETAILS
                            Text(
                              'ORDERED ITEMS (${order.items.length})',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Column(
                              children: order.items.map((item) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      // Safe image fallback]
                                      GestureDetector(
                                        onTap: () {
                                          // 🟢 Image click par Dialog open karne ke liye
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: const EdgeInsets.all(10),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Badi Image jo beech me dikhegi
                                                  InteractiveViewer(
                                                    // Zoom-in aur Zoom-out karne ki facility ke liye
                                                    panEnabled: true,
                                                    boundaryMargin: const EdgeInsets.all(20),
                                                    minScale: 0.5,
                                                    maxScale: 4,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        item.thumbnail,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  // Close (X) Button upar right corner me
                                                  Positioned(
                                                    top: 20,
                                                    right: 20,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                      style: IconButton.styleFrom(
                                                        backgroundColor: Colors.black54,
                                                      ),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.thumbnail,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.image_not_supported_outlined, size: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: GoogleFonts.lexend(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: const Color(0xFF1F2937),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Qty: ${item.quantity}  •  ₹${item.price} each',
                                              style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '₹${item.price * item.quantity}',
                                        style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 8),

                            // 👤 CUSTOMER & ADDRESS DETAILS CARD
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person_rounded, size: 16, color: Color(0xFF4B5563)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${order.userName ?? "Customer"}  •  ${order.address.mobile}',
                                        style: GoogleFonts.lexend(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF4B5563)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${order.address.houseNo}, ${order.address.area}, ${order.address.city} - ${order.address.pincode}',
                                          style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF4B5563)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 💳 FOOTER: TOTAL & TRACKING ACTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Amount', style: GoogleFonts.lexend(fontSize: 11, color: Colors.grey.shade600)),
                                    Text(
                                      '₹${order.finalAmount}',
                                      style: GoogleFonts.lexend(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showTrackingDialog(context, order),
                                  icon: const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.white),
                                  label: Text('Tracking Info',
                                      style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF111827),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Column(
              //   children: [
              //     Row(
              //       children: [
              //         Container(
              //           padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              //           // width: double.infinity,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(20),
              //             border: Border.all(
              //               color: Colors.grey,
              //             ),
              //              color: Colors.orange.shade200
              //           ),
              //           child: Row(
              //             children: [
              //               CircleAvatar(),
              //               Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text("Hii new user is here"),
              //                   Text("Hii new Admin user is here"),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              //           // width: double.infinity,
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(20),
              //               border: Border.all(
              //                 color: Colors.grey,
              //               ),
              //               color: Colors.orange.shade200
              //           ),
              //           child: Row(
              //             children: [
              //               CircleAvatar(),
              //               Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text("Hii new user is here",style: GoogleFonts.lexend(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.blue),),
              //                   Text("Hii new Admin user is here",style: GoogleFonts.lexend(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.orangeAccent),),
              //                 ],
              //               ),
              //               Container(
              //                 height: 40,
              //                 width: 50,
              //                 decoration: BoxDecoration(
              //                   border: Border.all(
              //                     color: Colors.transparent
              //                   ),
              //                   color: Colors.orange.shade400,
              //                   borderRadius: BorderRadius.circular(20)
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //     Container(
              //       width: double.infinity,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(20),
              //         border: Border.all(color: Colors.black54)
              //       ),
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           CircleAvatar(),
              //           CircleAvatar(),
              //         ],
              //       ),
              //     ),
              //     Row(
              //       children: [
              //         Container(
              //           padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              //           height: 40,
              //           width: 40,
              //           decoration: BoxDecoration(
              //             color: Colors.black,
              //             border: Border.all(color: Colors.deepOrange),
              //             borderRadius: BorderRadius.circular(20)
              //           ),
              //           child: Column(
              //             children: [
              //             ],
              //           ),
              //         )
              //       ],
              //     )
              //   ],
              // )

            ],
          );
        },
      ),
    );
  }
}