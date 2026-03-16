import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  static const _configCards = [
    {
      'id': 'invoice',
      'title': 'Invoice Settings',
      'desc': 'Prefix, GST, template, making charges',
      'icon': 0xe1c1,
      'color': 0xFFD4AF37,
    }, // receipt_long
    {
      'id': 'loyalty',
      'title': 'Loyalty Program',
      'desc': 'Points, tiers, redemption rules',
      'icon': 0xe5f7,
      'color': 0xFFF472B6,
    }, // stars
    {
      'id': 'whatsapp',
      'title': 'WhatsApp Integration',
      'desc': 'API settings, auto-messages',
      'icon': 0xe0c9,
      'color': 0xFF4ADE80,
    }, // chat_bubble
    {
      'id': 'language',
      'title': 'Language & Region',
      'desc': 'Display language, currency format',
      'icon': 0xe894,
      'color': 0xFF60A5FA,
    }, // language
    {
      'id': 'backup',
      'title': 'Backup & Data',
      'desc': 'Auto-backup, export, restore',
      'icon': 0xe1db,
      'color': 0xFFFBBF24,
    }, // backup
    {
      'id': 'theme',
      'title': 'Appearance',
      'desc': 'Theme, fonts, display preferences',
      'icon': 0xe40a,
      'color': 0xFFC084FC,
    }, // palette
    {
      'id': 'rates',
      'title': 'Rate Configuration',
      'desc': 'Auto-fetch, sources, update schedule',
      'icon': 0xe5d5,
      'color': 0xFFF0D060,
    }, // sync
    {
      'id': 'terms',
      'title': 'Terms & Conditions',
      'desc': 'Invoice terms, return policy',
      'icon': 0xe873,
      'color': 0xFF94A3B8,
    }, // description
    {
      'id': 'activityLogs',
      'title': 'Activity Logs',
      'desc': 'User actions, audit trail',
      'icon': 0xe1d8,
      'color': 0xFFF87171,
    }, // manage_history
    {
      'id': 'categoriesMetal',
      'title': 'Categories & Metal Types',
      'desc': 'Manage jewelry categories and metal types',
      'icon': 0xe1bf,
      'color': 0xFFD4AF37,
    }, // inventory_2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Business card ──
          _businessCard(),
          const SizedBox(height: 16),

          // ── Quick settings ──
          _sectionTitle('Quick Settings'),
          _quickSettings(),
          const SizedBox(height: 16),

          // ── Config cards ──
          _sectionTitle('Configuration'),
          ..._configCards.map(
            (c) => _ConfigCard(
              id: c['id'] as String,
              title: c['title'] as String,
              desc: c['desc'] as String,
              iconData: IconData(c['icon'] as int, fontFamily: 'MaterialIcons'),
              color: Color(c['color'] as int),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _businessCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color: AppColors.goldPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.businessName.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _tag(
                        Icons.tag_outlined,
                        'GSTIN: ${controller.gstin.value}',
                      ),
                      _tag(Icons.phone_outlined, controller.phone.value),
                      _tag(Icons.mail_outline, controller.email.value),
                      _tag(
                        Icons.store_outlined,
                        '${controller.storeCount} Stores',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
    ],
  );

  Widget _quickSettings() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Row 1
            Row(
              children: [
                _quickField(
                  'Making Charge (%)',
                  controller.defaultMakingCharge.value.toString(),
                  (v) {
                    controller.defaultMakingCharge.value =
                        double.tryParse(v) ??
                        controller.defaultMakingCharge.value;
                  },
                ),
                const SizedBox(width: 10),
                _quickField(
                  'GST Rate (%)',
                  controller.gstRate.value.toString(),
                  (v) {
                    controller.gstRate.value =
                        double.tryParse(v) ?? controller.gstRate.value;
                  },
                ),
                const SizedBox(width: 10),
                _quickField(
                  'Default Wastage (%)',
                  controller.defaultWastage.value.toString(),
                  (v) {
                    controller.defaultWastage.value =
                        double.tryParse(v) ?? controller.defaultWastage.value;
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 2
            Row(
              children: [
                _quickField('Invoice Prefix', controller.invoicePrefix.value, (
                  v,
                ) {
                  controller.invoicePrefix.value = v;
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickDrop(
                    'Currency',
                    ['INR (₹)', 'USD', 'EUR (€)'],
                    controller.currency.value,
                    (v) => controller.currency.value = v!,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickDrop(
                    'Weight Unit',
                    ['Grams', 'Tola', 'Both'],
                    controller.weightUnit.value,
                    (v) => controller.weightUnit.value = v!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickField(
    String label,
    String initial,
    ValueChanged<String> onChange,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: TextFormField(
              initialValue: initial,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              onChanged: onChange,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickDrop(
    String label,
    List<String> items,
    String val,
    ValueChanged<String?> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: val,
              isExpanded: true,
              dropdownColor: AppColors.bgSecondary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              items: items
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(
                        i,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    ),
  );
}

class _ConfigCard extends StatelessWidget {
  final String id, title, desc;
  final IconData iconData;
  final Color color;
  const _ConfigCard({
    required this.id,
    required this.title,
    required this.desc,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.settingsDetail, arguments: id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
