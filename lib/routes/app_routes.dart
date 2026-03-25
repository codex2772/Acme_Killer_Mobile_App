abstract class AppRoutes {
  static const splash         = '/';
  static const roleSelect     = '/role-select';
  static const login          = '/login';
  static const changePassword = '/change-password';

  static const dashboard = '/dashboard';

  static const inventory          = '/inventory';
  static const addInventory       = '/add-inventory';
  static const inventoryDetail    = '/inventory-detail';
  static const editInventory      = '/edit-inventory';
  static const transferInventory  = '/transfer-inventory';

  static const billing            = '/billing';
  static const createInvoice      = '/create-invoice';
  static const invoiceDetail      = '/invoice-detail';
  static const createEstimate     = '/create-estimate';
  static const createCreditNote   = '/create-credit-note';

  static const customers          = '/customers';
  static const addCustomer        = '/add-customer';
  static const customerProfile    = '/customer-profile';
  static const editCustomer       = '/edit-customer';

  static const staff              = '/staff';
  static const addStaff           = '/add-staff';
  static const staffDetail        = '/staff-detail';
  static const editStaff          = '/edit-staff';

  static const accounts           = '/accounts';
  static const addLedgerEntry     = '/add-ledger-entry';
  static const addSupplier        = '/add-supplier';

  static const reports            = '/reports';
  static const reportDetail       = '/report-detail';

  static const todayRates         = '/today-rates';
  static const oldGold            = '/old-gold';
  static const addOldGold         = '/add-old-gold';
  static const oldGoldDetail      = '/old-gold-detail';
  static const schemes            = '/schemes';
  static const addScheme          = '/add-scheme';
  static const schemeDetail       = '/scheme-detail';
  static const editScheme         = '/edit-scheme';

  static const settings           = '/settings';
  static const settingsDetail     = '/settings-detail';

  // ── Enquiries — from latest Electron build ───────────────────────
  static const enquiries          = '/enquiries';
  static const enquiryDetail      = '/enquiry-detail';

  // ── Module gating — shown when module is disabled for store ──────
  // mirrors Electron router.js module-gating screen
  static const moduleNotAvailable = '/module-not-available';
}
