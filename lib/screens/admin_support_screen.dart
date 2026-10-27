import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_support_provider.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> with SingleTickerProviderStateMixin {
  String _selectedStatus = 'ALL';
  final String _selectedPriority = 'ALL';
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTickets());

    // Blinking dot animation controller for unread/new messages
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  Future<void> _loadTickets() async {
    final provider = Provider.of<AdminSupportProvider>(context, listen: false);
    await provider.fetchAllTickets(
      status: _selectedStatus,
      priority: _selectedPriority,
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        return Colors.red;
      case 'MEDIUM':
        return Colors.amber.shade800;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _openChatBottomSheet(BuildContext context, Map<String, dynamic> ticket) {
    final provider = Provider.of<AdminSupportProvider>(context, listen: false);
    final String ticketDbId = ticket['_id'] ?? ticket['id'] ?? '';

    if (ticketDbId.isNotEmpty) {
      provider.fetchTicketDetails(ticketDbId);
    }

    final TextEditingController replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<AdminSupportProvider>(
          builder: (context, p, _) {
            final details = p.selectedTicket ?? ticket;
            final List messages = details['messages'] ?? [];
            final String currentStatus = details['status'] ?? 'OPEN';
            final String currentPriority = details['priority'] ?? 'MEDIUM';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.82,
                child: Column(
                  children: [
                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details['ticketId'] ?? 'Ticket Details',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                details['subject'] ?? 'No Subject',
                                style: GoogleFonts.lexend(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status & Priority Selectors Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text('Status: ', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                              DropdownButton<String>(
                                value: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].contains(currentStatus)
                                    ? currentStatus
                                    : 'OPEN',
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, size: 18),
                                items: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(s),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    provider.updateStatus(ticketDbId, val);
                                  }
                                },
                              ),
                            ],
                          ),
                          Container(height: 20, width: 1, color: Colors.grey.shade300),
                          Row(
                            children: [
                              Text('Priority: ', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                              DropdownButton<String>(
                                value: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'].contains(currentPriority)
                                    ? currentPriority
                                    : 'MEDIUM',
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, size: 18),
                                items: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'].map((pr) {
                                  return DropdownMenuItem(
                                    value: pr,
                                    child: Text(
                                      pr,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getPriorityColor(pr),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    provider.updatePriority(ticketDbId, val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    // Chat Messages List
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'No messages yet.',
                                style: GoogleFonts.lexend(color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final sender = (msg['sender'] ?? '').toString().toUpperCase();
                                final isAdmin = sender == 'ADMIN';

                                return Align(
                                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isAdmin ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(14),
                                        topRight: const Radius.circular(14),
                                        bottomLeft: Radius.circular(isAdmin ? 14 : 4),
                                        bottomRight: Radius.circular(isAdmin ? 4 : 14),
                                      ),
                                    ),
                                    child: Text(
                                      msg['text'] ?? '',
                                      style: GoogleFonts.lexend(
                                        color: isAdmin ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),

                    // Reply Input Field
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              style: GoogleFonts.lexend(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Type admin reply...',
                                hintStyle: GoogleFonts.lexend(fontSize: 13, color: Colors.grey.shade400),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            onPressed: () async {
                              final text = replyController.text.trim();
                              if (text.isNotEmpty) {
                                replyController.clear();
                                final success = await provider.sendAdminMessage(ticketDbId, text);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(provider.error ?? 'Failed to send message')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      final String hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
      final String minute = dt.minute.toString().padLeft(2, '0');
      final String period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month}/${dt.year} $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24.0),
      child: Consumer<AdminSupportProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Tickets Catalog',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage, track, and respond to customer support inquiries.',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent_rounded, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Total Tickets: ${provider.tickets.length}',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((st) {
                    final isSel = _selectedStatus == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ChoiceChip(
                        label: Text(
                          st,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        selected: isSel,
                        selectedColor: const Color(0xFF0F172A),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSel ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        onSelected: (val) {
                          setState(() => _selectedStatus = st);
                          provider.fetchAllTickets(status: _selectedStatus, priority: _selectedPriority);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Error State Banner
              if (provider.error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    provider.error!,
                    style: GoogleFonts.lexend(color: Colors.red.shade700, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Main Body Content
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.tickets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No support tickets found',
                                  style: GoogleFonts.lexend(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tickets created by users will appear here.',
                                  style: GoogleFonts.lexend(color: Colors.grey.shade400, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : Container(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: RefreshIndicator(
                                onRefresh: _loadTickets,
                                child: ListView.separated(
                                  itemCount: provider.tickets.length,
                                  padding: EdgeInsets.zero,
                                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  itemBuilder: (context, index) {
                                    final ticket = provider.tickets[index];

                                    final statusColor = _getStatusColor(ticket['status'] ?? '');
                                    final priorityColor = _getPriorityColor(ticket['priority'] ?? 'MEDIUM');

                                    final String ticketNum = ticket['ticketId'] ?? 'N/A';
                                    final String subject = ticket['subject'] ?? 'No Subject';
                                    final String userName = ticket['userId'] is Map
                                        ? (ticket['userId']['name'] ?? 'User')
                                        : 'User';
                                    final String category = ticket['category'] ?? 'General';
                                    final String createdAt = _formatDate(ticket['createdAt']);

                                    final List messages = ticket['messages'] is List ? ticket['messages'] : [];
                                    final bool isLastMessageFromUser = messages.isNotEmpty &&
                                        (messages.last['sender'] ?? '').toString().toUpperCase() == 'USER';
                                    final bool isTicketOpen = (ticket['status'] ?? '').toString().toUpperCase() != 'CLOSED';
                                    final bool hasNewMessage = isLastMessageFromUser && isTicketOpen;

                                    return InkWell(
                                      onTap: () => _openChatBottomSheet(context, ticket),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: hasNewMessage ? Colors.green.shade50.withValues(alpha: 0.4) : Colors.transparent,
                                        ),
                                        child: Row(
                                          children: [
                                            // Icon / Avatar
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(Icons.support_agent_rounded, color: Colors.blue.shade600, size: 20),
                                            ),
                                            const SizedBox(width: 16),

                                            // Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        ticketNum,
                                                        style: GoogleFonts.lexend(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                          color: const Color(0xFF0F172A),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          subject,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.lexend(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                            color: const Color(0xFF334155),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      // New Message Blinking Indicator & Badge
                                                      if (hasNewMessage) ...[
                                                        FadeTransition(
                                                          opacity: _blinkController,
                                                          child: Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.green,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green.shade100,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            'New Message',
                                                            style: GoogleFonts.lexend(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green.shade800,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                      ],
                                                      Text(
                                                        '$userName • $category',
                                                        style: GoogleFonts.lexend(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: BoxDecoration(
                                                          color: priorityColor,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        ticket['priority'] ?? 'MEDIUM',
                                                        style: GoogleFonts.lexend(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: priorityColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Date & Status badge
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (createdAt.isNotEmpty)
                                                  Text(
                                                    createdAt,
                                                    style: GoogleFonts.lexend(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade400,
                                                    ),
                                                  ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    ticket['status'] ?? '',
                                                    style: GoogleFonts.lexend(
                                                      color: statusColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
              ),


              // const SizedBox(height: 24),
              // Column(
              //   children: [
              //     CircleAvatar(),
              //     Text("Hii new item here",style: GoogleFonts.lexend(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
              //     const SizedBox(height: 10,),
              //     Container(
              //       padding: EdgeInsets.all(8),
              //       width: double.infinity,
              //       decoration: BoxDecoration(
              //         border: Border.all(color: Colors.green),
              //         borderRadius: BorderRadius.circular(28),
              //         color: Colors.amberAccent
              //       ),
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
