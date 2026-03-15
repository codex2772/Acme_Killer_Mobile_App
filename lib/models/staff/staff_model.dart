class Staff {
  final String id;
  final String name;

  final String phone;
  final String email;

  final String role;

  final String store; // store name
  final List<int> storeIds; // backend store ids

  String status;

  final double salary;
  final double commission;

  final double salesTarget;
  final double currentSales;

  final String joinDate;

  final List<String> permissions;

  final List attendance;

  final Map<String, dynamic> leaves;

  Staff({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.store,
    required this.storeIds,
    required this.status,
    required this.salary,
    required this.commission,
    required this.salesTarget,
    required this.currentSales,
    required this.joinDate,
    required this.permissions,
    required this.attendance,
    required this.leaves,
  });
}