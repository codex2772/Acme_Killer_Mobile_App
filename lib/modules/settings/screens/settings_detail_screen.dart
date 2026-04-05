import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';

class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final section = Get.arguments as String? ?? 'invoice';

    final titles = {
      'invoice': 'Invoice Settings',
      'loyalty': 'Loyalty Program',
      'whatsapp': 'WhatsApp Integration',
      'language': 'Language & Region',
      'backup': 'Backup & Data',
      'theme': 'Appearance',
      'rates': 'Rate Configuration',
      'terms': 'Terms & Conditions',
      'activityLogs': 'Activity Logs',
      'categoriesMetal': 'Categories & Metal Types',
    };

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
        title: Text(
          titles[section] ?? 'Settings',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildSection(context, section, ctrl),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String section,
    SettingsController ctrl,
  ) {
    switch (section) {
      case 'invoice':
        return _InvoiceSettings(ctrl: ctrl);
      case 'loyalty':
        return _LoyaltySettings(ctrl: ctrl);
      case 'whatsapp':
        return _WhatsAppSettings(ctrl: ctrl);
      case 'language':
        return _LanguageSettings(ctrl: ctrl);
      case 'backup':
        return _BackupSettings(ctrl: ctrl);
      case 'theme':
        return _AppearanceSettings(ctrl: ctrl);
      case 'rates':
        return _RateSettings(ctrl: ctrl);
      case 'terms':
        return _TermsSettings(ctrl: ctrl);
      case 'activityLogs':
        return _ActivityLogsSection(ctrl: ctrl);
      case 'categoriesMetal':
        return _CategoriesMetalSection(ctrl: ctrl);
      default:
        return _InvoiceSettings(ctrl: ctrl);
    }
  }
}

// ── Shared helpers ─────────────────────────────────────────────

Widget _card(String title, IconData icon, Widget child) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
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
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      child,
    ],
  ),
);

Widget _field(
  TextEditingController ctrl,
  String label, {
  TextInputType? keyboardType,
  int maxLines = 1,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 5),
    Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    ),
    const SizedBox(height: 10),
  ],
);

Widget _drop(
  String label,
  List<String> items,
  String val,
  ValueChanged<String?> onChange,
) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 5),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: AppColors.bgSecondary,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    ),
    const SizedBox(height: 10),
  ],
);

Widget _row2(Widget a, Widget b) => Row(
  children: [
    Expanded(
      child: Padding(padding: const EdgeInsets.only(right: 6), child: a),
    ),
    Expanded(
      child: Padding(padding: const EdgeInsets.only(left: 6), child: b),
    ),
  ],
);
Widget _row3(Widget a, Widget b, Widget c) => Row(
  children: [
    Expanded(
      child: Padding(padding: const EdgeInsets.only(right: 4), child: a),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: b,
      ),
    ),
    Expanded(
      child: Padding(padding: const EdgeInsets.only(left: 4), child: c),
    ),
  ],
);

Widget _saveBtn(VoidCallback onSave) => Padding(
  padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
  child: SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: onSave,
      icon: const Icon(Icons.check, size: 18, color: Colors.black),
      label: const Text(
        'Save Changes',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
  ),
);

void _saved() => Get.snackbar(
  'Saved',
  'Settings updated successfully!',
  backgroundColor: AppColors.bgCard,
  colorText: AppColors.textPrimary,
  snackPosition: SnackPosition.BOTTOM,
  margin: const EdgeInsets.all(12),
);

// ─── INVOICE SETTINGS ──────────────────────────────────────

class _InvoiceSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _InvoiceSettings({required this.ctrl});
  @override
  State<_InvoiceSettings> createState() => _InvoiceSettingsState();
}

class _InvoiceSettingsState extends State<_InvoiceSettings> {
  late TextEditingController _prefix, _gst, _making, _wastage;
  String _template = 'Professional';
  String _autoPrint = 'No';

