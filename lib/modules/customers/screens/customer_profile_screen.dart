import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/billing_service.dart';
import '../../../services/accounts_service.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_wishlist_preview.dart';
import '../widgets/loyalty_progress.dart';

// ════════════════════════════════════════════════════════════════════
// CustomerProfileScreen — StatefulWidget
//
// Mirrors Electron renderCustomerProfile():
//  1. On open: fetch all invoices → filter by customerId/name
//     → build purchaseHistory list
//  2. On open: fetch all ledger entries → filter by party === customer.name
//     → compute running balance → build ledger list
//  3. Show live data in Ledger + Purchases tabs
// ════════════════════════════════════════════════════════════════════
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late Customer customer;
  bool _loadingExtra = true;

  // Live-fetched data (replaces the always-empty lists from customer model)
  List<LedgerEntry> _ledger = [];
  List<PurchaseHistoryItem> _purchases = [];
  int _totalSpend = 0;
  bool _hasOutstanding = false;
  String _outstandingDisplay = '₹0';

  @override
  void initState() {
    super.initState();
    customer = Get.arguments as Customer;
    _fetchLiveData();
  }

  // ── mirrors Electron: fetch invoices + ledger on profile open ──
  Future<void> _fetchLiveData() async {
    setState(() => _loadingExtra = true);
    await Future.wait([_fetchPurchases(), _fetchLedger()]);
    setState(() => _loadingExtra = false);
  }

  // mirrors Electron: invoices.list() → filter by customerId or name
  Future<void> _fetchPurchases() async {
    try {
      final r = await Get.find<BillingService>().listInvoices();
      if (!r.success || r.data is! List) return;

      final all = r.data as List;
      final custId = customer.backendId;

      final filtered = all.where((inv) {
        if (inv is! Map) return false;
        final idMatch = custId != null && inv['customerId'] == custId;
        final nameMatch =
            (inv['customer']?.toString() ??
                    inv['customerName']?.toString() ??
                    '')
                .toLowerCase() ==
            customer.name.toLowerCase();
        return idMatch || nameMatch;
      }).toList();

      const psMap = {
        'PAID': 'Paid',
        'PARTIAL': 'Partial',
        'PENDING': 'Pending',
        'CANCELLED': 'Cancelled',
      };

      final purchases = filtered.map((inv) {
        final items = (inv['items'] as List? ?? [])
            .map((it) => (it as Map)['name']?.toString() ?? 'Item')
            .join(', ');
        final total = (inv['total'] ?? inv['totalAmount'] ?? 0) as num;
        final status =
            psMap[inv['paymentStatus']?.toString()] ??
            psMap[inv['status']?.toString()] ??
            'Pending';
        return PurchaseHistoryItem(
          invoiceId:
              inv['invoiceNumber']?.toString() ?? inv['id']?.toString() ?? '—',
          date: (inv['date'] ?? inv['createdAt'] ?? '').toString(),
          items: items.isEmpty ? 'Jewelry Items' : items,
          itemCount: (inv['items'] as List? ?? []).length,
          total: _fmt(total.toInt()),
          totalNum: total.toInt(),
          status: status,
        );
      }).toList();

      final spend = filtered
          .where(
            (inv) =>
                inv['status'] != 'CANCELLED' &&
                inv['paymentStatus'] != 'CANCELLED',
          )
          .fold<int>(
            0,
            (s, inv) =>
                s + ((inv['total'] ?? inv['totalAmount'] ?? 0) as num).toInt(),
          );

      if (mounted)
        setState(() {
          _purchases = purchases;
          _totalSpend = spend;
        });
    } catch (_) {}
  }

  // mirrors Electron: ledger.list() → filter by party === customer.name → running balance
  Future<void> _fetchLedger() async {
    try {
      final r = await Get.find<LedgerService>().list();
      if (!r.success || r.data is! List) return;

      final all = r.data as List;
      final custEntries = all.where((e) {
        if (e is! Map) return false;
        final party = (e['party'] ?? '').toString().toLowerCase();
        return party == customer.name.toLowerCase();
      }).toList();

      // Sort by date ascending (mirrors Electron sort)
      custEntries.sort((a, b) {
        final da =
            DateTime.tryParse((a['date'] ?? a['createdAt'] ?? '').toString()) ??
            DateTime(2000);
        final db =
            DateTime.tryParse((b['date'] ?? b['createdAt'] ?? '').toString()) ??
            DateTime(2000);
        return da.compareTo(db);
      });

      // Compute running balance (DR = owed by customer, CR = payment received)
      int runBal = 0;
      final ledger = custEntries.map((e) {
        final amt = ((e['amount'] as num?)?.toInt() ?? 0);
        if ((e['type'] ?? '').toString() == 'DR')
          runBal -= amt;
        else
          runBal += amt;
        return LedgerEntry(
          date: (e['date'] ?? e['createdAt'] ?? '').toString(),
          type: (e['type'] ?? 'CR').toString(),
          desc: (e['note'] ?? e['description'] ?? '—').toString(),
          amount: _fmt(amt),
          amountNum: amt,
          balance: _fmt(runBal.abs()),
          balanceNum: runBal,
        );
      }).toList();

      // Outstanding = last entry has negative balance (customer owes money)
      final hasOutstanding = ledger.isNotEmpty && ledger.last.balanceNum < 0;
      final outstandingDisplay = hasOutstanding
          ? '₹${ledger.last.balanceNum.abs()}'
          : '₹0';

      if (mounted)
        setState(() {
          _ledger = ledger;
          _hasOutstanding = hasOutstanding;
          _outstandingDisplay = outstandingDisplay;
        });
    } catch (_) {}
  }

  String _fmt(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(customer.type);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Customer Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Get.toNamed(AppRoutes.editCustomer, arguments: customer),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.print_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => Get.snackbar(
                'Print',
                'Printing profile for ${customer.name}',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              ),
            ),
            TextButton.icon(
              onPressed: () => _whatsApp(customer),
              icon: const Icon(
                Icons.message_outlined,
                color: Color(0xFF25D366),
                size: 16,
              ),
              label: const Text(
                'WhatsApp',
                style: TextStyle(color: Color(0xFF25D366), fontSize: 12),
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            _header(customer, typeColor),
            _miniStats(),
            Container(
              color: AppColors.bgPrimary,
              child: const TabBar(
                indicatorColor: AppColors.goldPrimary,
                indicatorWeight: 2,
                labelColor: AppColors.goldPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Ledger'),
                  Tab(text: 'Purchases'),
                  Tab(text: 'Notes'),
                ],
              ),
            ),
            Expanded(
              child: _loadingExtra
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldPrimary,
                      ),
                    )
                  : TabBarView(
                      children: [
                        _OverviewTab(customer: customer, purchases: _purchases),
                        _LedgerTab(
                          customer: customer,
                          ledger: _ledger,
                          hasOutstanding: _hasOutstanding,
                          outstandingDisplay: _outstandingDisplay,
                        ),
                        _PurchasesTab(
                          customer: customer,
                          purchases: _purchases,
                          totalSpend: _totalSpend,
                        ),
                        _NotesTab(customer: customer),
                      ],
                    ),
            ),
          ],
        ),

        bottomNavigationBar: _bottomBar(customer),
      ),
    );
  }

  Widget _header(Customer c, Color typeColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: typeColor.withOpacity(0.5), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              c.initials,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _badge(c.type, typeColor),
                    const SizedBox(width: 6),
                    _tierBadge(c.loyaltyTier),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 12,
                  children: [
                    _meta(Icons.phone_outlined, c.phone),
                    if (c.email.isNotEmpty) _meta(Icons.mail_outline, c.email),
                    if (c.city.isNotEmpty)
                      _meta(Icons.location_on_outlined, c.city),
                  ],
                ),
                if (c.tags.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: c.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Uses live-fetched state instead of always-empty customer model fields
  Widget _miniStats() {
    final spendStr = _loadingExtra ? '...' : _fmt(_totalSpend);
    final ordersStr = _loadingExtra ? '...' : '${_purchases.length}';
    final dueStr = _loadingExtra
        ? '...'
        : (_hasOutstanding ? _outstandingDisplay : '₹0');
    final dueLabel = _hasOutstanding ? 'Due' : 'No Dues';
    final dueColor = _hasOutstanding ? AppColors.error : AppColors.success;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _mStat(spendStr, 'Lifetime Spend', AppColors.goldPrimary),
          _mStat(ordersStr, 'Orders', AppColors.info),
          _mStat('${customer.loyaltyPoints}', 'Points', AppColors.success),
          _mStat(dueStr, dueLabel, dueColor),
        ],
      ),
    );
  }

  Widget _mStat(String v, String l, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            v,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    ),
  );

  Widget _bottomBar(Customer c) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
    decoration: const BoxDecoration(
      color: AppColors.bgSecondary,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _whatsApp(c),
            icon: const Icon(
              Icons.message_outlined,
              size: 15,
              color: Color(0xFF25D366),
            ),
            label: const Text(
              'WhatsApp',
              style: TextStyle(color: Color(0xFF25D366), fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF25D366)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              try {
                final billing = Get.find<dynamic>();
                billing.customer.value = customer.name;
                billing.customerId.value =
                    customer.backendId?.toString() ?? customer.id;
              } catch (_) {}
              Get.toNamed(AppRoutes.createInvoice);
            },
            icon: const Icon(
              Icons.receipt_long_outlined,
              size: 15,
              color: Colors.black,
            ),
            label: const Text(
              'New Invoice',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );

  // mirrors Electron: wa.me/91{phone}?text=Hello+{name}...
  Future<void> _whatsApp(Customer c) async {
    final raw = (c.whatsapp.isNotEmpty ? c.whatsapp : c.phone).replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final phone = raw.startsWith('91') ? raw : '91$raw';
    final msg = Uri.encodeComponent(
      'Hello ${c.name}, this is Rajmahal Jewellers. How can we help you today?',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'WhatsApp',
        'Could not open WhatsApp for ${c.name}',
        backgroundColor: AppColors.bgCard,
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Widget _tierBadge(String tier) {
    final color = _tierColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10, color: color),
          const SizedBox(width: 3),
          Text('$tier Tier', style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );

  Color _typeColor(String t) {
    switch (t.toLowerCase()) {
      case 'vip':
        return AppColors.goldPrimary;
      case 'premium':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _tierColor(String t) {
    switch (t) {
      case 'Platinum':
        return const Color(0xFFE2E8F0);
      case 'Gold':
        return AppColors.goldPrimary;
      case 'Bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

// ── Overview Tab ──
class _OverviewTab extends StatelessWidget {
  final Customer customer;
  final List<PurchaseHistoryItem> purchases;
  const _OverviewTab({required this.customer, required this.purchases});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LoyaltyProgress(customer: customer),
        const SizedBox(height: 12),
        _card('Buying Preferences', Icons.tag_outlined, _prefsContent()),
        const SizedBox(height: 12),
        _card('Contact & KYC', Icons.shield_outlined, _kycContent()),
        const SizedBox(height: 12),
        _card(
          'Wishlist (${customer.wishlist.length})',
          Icons.bookmark_outline,
          CustomerWishlistPreview(customer: customer),
        ),
      ],
    );
  }

  Widget _prefsContent() {
    final p = customer.preferences;

    // mirrors Electron: compute top categories from purchase history
    final catCounts = <String, int>{};
    for (final purchase in purchases) {
      for (final item in purchase.items.split(', ')) {
        final cat = item.contains('Necklace')
            ? 'Necklaces'
            : item.contains('Ring')
            ? 'Rings'
            : item.contains('Earring') ||
                  item.contains('Jhumka') ||
                  item.contains('Stud')
            ? 'Earrings'
            : item.contains('Bangle')
            ? 'Bangles'
            : item.contains('Chain')
            ? 'Chains'
            : item.contains('Set') || item.contains('Choker')
            ? 'Sets'
            : item.contains('Pendant') || item.contains('Mangalsutra')
            ? 'Pendants'
            : 'Other';
        catCounts[cat] = (catCounts[cat] ?? 0) + 1;
      }
    }
    final topCats = catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Top categories (from real purchase data)
        if (topCats.isNotEmpty) ...[
          ...topCats
              .take(4)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.key,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${e.value} item${e.value > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const Divider(color: AppColors.border, height: 16),
        ],
        _row('Preferred Metal', '${p.metal} ${p.purity}'),
        _row('Style', p.style),
        if (p.ringSize.isNotEmpty) _row('Ring Size', p.ringSize),
        if (p.wristSize.isNotEmpty) _row('Wrist Size', p.wristSize),
        if (p.chainLength.isNotEmpty) _row('Chain Length', p.chainLength),
        if (p.bangleSize.isNotEmpty) _row('Bangle Size', p.bangleSize),
        if (p.ankletSize.isNotEmpty) _row('Anklet Size', p.ankletSize),
      ],
    );
  }

  Widget _kycContent() => Column(
    children: [
      _row('Phone', customer.phone),
      _row('WhatsApp', customer.whatsapp.isEmpty ? '—' : customer.whatsapp),
      _row('Email', customer.email.isEmpty ? '—' : customer.email),
      _row('Address', customer.address.isEmpty ? '—' : customer.address),
      _row('PAN', customer.pan.isEmpty ? '—' : customer.pan),
      _row('Aadhaar', customer.aadhaar.isEmpty ? '—' : customer.aadhaar),
      if (customer.gstNumber.isNotEmpty) _row('GST', customer.gstNumber),
      if (customer.referredBy.isNotEmpty)
        _row('Referred By', customer.referredBy),
    ],
  );

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _card(String title, IconData icon, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.goldPrimary, size: 15),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

// ── Ledger Tab ──
class _LedgerTab extends StatelessWidget {
  final Customer customer;
  final List<LedgerEntry> ledger;
  final bool hasOutstanding;
  final String outstandingDisplay;
  const _LedgerTab({
    required this.customer,
    required this.ledger,
    required this.hasOutstanding,
    required this.outstandingDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Ledger',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (ledger.isNotEmpty)
              GestureDetector(
                onTap: () => Get.snackbar(
                  'Ledger Export',
                  'Ledger exported for ${customer.name}',
                  backgroundColor: AppColors.bgCard,
                  colorText: AppColors.success,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: AppColors.goldPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Export',
                        style: TextStyle(
                          color: AppColors.goldPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Outstanding banner
        if (hasOutstanding)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Outstanding: $outstandingDisplay',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'No outstanding dues — All payments clear',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        if (ledger.isEmpty)
          const Center(
            child: Text(
              'No ledger entries',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Description',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ...ledger.map(
                  (l) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _fmt(l.date),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (l.type == 'CR'
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l.type,
                              style: TextStyle(
                                color: l.type == 'CR'
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l.desc,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l.amount,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              l.balance,
                              style: TextStyle(
                                color: l.hasBalance
                                    ? AppColors.error
                                    : AppColors.success,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]}';
    } catch (_) {
      return d;
    }
  }
}

// ── Purchases Tab ──
class _PurchasesTab extends StatelessWidget {
  final Customer customer;
  final List<PurchaseHistoryItem> purchases;
  final int totalSpend;
  const _PurchasesTab({
    required this.customer,
    required this.purchases,
    required this.totalSpend,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // mirrors Electron: summary + Download Statement header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12, right: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sumStat('${purchases.length}', 'Orders'),
                    _sumStat(_fmtAmt(totalSpend), 'Lifetime'),
                    _sumStat(
                      purchases.isEmpty
                          ? '₹0'
                          : '₹${((totalSpend / purchases.length) / 1000).toStringAsFixed(0)}K',
                      'Avg Order',
                    ),
                  ],
                ),
              ),
            ),
            // mirrors Electron: Download Statement button
            GestureDetector(
              onTap: () => Get.snackbar(
                'Statement',
                'Printing statement for ${customer.name}',
                backgroundColor: AppColors.bgCard,
                colorText: AppColors.textPrimary,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.download_outlined,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Statement',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (purchases.isEmpty)
          const Center(
            child: Text(
              'No purchases yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          // mirrors Electron: tap row → navigate to invoiceDetail
          ...purchases.map(
            (p) => GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.billing),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.goldPrimary,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.invoiceId,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            p.items,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _fmt(p.date),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.total,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _statusBadge(p.status),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fmtAmt(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  Widget _sumStat(String v, String l) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ],
  );

  Widget _statusBadge(String s) {
    Color c;
    switch (s) {
      case 'Paid':
        c = AppColors.success;
        break;
      case 'Partial':
        c = AppColors.info;
        break;
      default:
        c = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(
        s,
        style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }
}

// ── Notes Tab ──
class _NotesTab extends StatelessWidget {
  final Customer customer;
  const _NotesTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Internal Notes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddNote(context),
              icon: const Icon(Icons.add, size: 14, color: Colors.black),
              label: const Text(
                'Add Note',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (customer.notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No notes yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...customer.notes.map(
            (n) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        n.date,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.person_outline,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        n.addedBy,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),

        // Measurement preferences
        const Text(
          'Size & Measurements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            _prefCard(
              Icons.diamond_outlined,
              'Ring Size',
              customer.preferences.ringSize,
            ),
            _prefCard(
              Icons.watch_outlined,
              'Wrist',
              customer.preferences.wristSize,
            ),
            _prefCard(
              Icons.link_outlined,
              'Chain',
              customer.preferences.chainLength,
            ),
            _prefCard(
              Icons.star_outline,
              'Style',
              customer.preferences.style.split(' ').first,
            ),
            _prefCard(
              Icons.circle_outlined,
              'Metal',
              customer.preferences.metal,
            ),
            _prefCard(
              Icons.percent_outlined,
              'Purity',
              customer.preferences.purity,
            ),
          ],
        ),
      ],
    );
  }

  Widget _prefCard(IconData icon, String label, String val) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 18),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        Text(
          val.isEmpty ? '—' : val,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  void _showAddNote(BuildContext context) {
    final ctrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Add Note',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Enter note about this customer...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                Get.find<CustomerController>().addNote(
                  customer.id,
                  ctrl.text.trim(),
                  'Staff',
                );
                Get.back();
                Get.snackbar(
                  'Note Added',
                  'Note saved successfully!',
                  backgroundColor: AppColors.bgCard,
                  colorText: AppColors.textPrimary,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
