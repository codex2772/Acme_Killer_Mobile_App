class Attendance {
  String date;
  String clockIn;
  String clockOut;
  double hours;
  String status;

  Attendance({
    required this.date,
    this.clockIn = "",
    this.clockOut = "",
    this.hours = 0,
    this.status = "Absent",
  });
}