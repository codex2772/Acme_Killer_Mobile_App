import 'package:get/get.dart';
import '../../../models/staff/staff_model.dart';
import '../../../models/staff/attendance_model.dart';

// ── Permission constants ─────────────────────────────────────

class PermDef {
  final String id;
  final String label;
  final String group;
  const PermDef({required this.id, required this.label, required this.group});
}

const kAllPermissions = [
  PermDef(id: 'inventory_view',    label: 'View Inventory',    group: 'Inventory'),
  PermDef(id: 'inventory_manage',  label: 'Manage Inventory',  group: 'Inventory'),
  PermDef(id: 'customer_view',     label: 'View Customers',    group: 'Customers'),
  PermDef(id: 'customer_manage',   label: 'Manage Customers',  group: 'Customers'),
  PermDef(id: 'billing_view',      label: 'View Invoices',     group: 'Billing'),
  PermDef(id: 'billing_create',    label: 'Create Invoices',   group: 'Billing'),
  PermDef(id: 'accounts_view',     label: 'View Accounts',     group: 'Accounts'),
  PermDef(id: 'accounts_manage',   label: 'Manage Accounts',   group: 'Accounts'),
  PermDef(id: 'reports_view',      label: 'View Reports',      group: 'Reports'),
  PermDef(id: 'old_gold_manage',   label: 'Manage Old Gold',   group: 'Old Gold'),
  PermDef(id: 'schemes_manage',    label: 'Manage Schemes',    group: 'Schemes'),
  PermDef(id: 'rates_manage',      label: 'Update Rates',      group: 'Rates'),
];

const kAdminPermissions = [
  'inventory_view', 'inventory_manage', 'customer_view', 'customer_manage',
  'billing_view', 'billing_create', 'accounts_view', 'accounts_manage',
  'reports_view', 'old_gold_manage', 'schemes_manage', 'rates_manage',
];

Map<String, List<PermDef>> get kPermGroups {
  final map = <String, List<PermDef>>{};
  for (final p in kAllPermissions) {
    map.putIfAbsent(p.group, () => []).add(p);
  }
  return map;
}

// ── StaffController ──────────────────────────────────────────

class StaffController extends GetxController {
  final RxList<Staff> staffMembers = <Staff>[].obs;
  final RxString searchQuery  = ''.obs;
  final RxString activeFilter = 'all'.obs; // all | admin | staff | active | inactive
  final Rx<Staff?> selectedStaff = Rx<Staff?>(null);

  @override
  void onInit() {
    super.onInit();
    _seedStaff();
  }

  void _seedStaff() {
    staffMembers.assignAll([
      Staff(
        id: 'STF001', name: 'Arjun Kapoor',
        phone: '+91 99887 76655', email: 'arjun.k@jewelerp.com',
        role: 'admin', store: 'Rajmahal Jewellers - Main', storeIds: [1],
        status: 'Active', salary: 45000, commission: 0.5,
        salesTarget: 2000000, currentSales: 1650000,
        joinDate: '2024-06-15',
        permissions: kAdminPermissions,
        attendance: [
          Attendance(date:'2026-03-12', clockIn:'09:30', clockOut:'19:00', hours:9.5, status:'Present'),
          Attendance(date:'2026-03-11', clockIn:'09:15', clockOut:'18:45', hours:9.5, status:'Present'),
          Attendance(date:'2026-03-10', clockIn:'09:45', clockOut:'19:15', hours:9.5, status:'Present'),
          Attendance(date:'2026-03-09', clockIn:'',      clockOut:'',      hours:0,   status:'Sunday'),
          Attendance(date:'2026-03-08', clockIn:'09:30', clockOut:'18:30', hours:9.0, status:'Present'),
        ],
        leaves: {'total':24,'used':4,'pending':1,'balance':19},
      ),
      Staff(
        id: 'STF002', name: 'Sneha Reddy',
        phone: '+91 88776 65544', email: 'sneha.r@jewelerp.com',
        role: 'admin', store: 'Rajmahal Jewellers - Mall Road', storeIds: [2],
        status: 'Active', salary: 42000, commission: 0.5,
        salesTarget: 1500000, currentSales: 1280000,
        joinDate: '2024-09-01',
        permissions: kAdminPermissions,
        attendance: [
          Attendance(date:'2026-03-12', clockIn:'09:00', clockOut:'18:30', hours:9.5, status:'Present'),
          Attendance(date:'2026-03-11', clockIn:'09:30', clockOut:'19:00', hours:9.5, status:'Present'),
        ],
        leaves: {'total':24,'used':2,'pending':0,'balance':22},
      ),
      Staff(
        id: 'STF003', name: 'Ravi Kumar',
        phone: '+91 77665 54433', email: 'ravi.k@jewelerp.com',
        role: 'staff', store: 'Rajmahal Jewellers - Main', storeIds: [1],
        status: 'Active', salary: 28000, commission: 0.3,
        salesTarget: 800000, currentSales: 520000,
        joinDate: '2025-01-10',
        permissions: ['inventory_view','customer_view','billing_create','billing_view'],
        attendance: [
          Attendance(date:'2026-03-12', clockIn:'10:00', clockOut:'',      hours:0,    status:'Present'),
          Attendance(date:'2026-03-11', clockIn:'09:45', clockOut:'18:30', hours:8.75, status:'Present'),
          Attendance(date:'2026-03-10', clockIn:'',      clockOut:'',      hours:0,    status:'Leave'),
        ],
        leaves: {'total':18,'used':6,'pending':0,'balance':12},
      ),
      Staff(
        id: 'STF004', name: 'Pooja Nair',
        phone: '+91 66554 43322', email: 'pooja.n@jewelerp.com',
        role: 'staff', store: 'Rajmahal Jewellers - Main', storeIds: [1],
        status: 'Active', salary: 25000, commission: 0.2,
        salesTarget: 600000, currentSales: 380000,
        joinDate: '2025-03-20',
        permissions: ['inventory_view','customer_view','customer_manage','billing_create'],
        attendance: [
          Attendance(date:'2026-03-12', clockIn:'09:15', clockOut:'', hours:0, status:'Present'),
        ],
        leaves: {'total':18,'used':3,'pending':1,'balance':14},
      ),
      Staff(
        id: 'STF005', name: 'Amit Joshi',
        phone: '+91 55443 32211', email: 'amit.j@jewelerp.com',
        role: 'staff', store: 'Rajmahal Jewellers - Mall Road', storeIds: [2],
        status: 'Inactive', salary: 22000, commission: 0.0,
        salesTarget: 0, currentSales: 0,
        joinDate: '2025-06-05',
        permissions: ['inventory_view','billing_view'],
        attendance: [],
        leaves: {'total':18,'used':18,'pending':0,'balance':0},
      ),
      Staff(
        id: 'STF006', name: 'Deepa Menon',
        phone: '+91 44332 21100', email: 'deepa.m@jewelerp.com',
        role: 'staff', store: 'Rajmahal Jewellers - City Center', storeIds: [3],
        status: 'Active', salary: 26000, commission: 0.25,
        salesTarget: 700000, currentSales: 445000,
        joinDate: '2025-08-12',
        permissions: ['inventory_view','inventory_manage','customer_view','billing_create','billing_view'],
        attendance: [
          Attendance(date:'2026-03-12', clockIn:'09:30', clockOut:'', hours:0, status:'Present'),
        ],
        leaves: {'total':18,'used':2,'pending':0,'balance':16},
      ),
    ]);
  }

