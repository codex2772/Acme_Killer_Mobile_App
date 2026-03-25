import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════════
// LocalizationService — mirrors Electron i18n.js
// Supports: English, Marathi (मराठी), Hindi (हिन्दी)
//
// Usage anywhere in the app:
//   final l = Get.find<LocalizationService>();
//   l.t('dashboard')  → 'Dashboard' / 'डॅशबोर्ड' / 'डैशबोर्ड'
//   l.setLanguage('मराठी (Marathi)')
// ════════════════════════════════════════════════════════════════════
class LocalizationService extends GetxService {
  static const _kPrefKey = 'jewelerp_lang';

  final RxString currentLang = 'en'.obs;

  // ── Init — restore persisted language ────────────────────────────
  Future<LocalizationService> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPrefKey);
      if (saved != null && _translations.containsKey(saved)) {
        currentLang.value = saved;
      }
    } catch (_) {}
    return this;
  }

  // ── Set language by display label ────────────────────────────────
  // mirrors Electron setLanguage()
  Future<void> setLanguage(String langLabel) async {
    final code = _langCodeMap[langLabel] ??
        _langCodeMap[langLabel.split(' ')[0]] ??
        'en';
    currentLang.value = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, code);
    } catch (_) {}
  }

  // ── Translate key — mirrors Electron t() ─────────────────────────
  String t(String key) {
    final dict = _translations[currentLang.value] ?? _translations['en']!;
    return dict[key] ?? _translations['en']![key] ?? key;
  }

  // ── Available languages ───────────────────────────────────────────
  static const List<String> availableLanguages = [
    'English',
    'मराठी (Marathi)',
    'हिन्दी (Hindi)',
  ];

  static const Map<String, String> _langCodeMap = {
    'English':             'en',
    'हिन्दी (Hindi)':     'hi',
    'Hindi':              'hi',
    'मराठी (Marathi)':    'mr',
    'Marathi':            'mr',
  };

  // ── Translation dictionaries ──────────────────────────────────────
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Navigation
      'dashboard': 'Dashboard', 'inventory': 'Inventory', 'billing': 'Billing',
      'customers': 'Customers', 'accounts': 'Accounts', 'rates': 'Rates',
      'oldGold': 'Old Gold', 'schemes': 'Schemes', 'reports': 'Reports',
      'enquiries': 'Enquiries', 'staff': 'Staff', 'settings': 'Settings',
      'logout': 'Logout',
      // Roles
      'owner': 'Owner', 'admin': 'Admin', 'staffRole': 'Staff',
      // Actions
      'save': 'Save', 'cancel': 'Cancel', 'edit': 'Edit', 'delete': 'Delete',
      'add': 'Add', 'view': 'View', 'search': 'Search', 'filter': 'Filter',
      'export': 'Export', 'print': 'Print', 'back': 'Back', 'close': 'Close',
      'confirm': 'Confirm', 'submit': 'Submit', 'update': 'Update',
      'create': 'Create', 'refresh': 'Refresh', 'download': 'Download',
      // Common labels
      'all': 'All', 'allStores': 'All Stores', 'selectStore': 'Select Store',
      'name': 'Name', 'phone': 'Phone', 'email': 'Email', 'address': 'Address',
      'city': 'City', 'date': 'Date', 'status': 'Status', 'amount': 'Amount',
      'total': 'Total', 'notes': 'Notes', 'type': 'Type', 'category': 'Category',
      'weight': 'Weight', 'price': 'Price', 'description': 'Description',
      'active': 'Active', 'inactive': 'Inactive',
      // Dashboard
      'welcomeBack': 'Welcome Back', 'todaysSummary': "Today's Summary",
      'totalRevenue': 'Total Revenue', 'pendingPayments': 'Pending Payments',
      'recentActivity': 'Recent Activity', 'quickActions': 'Quick Actions',
      // Inventory
      'inventoryManagement': 'Inventory Management', 'totalItems': 'Total Items',
      'inStock': 'In Stock', 'lowStock': 'Low Stock', 'stockValue': 'Stock Value',
      'addItem': 'Add Item', 'editItem': 'Edit Item', 'metal': 'Metal',
      'purity': 'Purity', 'netWeight': 'Net Weight', 'grossWeight': 'Gross Weight',
      'makingCharges': 'Making Charges', 'sellingPrice': 'Selling Price',
      'costPrice': 'Cost Price', 'huid': 'HUID', 'barcode': 'Barcode',
      'searchInventory': 'Search name, HUID, barcode...',
      // Billing
      'billingInvoices': 'Billing & Invoices', 'invoices': 'Invoices',
      'estimates': 'Estimates', 'creditNotes': 'Credit Notes',
      'newInvoice': 'New Invoice', 'createInvoice': 'Create New Invoice',
      'paid': 'Paid', 'pending': 'Pending', 'partial': 'Partial',
      'cancelled': 'Cancelled', 'subtotal': 'Subtotal', 'gst': 'GST',
      'discount': 'Discount', 'grandTotal': 'Grand Total',
      'selectCustomer': 'Select Customer', 'saveInvoice': 'Save Invoice',
      'searchInvoices': 'Search invoices...', 'cash': 'Cash', 'upi': 'UPI',
      'card': 'Card', 'cheque': 'Cheque',
      // Customers
      'customerManagement': 'Customer Management', 'addCustomer': 'Add Customer',
      'customerProfile': 'Customer Profile', 'loyaltyPoints': 'Loyalty Points',
      'loyaltyTier': 'Loyalty Tier', 'purchases': 'Purchases',
      'searchCustomers': 'Search customers...',
      // Accounts
      'accountsManagement': 'Accounts & Finance', 'ledgerEntries': 'Ledger Entries',
      'expenses': 'Expenses', 'suppliers': 'Suppliers', 'cashRegister': 'Cash Register',
      'credit': 'Credit', 'debit': 'Debit', 'balance': 'Balance',
      // Rates
      'todayRates': "Today's Rates", 'liveRates': 'Live Rates',
      'fetchLiveRates': 'Fetch Live Rates', 'perGram': 'per gram',
      // Schemes
      'savingSchemes': 'Saving Schemes', 'addScheme': 'Add Scheme',
      'members': 'Members', 'monthlyAmount': 'Monthly Amount',
      // Staff
      'staffManagement': 'Staff Management', 'addStaff': 'Add Staff',
      'permissions': 'Permissions', 'salary': 'Salary', 'attendance': 'Attendance',
      // Reports
      'reportsAnalytics': 'Reports & Analytics', 'gstReport': 'GST Report',
      'activityLogs': 'Activity Logs',
      // Settings
      'settingsConfig': 'Settings', 'languageRegion': 'Language & Region',
      'businessName': 'Business Name', 'gstRate': 'GST Rate (%)',
      // Enquiries
      'customerEnquiries': 'Customer Enquiries', 'respondToEnquiry': 'Respond',
      'closeEnquiry': 'Close Enquiry', 'open': 'Open',
      'responded': 'Responded', 'closed': 'Closed',
      // Module gating
      'moduleNotAvailable': 'Module Not Available',
      'moduleNotAvailableDesc': 'This feature is not enabled for your current store. Contact your administrator to enable it.',
      'goToDashboard': 'Go to Dashboard',
      // Misc
      'noDataFound': 'No data found', 'loading': 'Loading...',
      'success': 'Success', 'error': 'Error', 'areYouSure': 'Are you sure?',
      'yes': 'Yes', 'no': 'No', 'today': 'Today', 'thisMonth': 'This Month',
    },

    'mr': {
      // नेव्हिगेशन
      'dashboard': 'डॅशबोर्ड', 'inventory': 'इन्व्हेंटरी', 'billing': 'बिलिंग',
      'customers': 'ग्राहक', 'accounts': 'खाती', 'rates': 'दर',
      'oldGold': 'जुने सोने', 'schemes': 'योजना', 'reports': 'अहवाल',
      'enquiries': 'चौकशी', 'staff': 'कर्मचारी', 'settings': 'सेटिंग्ज',
      'logout': 'बाहेर पडा',
      'owner': 'मालक', 'admin': 'प्रशासक', 'staffRole': 'कर्मचारी',
      'save': 'जतन करा', 'cancel': 'रद्द करा', 'edit': 'संपादन',
      'delete': 'हटवा', 'add': 'जोडा', 'view': 'पहा', 'search': 'शोधा',
      'back': 'मागे', 'close': 'बंद करा', 'confirm': 'पुष्टी करा',
      'update': 'अपडेट करा', 'refresh': 'रिफ्रेश',
      'all': 'सर्व', 'allStores': 'सर्व दुकाने', 'name': 'नाव',
      'phone': 'फोन', 'email': 'ईमेल', 'date': 'तारीख', 'status': 'स्थिती',
      'amount': 'रक्कम', 'total': 'एकूण', 'weight': 'वजन', 'price': 'किंमत',
      'active': 'सक्रिय', 'inactive': 'निष्क्रिय',
      'welcomeBack': 'पुन्हा स्वागत', 'todaysSummary': 'आजचा सारांश',
      'totalRevenue': 'एकूण महसूल', 'pendingPayments': 'बाकी पेमेंट',
      'inventoryManagement': 'इन्व्हेंटरी व्यवस्थापन', 'inStock': 'स्टॉकमध्ये',
      'lowStock': 'कमी स्टॉक', 'stockValue': 'स्टॉक मूल्य',
      'metal': 'धातू', 'purity': 'शुद्धता', 'netWeight': 'निव्वळ वजन',
      'sellingPrice': 'विक्री किंमत', 'costPrice': 'मूळ किंमत',
      'billingInvoices': 'बिलिंग आणि पावत्या', 'invoices': 'पावत्या',
      'paid': 'भरलेले', 'pending': 'बाकी', 'partial': 'अंशतः',
      'gst': 'GST', 'discount': 'सवलत', 'grandTotal': 'एकूण रक्कम',
      'cash': 'रोख', 'card': 'कार्ड',
      'customerManagement': 'ग्राहक व्यवस्थापन', 'addCustomer': 'ग्राहक जोडा',
      'loyaltyPoints': 'लॉयल्टी पॉइंट्स',
      'accountsManagement': 'खाती आणि वित्त', 'expenses': 'खर्च',
      'suppliers': 'पुरवठादार', 'credit': 'जमा', 'debit': 'नावे',
      'todayRates': 'आजचे दर', 'liveRates': 'लाइव्ह दर', 'perGram': 'प्रति ग्रॅम',
      'savingSchemes': 'बचत योजना', 'members': 'सदस्य',
      'staffManagement': 'कर्मचारी व्यवस्थापन', 'salary': 'पगार',
      'attendance': 'हजेरी', 'permissions': 'परवानग्या',
      'settingsConfig': 'सेटिंग्ज', 'businessName': 'व्यवसायाचे नाव',
      'customerEnquiries': 'ग्राहक चौकशी', 'respondToEnquiry': 'उत्तर द्या',
      'closeEnquiry': 'चौकशी बंद करा', 'open': 'उघडा',
      'responded': 'उत्तर दिले', 'closed': 'बंद',
      'moduleNotAvailable': 'मॉड्यूल उपलब्ध नाही',
      'moduleNotAvailableDesc': 'ही सुविधा तुमच्या सध्याच्या दुकानासाठी सक्षम नाही.',
      'goToDashboard': 'डॅशबोर्डवर जा',
      'noDataFound': 'डेटा सापडला नाही', 'loading': 'लोड होत आहे...',
      'yes': 'हो', 'no': 'नाही', 'today': 'आज', 'thisMonth': 'या महिन्यात',
    },

    'hi': {
      // नेविगेशन
      'dashboard': 'डैशबोर्ड', 'inventory': 'इन्वेंट्री', 'billing': 'बिलिंग',
      'customers': 'ग्राहक', 'accounts': 'खाते', 'rates': 'दर',
      'oldGold': 'पुराना सोना', 'schemes': 'योजनाएँ', 'reports': 'रिपोर्ट',
      'enquiries': 'पूछताछ', 'staff': 'कर्मचारी', 'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'owner': 'मालिक', 'admin': 'प्रशासक', 'staffRole': 'कर्मचारी',
      'save': 'सहेजें', 'cancel': 'रद्द करें', 'edit': 'संपादित करें',
      'delete': 'हटाएँ', 'add': 'जोड़ें', 'view': 'देखें', 'search': 'खोजें',
      'back': 'वापस', 'close': 'बंद करें', 'confirm': 'पुष्टि करें',
      'update': 'अपडेट करें', 'refresh': 'रिफ्रेश',
      'all': 'सभी', 'allStores': 'सभी दुकानें', 'name': 'नाम',
      'phone': 'फ़ोन', 'email': 'ईमेल', 'date': 'तारीख', 'status': 'स्थिति',
      'amount': 'राशि', 'total': 'कुल', 'weight': 'वज़न', 'price': 'कीमत',
      'active': 'सक्रिय', 'inactive': 'निष्क्रिय',
      'welcomeBack': 'वापसी पर स्वागत', 'todaysSummary': 'आज का सारांश',
      'totalRevenue': 'कुल राजस्व', 'pendingPayments': 'बकाया भुगतान',
      'inventoryManagement': 'इन्वेंट्री प्रबंधन', 'inStock': 'स्टॉक में',
      'lowStock': 'कम स्टॉक', 'stockValue': 'स्टॉक मूल्य',
      'metal': 'धातु', 'purity': 'शुद्धता', 'netWeight': 'शुद्ध वज़न',
      'sellingPrice': 'बिक्री मूल्य', 'costPrice': 'लागत मूल्य',
      'billingInvoices': 'बिलिंग और चालान', 'invoices': 'चालान',
      'paid': 'भुगतान किया', 'pending': 'बकाया', 'partial': 'आंशिक',
      'gst': 'GST', 'discount': 'छूट', 'grandTotal': 'कुल राशि',
      'cash': 'नकद', 'card': 'कार्ड',
      'customerManagement': 'ग्राहक प्रबंधन', 'addCustomer': 'ग्राहक जोड़ें',
      'loyaltyPoints': 'लॉयल्टी पॉइंट्स',
      'accountsManagement': 'खाते और वित्त', 'expenses': 'खर्च',
      'suppliers': 'आपूर्तिकर्ता', 'credit': 'जमा', 'debit': 'नामे',
      'todayRates': 'आज के दर', 'liveRates': 'लाइव दर', 'perGram': 'प्रति ग्राम',
      'savingSchemes': 'बचत योजनाएँ', 'members': 'सदस्य',
      'staffManagement': 'कर्मचारी प्रबंधन', 'salary': 'वेतन',
      'attendance': 'उपस्थिति', 'permissions': 'अनुमतियाँ',
      'settingsConfig': 'सेटिंग्स', 'businessName': 'व्यवसाय का नाम',
      'customerEnquiries': 'ग्राहक पूछताछ', 'respondToEnquiry': 'जवाब दें',
      'closeEnquiry': 'पूछताछ बंद करें', 'open': 'खुला',
      'responded': 'जवाब दिया', 'closed': 'बंद',
      'moduleNotAvailable': 'मॉड्यूल उपलब्ध नहीं',
      'moduleNotAvailableDesc': 'यह सुविधा आपकी वर्तमान दुकान के लिए सक्षम नहीं है।',
      'goToDashboard': 'डैशबोर्ड पर जाएँ',
      'noDataFound': 'कोई डेटा नहीं मिला', 'loading': 'लोड हो रहा है...',
      'yes': 'हाँ', 'no': 'नहीं', 'today': 'आज', 'thisMonth': 'इस महीने',
    },
  };
}
