class LeaveRequest {

  String id;
  String staffId;
  String fromDate;
  String toDate;
  String status;

  LeaveRequest({
    required this.id,
    required this.staffId,
    required this.fromDate,
    required this.toDate,
    this.status = "Pending",
  });
}