  @override
  void initState() {
    super.initState();
    final c = widget.ctrl;
    _prefix = TextEditingController(text: c.invoicePrefix.value);
    _gst = TextEditingController(text: c.gstRate.value.toString());
    _making = TextEditingController(
      text: c.defaultMakingCharge.value.toString(),
    );
    _wastage = TextEditingController(text: c.defaultWastage.value.toString());
    _template = c.invoiceTemplate.value == 'professional'
        ? 'Professional'
        : c.invoiceTemplate.value;
  }

  @override
  void dispose() {
    for (final c in [_prefix, _gst, _making, _wastage]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Invoice Configuration',
          Icons.receipt_long_outlined,
          Column(
            children: [
              _row2(
                _field(_prefix, 'Invoice Prefix'),
                _drop(
                  'Template',
                  ['Professional', 'Classic', 'Modern', 'Minimal'],
                  _template,
                  (v) => setState(() => _template = v!),
                ),
              ),
              _row2(
                _field(
                  _gst,
                  'Default GST (%)',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  _making,
                  'Making Charge (%)',
                  keyboardType: TextInputType.number,
                ),
              ),
              _row2(
                _field(
                  _wastage,
                  'Default Wastage (%)',
                  keyboardType: TextInputType.number,
                ),
                _drop(
                  'Auto Print',
                  ['Yes', 'No'],
                  _autoPrint,
                  (v) => setState(() => _autoPrint = v!),
                ),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.saveInvoiceSettings(
            prefix: _prefix.text,
            gst: double.tryParse(_gst.text) ?? 3.0,
            making: double.tryParse(_making.text) ?? 12.0,
            wastage: double.tryParse(_wastage.text) ?? 2.0,
            template: _template.toLowerCase(),
          );
          _saved();
          Get.back();
        }),
      ],
    );
  }
}

// ─── LOYALTY SETTINGS ──────────────────────────────────────

class _LoyaltySettings extends StatefulWidget {
  final SettingsController ctrl;
  const _LoyaltySettings({required this.ctrl});
  @override
  State<_LoyaltySettings> createState() => _LoyaltySettingsState();
}

class _LoyaltySettingsState extends State<_LoyaltySettings> {
  late TextEditingController _pts, _red, _exp, _silver, _gold, _plat;
  @override
  void initState() {
    super.initState();
    final c = widget.ctrl.loyaltyConfig;
    _pts = TextEditingController(text: c.pointsPerRupee.toString());
    _red = TextEditingController(text: c.redemptionRate.toString());
    _exp = TextEditingController(text: '24');
    _silver = TextEditingController(text: c.silverThreshold.toString());
    _gold = TextEditingController(text: c.goldThreshold.toString());
    _plat = TextEditingController(text: c.platinumThreshold.toString());
  }

