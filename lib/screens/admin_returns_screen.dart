import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_order_provider.dart';
import '../models/order_model.dart';

class AdminReturnsScreen extends StatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  State<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends State<AdminReturnsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<AdminOrderProvider>(context, listen: false).fetchReturnRequests();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Return Requested':
        return const Color(0xFFF59E0B); // Amber
      case 'Return Approved':
        return const Color(0xFF3B82F6); // Blue
      case 'Returned':
        return const Color(0xFF10B981); // Emerald
      case 'Return Rejected':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Modern Styled Dialog: Return Approve / Reject
  void _showReturnActionDialog(BuildContext context, OrderModel order, String status) {
    final commentController = TextEditingController();
    final isApprove = status == 'APPROVED';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isApprove ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApprove ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isApprove ? 'Approve Return' : 'Reject Return',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
              style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Admin Comment / Reason',
                hintText: isApprove
                    ? 'e.g. Return pickup scheduled for tomorrow'
                    : 'e.g. Return window expired or item damaged by user',
                labelStyle: GoogleFonts.lexend(color: Colors.grey.shade600),
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isApprove ? Colors.green : Colors.red),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              final provider = Provider.of<AdminOrderProvider>(context, listen: false);
              final success = await provider.processReturnRequest(
                orderId: order.id,
                status: status,
                adminComment: commentController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      success ? 'Return request updated!' : 'Action failed. Try again.',
                      style: GoogleFonts.lexend(),
                    ),
                    backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                  ),
                );
              }
            },
            child: Text('Confirm ${isApprove ? "Approve" : "Reject"}',
                style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Modern Styled Dialog: Issue Refund
  void _showRefundDialog(BuildContext context, OrderModel order) {
    final amountController = TextEditingController(text: order.finalAmount.toString());
    final txnController = TextEditingController(text: 'TXN_REFUND_${DateTime.now().millisecondsSinceEpoch}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
              child: Icon(Icons.account_balance_wallet_rounded, color: Colors.purple.shade700),
            ),
            const SizedBox(width: 12),
            Text('Issue Refund', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Refund Amount (₹)',
                prefixText: '₹ ',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: txnController,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Transaction Reference / ID',
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.lexend(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              final provider = Provider.of<AdminOrderProvider>(context, listen: false);
              final success = await provider.processRefund(
                orderId: order.id,
                refundAmount: double.tryParse(amountController.text) ?? order.finalAmount,
                transactionId: txnController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      success ? 'Refund processed successfully!' : 'Refund failed',
                      style: GoogleFonts.lexend(),
                    ),
                    backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                  ),
                );
              }
            },
            child: Text('Process Refund',
                style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Returns & Refunds',
          style: GoogleFonts.lexend(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1F2937)),
            onPressed: () => Provider.of<AdminOrderProvider>(context, listen: false).fetchReturnRequests(),
          )
        ],
      ),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          final returns = provider.returnRequests;

          if (returns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Return Requests Found',
                    style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All user returns and refunds are processed.',
                    style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final order = returns[index];
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
                      // Header Row: Order ID & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, size: 18, color: Color(0xFF374151)),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ORDER #${order.id.substring(order.id.length - 6).toUpperCase()}',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    'Amount: ₹${order.finalAmount}',
                                    style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              order.orderStatus,
                              style: GoogleFonts.lexend(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ),

                      // 🛍️ PRODUCT DETAILS SECTION
                      Text(
                        'RETURNED ITEMS (${order.items.length})',
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.thumbnail,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image_not_supported_outlined, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                      const SizedBox(height: 2),
                                      Text(
                                        'Qty: ${item.quantity}  •  Price: ₹${item.price}',
                                        style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 8),

                      // Customer Info & Return Reason Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB), // Soft Yellow accent
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${order.userName ?? "Customer"} (${order.address.mobile})',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF78350F)),
                                children: [
                                  const TextSpan(text: 'Reason: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: order.returnReason ?? 'Not specified'),
                                ],
                              ),
                            ),
                            if (order.returnComment != null && order.returnComment!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${order.returnComment}"',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (order.adminComment != null && order.adminComment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Admin Note: ${order.adminComment}',
                            style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // 🎯 ACTION BUTTONS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (order.orderStatus == 'Return Requested') ...[
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(color: Color(0xFFFCA5A5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: () => _showReturnActionDialog(context, order, 'REJECTED'),
                              child: Text('Reject', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: () => _showReturnActionDialog(context, order, 'APPROVED'),
                              child: Text('Approve Return',
                                  style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          if (order.orderStatus == 'Return Approved') ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              icon: const Icon(Icons.currency_rupee, color: Colors.white, size: 16),
                              label: Text('Issue Refund',
                                  style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () => _showRefundDialog(context, order),
                            ),
                          ],
                          if (order.orderStatus == 'Returned' && order.refundDetails != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Refunded: ₹${order.refundDetails!.refundAmount} (${order.refundDetails!.transactionId})',
                                    style: GoogleFonts.lexend(
                                      color: const Color(0xFF047857),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]
                        ],
                      ),




                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      //   width: double.infinity,
                      //   height: 140,
                      //   decoration: BoxDecoration(
                      //
                      //     color: Colors.blue,
                      //   ),
                      //   child: Column(
                      //
                      //     children: [
                      //
                      //       Text("Hii this is a admin riplay"),
                      //
                      //     ],
                      //   ),
                      // ),// ye abhi dummy hai isko bad me hata bhi sakte hai

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}