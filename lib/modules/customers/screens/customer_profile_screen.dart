import 'package:acme_killer_mobile_app/modules/customers/widgets/customer_wishlist_preview.dart';
import 'package:acme_killer_mobile_app/modules/customers/widgets/loyalty_progress.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/customer_model.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,

        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          title: Text(
            customer.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textPrimary),
              onPressed: () {
                Get.toNamed(AppRoutes.editCustomer, arguments: customer);
              },
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () => openWhatsApp(customer),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.goldPrimary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.goldPrimary,
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Ledger"),
              Tab(text: "Purchases"),
              Tab(text: "Notes"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _overview(customer),
            _ledger(customer),
            _purchases(customer),
            _notes(customer),
          ],
        ),
      ),
    );
  }

  /// ================================
  /// OVERVIEW
  /// ================================

  Widget _overview(Customer c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// PROFILE CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.goldPrimary,
                  child: Text(
                    c.name[0],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        c.phone ?? "-",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),

                      Text(
                        c.email ?? "-",
                        style: const TextStyle(color: AppColors.textMuted),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withOpacity(.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.type,
                          style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// STATS
          Row(
            children: [
              _statCard("Spend", "₹${c.totalPurchases}"),

              _statCard("Visits", c.visits.toString()),

              _statCard("Orders", c.purchaseHistory.length.toString()),
            ],
          ),

          const SizedBox(height: 20),

          /// ADDRESS
          _detailCard("City", c.city ?? "-"),
          _detailCard("Address", c.address ?? "-"),
          _detailCard("PAN", c.pan ?? "-"),
          _detailCard("GST", c.gstNumber ?? "-"),

          const SizedBox(height: 20),

          LoyaltyProgress(customer: c),

          const SizedBox(height: 20),

          WishlistPreview(customer: c),
        ],
      ),
    );
  }

  /// ================================
  /// LEDGER
  /// ================================

  Widget _ledger(Customer c) {
    final ledger = c.ledger;

    if (ledger.isEmpty) {
      return const Center(
        child: Text(
          "No ledger records",
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ledger.length,
      itemBuilder: (_, i) {
        final entry = ledger[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                entry["type"] == "credit"
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: entry["type"] == "credit" ? Colors.green : Colors.red,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry["note"],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      entry["date"],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "₹${entry["amount"]}",
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openWhatsApp(Customer c) {
    final phone = c.phone?.replaceAll(RegExp(r'\D'), '');

    final url = "https://wa.me/91$phone?text=Hello ${c.name}";

    launchUrl(Uri.parse(url));
  }

  /// ================================
  /// PURCHASES
  /// ================================

  Widget _purchases(Customer c) {
    final purchases = c.purchaseHistory;

    if (purchases.isEmpty) {
      return const Center(
        child: Text(
          "No purchases yet",
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchases.length,
      itemBuilder: (_, i) {
        final item = purchases[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.goldPrimary),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["item"],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      item["date"],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "₹${item["amount"]}",
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================================
  /// NOTES
  /// ================================

  Widget _notes(Customer c) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        c.notes.isEmpty ? "No notes available" : c.notes,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  /// ================================
  /// SMALL WIDGETS
  /// ================================

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String title, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),

          Text(
            value ?? "-",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