  @override
  void dispose() {
    for (final c in [_pts, _red, _exp, _silver, _gold, _plat]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Points Configuration',
          Icons.stars_outlined,
          Column(
            children: [
              _row3(
                _field(
                  _pts,
                  'Points per ₹1 Spent',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _field(
                  _red,
                  'Redemption (pts per ₹1)',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  _exp,
                  'Points Expiry (months)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
        _card(
          'Tier Thresholds',
          Icons.workspace_premium_outlined,
          Column(
            children: [
              _row3(
                _field(
                  _silver,
                  'Silver Tier (₹)',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  _gold,
                  'Gold Tier (₹)',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  _plat,
                  'Platinum Tier (₹)',
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _tierRow('Silver', '₹0+', const Color(0xFF94A3B8)),
                    _tierRow('Gold', '₹5L+', AppColors.goldPrimary),
                    _tierRow('Platinum', '₹10L+', const Color(0xFFE2E8F0)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.loyaltyConfig.pointsPerRupee =
              double.tryParse(_pts.text) ?? 0.5;
          widget.ctrl.loyaltyConfig.redemptionRate =
              int.tryParse(_red.text) ?? 100;
          widget.ctrl.loyaltyConfig.silverThreshold =
              int.tryParse(_silver.text) ?? 0;
          widget.ctrl.loyaltyConfig.goldThreshold =
              int.tryParse(_gold.text) ?? 500000;
          widget.ctrl.loyaltyConfig.platinumThreshold =
              int.tryParse(_plat.text) ?? 1000000;
          _saved();
          Get.back();
        }),
      ],
    );
  }

  Widget _tierRow(String tier, String threshold, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          tier,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          threshold,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );
}

// ─── WHATSAPP SETTINGS ─────────────────────────────────────

class _WhatsAppSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _WhatsAppSettings({required this.ctrl});
  @override
  State<_WhatsAppSettings> createState() => _WhatsAppSettingsState();
}

class _WhatsAppSettingsState extends State<_WhatsAppSettings> {
  late String _enabled, _provider;
  late TextEditingController _apiKey;
  @override
  void initState() {
    super.initState();
    final c = widget.ctrl;
    _enabled = c.whatsappEnabled.value ? 'Enabled' : 'Disabled';
    _provider = c.whatsappProvider.value;
    _apiKey = TextEditingController(text: c.whatsappApiKey.value);
  }

  @override
  void dispose() {
    _apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'WhatsApp API',
          Icons.chat_bubble_outline,
          Column(
            children: [
              _row2(
                _drop(
                  'Status',
                  ['Enabled', 'Disabled'],
                  _enabled,
                  (v) => setState(() => _enabled = v!),
                ),
                _drop(
                  'Provider',
                  ['WhatsApp Business API', 'Twilio', 'Custom'],
                  _provider,
                  (v) => setState(() => _provider = v!),
                ),
              ),
              _field(_apiKey, 'API Key'),
            ],
          ),
        ),
        _card(
          'Auto Messages',
          Icons.auto_awesome_outlined,
          Column(
            children: [
              _autoMsgTile(
                'Birthday Wishes',
                'Send on customer birthday',
                true,
              ),
              _autoMsgTile(
                'Anniversary Wishes',
                'Send on anniversary date',
                true,
              ),
              _autoMsgTile(
                'Payment Reminders',
                'Remind about pending dues',
                true,
              ),
              _autoMsgTile(
                'Scheme Due Alerts',
                'Notify scheme payment due',
                false,
              ),
              _autoMsgTile('Invoice Copy', 'Send invoice after billing', true),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.whatsappEnabled.value = _enabled == 'Enabled';
          widget.ctrl.whatsappApiKey.value = _apiKey.text;
          widget.ctrl.whatsappProvider.value = _provider;
          _saved();
          Get.back();
        }),
      ],
    );
  }

  Widget _autoMsgTile(String title, String sub, bool enabled) {
    final isEnabled = enabled.obs;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: isEnabled.value,
              onChanged: (v) => isEnabled.value = v,
              activeColor: AppColors.goldPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LANGUAGE SETTINGS ─────────────────────────────────────

class _LanguageSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _LanguageSettings({required this.ctrl});
  @override
  State<_LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<_LanguageSettings> {
  late String _lang, _curr, _date, _weight;
  @override
  void initState() {
    super.initState();
    _lang = widget.ctrl.language.value;
    _curr = 'Indian (₹1,23,456.78)';
    _date = widget.ctrl.dateFormat.value;
    _weight = widget.ctrl.weightUnit.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Regional Preferences',
          Icons.language_outlined,
          Column(
            children: [
              _row2(
                _drop(
                  'Display Language',
                  [
                    'English',
                    'हिन्दी (Hindi)',
                    'ગુજરાતી (Gujarati)',
                    'मराठी (Marathi)',
                    'தமிழ் (Tamil)',
                  ],
                  _lang,
                  (v) => setState(() => _lang = v!),
                ),
                _drop(
                  'Currency Format',
                  ['Indian (₹1,23,456.78)', 'International (₹123,456.78)'],
                  _curr,
                  (v) => setState(() => _curr = v!),
                ),
              ),
              _row2(
                _drop(
                  'Date Format',
                  ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                  _date,
                  (v) => setState(() => _date = v!),
                ),
                _drop(
                  'Weight Display',
                  ['Grams', 'Tola', 'Both'],
                  _weight,
                  (v) => setState(() => _weight = v!),
                ),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.language.value = _lang;
          widget.ctrl.dateFormat.value = _date;
          widget.ctrl.weightUnit.value = _weight;
          _saved();
          Get.back();
        }),
      ],
    );
  }
}

// ─── BACKUP SETTINGS ───────────────────────────────────────

class _BackupSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _BackupSettings({required this.ctrl});
  @override
  State<_BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends State<_BackupSettings> {
  late String _auto, _freq;
  @override
  void initState() {
    super.initState();
    _auto = widget.ctrl.autoBackup.value ? 'Enabled' : 'Disabled';
    _freq = widget.ctrl.backupFrequency.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Auto Backup',
          Icons.backup_outlined,
          Column(
            children: [
              _row2(
                _drop(
                  'Auto Backup',
                  ['Enabled', 'Disabled'],
                  _auto,
                  (v) => setState(() => _auto = v!),
                ),
                _drop(
                  'Frequency',
                  ['Daily', 'Weekly', 'Monthly'],
                  _freq,
                  (v) => setState(() => _freq = v!),
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Backup',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            widget.ctrl.lastBackup.value,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
        _card(
          'Data Management',
          Icons.storage_outlined,
          Column(
            children: [
              _actionBtn(
                Icons.save_outlined,
                'Backup Now',
                'Download complete data backup',
                AppColors.goldPrimary,
                () {
                  widget.ctrl.doBackupNow();
                  // mirrors Electron: triggers backup download
                  // Mobile: update lastBackup timestamp + confirm
                  widget.ctrl.lastBackup.value =
                      '${DateTime.now().toIso8601String().substring(0, 10)} '
                      '${TimeOfDay.now().format(context)}';
                  Get.snackbar(
                    'Backup Created',
                    'Backup saved — ${widget.ctrl.lastBackup.value}',
                    backgroundColor: AppColors.bgCard,
                    colorText: AppColors.success,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                  );
                },
              ),
              const SizedBox(height: 8),
              _actionBtn(
                Icons.download_outlined,
                'Export All Data',
                'Export all data as JSON',
                AppColors.info,
                () {
                  // mirrors Electron: generates JSON export — mobile shows summary
                  Get.snackbar(
                    'Export Ready',
                    'Customers · Inventory · Invoices · Ledger — ready to export\n'
                        'Connect to desktop to download full file',
                    backgroundColor: AppColors.bgCard,
                    colorText: AppColors.info,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 4),
                  );
                },
              ),
              const SizedBox(height: 8),
              _actionBtn(
                Icons.restore_outlined,
                'Restore Data',
                'Upload a backup file',
                AppColors.warning,
                () {
                  // mirrors Electron: restore from JSON — desktop-only file operation
                  Get.snackbar(
                    'Restore Data',
                    'To restore: transfer backup file to this device, then select it\n'
                        'Full restore available on desktop version',
                    backgroundColor: AppColors.bgCard,
                    colorText: AppColors.warning,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 4),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
          child: ElevatedButton.icon(
            onPressed: () {
              widget.ctrl.autoBackup.value = _auto == 'Enabled';
              widget.ctrl.backupFrequency.value = _freq;
              _saved();
              Get.back();
            },
            icon: const Icon(Icons.check, size: 18, color: Colors.black),
            label: const Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String title,
    String sub,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 13),
        ],
      ),
    ),
  );
}

// ─── APPEARANCE ────────────────────────────────────────────

class _AppearanceSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _AppearanceSettings({required this.ctrl});
  @override
  State<_AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<_AppearanceSettings> {
  late String _theme, _accent, _fontSize;
  @override
  void initState() {
    super.initState();
    _theme = widget.ctrl.theme.value;
    _accent = widget.ctrl.accentColor.value;
    _fontSize = widget.ctrl.fontSize.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Display Settings',
          Icons.palette_outlined,
          Column(
            children: [
              _row2(
                _drop(
                  'Theme',
                  ['Dark (Default)', 'Light', 'System'],
                  _theme,
                  (v) => setState(() => _theme = v!),
                ),
                _drop(
                  'Accent Color',
                  ['Gold (#D4AF37)', 'Rose (#F472B6)', 'Blue (#60A5FA)'],
                  _accent,
                  (v) => setState(() => _accent = v!),
                ),
              ),
              _row2(
                _drop(
                  'Font Size',
                  ['Small', 'Medium', 'Large'],
                  _fontSize,
                  (v) => setState(() => _fontSize = v!),
                ),
                _drop('Sidebar', ['Left', 'Right'], 'Left', (_) {}),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.theme.value = _theme;
          widget.ctrl.accentColor.value = _accent;
          widget.ctrl.fontSize.value = _fontSize;
          _saved();
          Get.back();
        }),
      ],
    );
  }
}

// ─── RATE SETTINGS ─────────────────────────────────────────

class _RateSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _RateSettings({required this.ctrl});
  @override
  State<_RateSettings> createState() => _RateSettingsState();
}

class _RateSettingsState extends State<_RateSettings> {
  late String _auto, _source, _freq;
  final _endpointCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _auto = widget.ctrl.rateAutoFetch.value ? 'Enabled' : 'Disabled';
    _source = widget.ctrl.rateApiSource.value;
    _freq = widget.ctrl.rateFrequency.value;
  }

  @override
  void dispose() {
    _endpointCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Rate Source Configuration',
          Icons.sync_outlined,
          Column(
            children: [
              _row2(
                _drop(
                  'Auto-Fetch Rates',
                  ['Enabled', 'Disabled'],
                  _auto,
                  (v) => setState(() => _auto = v!),
                ),
                _drop(
                  'Rate Source',
                  ['Manual Entry', 'IBJA API', 'Custom API'],
                  _source,
                  (v) => setState(() => _source = v!),
                ),
              ),
              _row2(
                _drop(
                  'Update Frequency',
                  ['Every 15 min', 'Every 30 min', 'Hourly', 'Daily'],
                  _freq,
                  (v) => setState(() => _freq = v!),
                ),
                _field(
                  _endpointCtrl,
                  'Custom API Endpoint',
                  hint: 'https://api.example.com/rates',
                ),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.rateAutoFetch.value = _auto == 'Enabled';
          widget.ctrl.rateApiSource.value = _source;
          widget.ctrl.rateFrequency.value = _freq;
          _saved();
          Get.back();
        }),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, {String? hint}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: ctrl,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
}

// ─── TERMS SETTINGS ────────────────────────────────────────

class _TermsSettings extends StatefulWidget {
  final SettingsController ctrl;
  const _TermsSettings({required this.ctrl});
  @override
  State<_TermsSettings> createState() => _TermsSettingsState();
}

class _TermsSettingsState extends State<_TermsSettings> {
  late TextEditingController _termsCtrl;
  @override
  void initState() {
    super.initState();
    _termsCtrl = TextEditingController(
      text: widget.ctrl.termsAndConditions.value,
    );
  }

  @override
  void dispose() {
    _termsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
      children: [
        _card(
          'Invoice Terms & Conditions',
          Icons.description_outlined,
          Column(
            children: [
              const Text(
                'This text appears at the bottom of every invoice.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _termsCtrl,
                  maxLines: 12,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        _saveBtn(() {
          widget.ctrl.termsAndConditions.value = _termsCtrl.text;
          _saved();
          Get.back();
        }),
      ],
    );
  }
}

// ─── ACTIVITY LOGS ─────────────────────────────────────────

class _ActivityLogsSection extends StatelessWidget {
  final SettingsController ctrl;
  const _ActivityLogsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
        itemCount: ctrl.activityLogs.length,
        itemBuilder: (_, i) {
          final log = ctrl.activityLogs[i];
          final modColor = _modColor(log.module);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: modColor, width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            log.action,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: modColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.module,
                              style: TextStyle(
                                color: modColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        log.detail,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 11,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            log.user,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time_outlined,
                            size: 11,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            log.timestamp.substring(0, 16),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Color _modColor(String module) {
    switch (module) {
      case 'Billing':
        return AppColors.goldPrimary;
      case 'Inventory':
        return AppColors.info;
      case 'Customers':
        return const Color(0xFF60A5FA);
      case 'Rates':
        return const Color(0xFFF0D060);
      case 'Old Gold':
        return AppColors.warning;
      case 'Schemes':
        return const Color(0xFFF472B6);
      case 'Settings':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ─── CATEGORIES & METAL TYPES ──────────────────────────────

class _CategoriesMetalSection extends StatelessWidget {
  final SettingsController ctrl;
  const _CategoriesMetalSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.bgPrimary,
            child: const TabBar(
              indicatorColor: AppColors.goldPrimary,
              labelColor: AppColors.goldPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(text: 'Categories'),
                Tab(text: 'Metal Types'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _CategoriesTab(ctrl: ctrl),
                _MetalTypesTab(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final SettingsController ctrl;
  const _CategoriesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage jewellery categories',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(
                  context,
                  'Category',
                  (name, desc) => ctrl.addCategory(name, desc),
                ),
                icon: const Icon(Icons.add, size: 14, color: Colors.black),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 30),
              itemCount: ctrl.categories.length,
              itemBuilder: (_, i) {
                final c = ctrl.categories[i];
                return _itemRow(
                  '#${c.id}',
                  c.name,
                  c.description,
                  onEdit: () => _showEditDialog(
                    context,
                    'Category',
                    c.name,
                    c.description,
                    (name, desc) => ctrl.updateCategory(c.id, name, desc),
                  ),
                  onDelete: () => _confirm(
                    context,
                    c.name,
                    () => ctrl.deleteCategory(c.id),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MetalTypesTab extends StatelessWidget {
  final SettingsController ctrl;
  const _MetalTypesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage metal types',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(
                  context,
                  'Metal Type',
                  (name, desc) => ctrl.addMetalType(name, desc),
                ),
                icon: const Icon(Icons.add, size: 14, color: Colors.black),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 30),
              itemCount: ctrl.metalTypes.length,
              itemBuilder: (_, i) {
                final m = ctrl.metalTypes[i];
                return _itemRow(
                  '#${m.id}',
                  m.name,
                  m.description,
                  onEdit: () => _showEditDialog(
                    context,
                    'Metal Type',
                    m.name,
                    m.description,
                    (name, desc) => ctrl.updateMetalType(m.id, name, desc),
                  ),
                  onDelete: () => _confirm(
                    context,
                    m.name,
                    () => ctrl.deleteMetalType(m.id),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

Widget _itemRow(
  String id,
  String name,
  String desc, {
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) => Container(
  margin: const EdgeInsets.only(bottom: 8),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  ),
  child: Row(
    children: [
      Text(
        id,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        softWrap: false,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (desc.isNotEmpty)
              Text(
                desc,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(Icons.edit_outlined, AppColors.info, onEdit),
          const SizedBox(width: 6),
          _iconBtn(Icons.delete_outline, AppColors.error, onDelete),
        ],
      ),
    ],
  ),
);

Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );

void _showAddDialog(
  BuildContext context,
  String type,
  void Function(String name, String desc) onSave,
) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text(
        'Add $type',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dlgField(nameCtrl, '$type Name *'),
          _dlgField(descCtrl, 'Description'),
        ],
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
            if (nameCtrl.text.trim().isEmpty) return;
            onSave(nameCtrl.text.trim(), descCtrl.text.trim());
            Get.back();
            Get.snackbar(
              'Added',
              '"${nameCtrl.text.trim()}" created!',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            );
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

void _showEditDialog(
  BuildContext context,
  String type,
  String initName,
  String initDesc,
  void Function(String name, String desc) onSave,
) {
  final nameCtrl = TextEditingController(text: initName);
  final descCtrl = TextEditingController(text: initDesc);
  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text(
        'Edit $type',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dlgField(nameCtrl, 'Name *'),
          _dlgField(descCtrl, 'Description'),
        ],
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
            if (nameCtrl.text.trim().isEmpty) return;
            onSave(nameCtrl.text.trim(), descCtrl.text.trim());
            Get.back();
            Get.snackbar(
              'Updated',
              '"${nameCtrl.text.trim()}" saved!',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            );
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

void _confirm(BuildContext context, String name, VoidCallback onConfirm) {
  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: const Text(
        'Confirm Delete',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Text(
        'Delete "$name"?',
        style: const TextStyle(color: AppColors.textSecondary),
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
            onConfirm();
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget _dlgField(TextEditingController c, String label) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: TextField(
    controller: c,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
  ),
);