  // ── Filtered list ────────────────────────────────────────
  List<Staff> get filteredStaff {
    var list = staffMembers.toList();
    final f = activeFilter.value;
    if (f == 'admin')    list = list.where((s) => s.role == 'admin').toList();
    else if (f == 'staff')    list = list.where((s) => s.role == 'staff').toList();
    else if (f == 'active')   list = list.where((s) => s.status == 'Active').toList();
    else if (f == 'inactive') list = list.where((s) => s.status == 'Inactive').toList();
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.phone.contains(q) ||
        s.email.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // ── Stats ────────────────────────────────────────────────
  int get totalStaff   => staffMembers.length;
  int get adminCount   => staffMembers.where((s) => s.role == 'admin').length;
  int get staffCount   => staffMembers.where((s) => s.role == 'staff').length;
  int get activeCount  => staffMembers.where((s) => s.status == 'Active').length;

  // Store overview: returns list of {name, short, admin, staff, total}
  List<Map<String,dynamic>> get storeOverview {
    final stores = [
      'Rajmahal Jewellers - Main',
      'Rajmahal Jewellers - Mall Road',
      'Rajmahal Jewellers - City Center',
    ];
    return stores.map((s) {
      final short = s.replaceAll('Rajmahal Jewellers - ','');
      final admins = staffMembers.where((m) => m.store == s && m.role == 'admin').length;
      final staff  = staffMembers.where((m) => m.store == s && m.role == 'staff').length;
      return {'name':s,'short':short,'admin':admins,'staff':staff,'total':admins+staff};
    }).toList();
  }

  // ── Toggle active/inactive ───────────────────────────────
  void toggleStatus(String id) {
    final idx = staffMembers.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    staffMembers[idx].status =
        staffMembers[idx].status == 'Active' ? 'Inactive' : 'Active';
    staffMembers.refresh();
  }

  // ── Add staff ────────────────────────────────────────────
  void addStaff(Staff s) => staffMembers.add(s);

  // ── Update staff ─────────────────────────────────────────
  void updateStaff(String id, {
    String? name, String? phone, String? email,
    double? salary, double? commission, double? salesTarget,
    String? status, String? role, List<String>? permissions,
  }) {
    final idx = staffMembers.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final old = staffMembers[idx];
    staffMembers[idx] = Staff(
      id:           old.id,
      name:         name         ?? old.name,
      phone:        phone        ?? old.phone,
      email:        email        ?? old.email,
      role:         role         ?? old.role,
      store:        old.store,
      storeIds:     old.storeIds,
      status:       status       ?? old.status,
      salary:       salary       ?? old.salary,
      commission:   commission   ?? old.commission,
      salesTarget:  salesTarget  ?? old.salesTarget,
      currentSales: old.currentSales,
      joinDate:     old.joinDate,
      permissions:  permissions  ?? old.permissions,
      attendance:   old.attendance,
      leaves:       old.leaves,
    );
    staffMembers.refresh();
  }

  // ── Helper ───────────────────────────────────────────────
  String fmt(double v) {
    if (v >= 100000) return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹${v.toInt()}';
  }

  int targetPct(Staff s) => s.salesTarget > 0
      ? ((s.currentSales / s.salesTarget) * 100).round().clamp(0, 100)
      : 0;

  double commissionEarned(Staff s) =>
      (s.currentSales * s.commission / 100);

  String initials(String name) =>
      name.trim().split(' ').map((n) => n.isNotEmpty ? n[0].toUpperCase() : '').take(2).join();
}
