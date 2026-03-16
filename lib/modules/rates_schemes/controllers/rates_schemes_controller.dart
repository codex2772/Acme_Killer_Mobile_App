import 'package:get/get.dart';

// ─── Rates models ───────────────────────────────────────────

class MetalRate {
  final String metal;
  final int colorValue;
  RxInt rate;
  final String change;
  final bool trendUp;

  MetalRate({
    required this.metal,
    required this.colorValue,
    required int initialRate,
    required this.change,
    required this.trendUp,
  }) : rate = initialRate.obs;

  int get tolaRate => (rate.value * 11.664).round();
  String get formattedRate => '₹${_fmt(rate.value)}/g';
  String get formattedTola => '₹${_fmt(tolaRate)}/tola';

  static String _fmt(int v) {
    if (v >= 1000) {
      return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return v.toString();
  }
}

class RateHistoryEntry {
  final String date;
  final int gold22k;
  final int gold24k;
  final double silver;
  final int platinum;
  const RateHistoryEntry({
    required this.date, required this.gold22k, required this.gold24k,
    required this.silver, required this.platinum,
  });
}

class RateAlert {
  final String id;
  final String metal;
  final String condition; // below | above
  final int threshold;
  final String customer;
  bool active;
  RateAlert({required this.id, required this.metal, required this.condition,
    required this.threshold, required this.customer, required this.active});
}

// ─── Old Gold models ─────────────────────────────────────────

class PurityTest {
  final String method;
  final String actualPurity;
  final String purityPercent;
  final String testedBy;
  const PurityTest({required this.method, required this.actualPurity,
    required this.purityPercent, required this.testedBy});
}

class MeltingRecord {
  final String meltedWeight;
  final String meltDate;
  final String meltedBy;
  const MeltingRecord({required this.meltedWeight, required this.meltDate, required this.meltedBy});
}

class OldGoldEntry {
  final String id;
  final String customer;
  final String? customerId;
  final double weight;
  final String purity;
  final int rate;
  final int totalNum;
  final String date;
  final String type; // Exchange | Purchase
  final String store;
  final PurityTest? purityTest;
  final MeltingRecord? meltingRecord;
  final bool kycDone;
  final String notes;

  const OldGoldEntry({
    required this.id, required this.customer, this.customerId,
    required this.weight, required this.purity, required this.rate,
    required this.totalNum, required this.date, required this.type,
    required this.store, this.purityTest, this.meltingRecord,
    required this.kycDone, required this.notes,
  });

  String get formattedTotal {
    final v = totalNum;
    if (v >= 100000) return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }
}

// ─── Scheme models ───────────────────────────────────────────

class SchemePayment {
  final String month;
  final int amount;
  final String? date;
  String status; // Paid | Due | Upcoming
  SchemePayment({required this.month, required this.amount, this.date, required this.status});
}

class SchemeMember {
  final String id;
  final String name;
  final String phone;
  final String joinDate;
  int totalPaid;
  String status;
  final List<SchemePayment> payments;
  SchemeMember({required this.id, required this.name, required this.phone,
    required this.joinDate, required this.totalPaid, required this.status,
    required this.payments});

  bool get hasDue => payments.any((p) => p.status == 'Due');
  SchemePayment? get nextDue {
    try { return payments.firstWhere((p) => p.status == 'Due'); } catch (_) { return null; }
  }
}

class Scheme {
  String id;
  String name;
  String duration;
  int durationMonths;
  int monthlyAmtNum;
  String status;
  final String store;
  String startDate;
  String endDate;
  String bonusMonth;
  String description;
  List<SchemeMember> memberList;

  Scheme({
    required this.id, required this.name, required this.duration,
    required this.durationMonths, required this.monthlyAmtNum,
    required this.status, required this.store, required this.startDate,
    required this.endDate, required this.bonusMonth, required this.description,
    required this.memberList,
  });

  String get monthlyAmt {
    final v = monthlyAmtNum;
    if (v >= 1000) return '₹${v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    return '₹$v';
  }

  int get members => memberList.length;
  int get maturityValue => monthlyAmtNum * durationMonths;
  int get totalCollected => memberList.fold(0, (s, m) => s + m.totalPaid);
  int get dueCount => memberList.where((m) => m.hasDue).length;
}

// ─── Main controller ─────────────────────────────────────────

class RatesSchemesController extends GetxController {

  // Rates
  final List<MetalRate> metals = [
    MetalRate(metal:'Gold 24K',       colorValue:0xFFF0D060, initialRate:7350, change:'+₹18', trendUp:true),
    MetalRate(metal:'Gold 22K',       colorValue:0xFFD4AF37, initialRate:6285, change:'+₹15', trendUp:true),
    MetalRate(metal:'Gold 18K',       colorValue:0xFFB8941E, initialRate:5140, change:'+₹12', trendUp:true),
    MetalRate(metal:'Gold 14K',       colorValue:0xFF94750F, initialRate:4010, change:'+₹8',  trendUp:true),
    MetalRate(metal:'Silver (925)',   colorValue:0xFF94A3B8, initialRate:92,   change:'+₹0.50',trendUp:true),
    MetalRate(metal:'Platinum (950)', colorValue:0xFFE2E8F0, initialRate:3150, change:'+₹5',  trendUp:true),
    MetalRate(metal:'Rhodium',        colorValue:0xFFC084FC, initialRate:13500,change:'-₹50', trendUp:false),
    MetalRate(metal:'Rose Gold 18K',  colorValue:0xFFF472B6, initialRate:5200, change:'+₹10', trendUp:true),
    MetalRate(metal:'White Gold 18K', colorValue:0xFF60A5FA, initialRate:5300, change:'+₹12', trendUp:true),
  ];

  final List<RateHistoryEntry> rateHistory = const [
    RateHistoryEntry(date:'2026-03-12',gold22k:6285,gold24k:7350,silver:92.0,  platinum:3150),
    RateHistoryEntry(date:'2026-03-11',gold22k:6270,gold24k:7332,silver:91.5, platinum:3145),
    RateHistoryEntry(date:'2026-03-10',gold22k:6247,gold24k:7305,silver:91.0,  platinum:3165),
    RateHistoryEntry(date:'2026-03-09',gold22k:6230,gold24k:7285,silver:90.5, platinum:3140),
    RateHistoryEntry(date:'2026-03-08',gold22k:6210,gold24k:7260,silver:90.0,  platinum:3155),
    RateHistoryEntry(date:'2026-03-07',gold22k:6195,gold24k:7241,silver:89.5, platinum:3148),
    RateHistoryEntry(date:'2026-03-06',gold22k:6178,gold24k:7220,silver:89.0,  platinum:3135),
  ];

  final RxList<RateAlert> rateAlerts = <RateAlert>[
    RateAlert(id:'RA001', metal:'Gold 22K',  condition:'below', threshold:6200, customer:'Priya Sharma',  active:true),
    RateAlert(id:'RA002', metal:'Gold 24K',  condition:'above', threshold:7500, customer:'Anita Desai',   active:true),
    RateAlert(id:'RA003', metal:'Silver',    condition:'below', threshold:88,   customer:'Vikram Singh',  active:false),
  ].obs;

  // Old Gold
  final RxList<OldGoldEntry> oldGoldPurchases = <OldGoldEntry>[
    OldGoldEntry(id:'OG001', customer:'Priya Sharma', customerId:'CUS001',
      weight:15.20, purity:'22K', rate:6150, totalNum:93480,
      date:'2026-03-08', type:'Exchange', store:'Rajmahal Jewellers - Main',
      purityTest:const PurityTest(method:'XRF', actualPurity:'21.8K', purityPercent:'90.8%', testedBy:'Arjun Kapoor'),
      kycDone:true, notes:'Old bangles exchanged for new necklace'),
    OldGoldEntry(id:'OG002', customer:'Walk-in', customerId:null,
      weight:8.50, purity:'18K', rate:5020, totalNum:42670,
      date:'2026-03-06', type:'Purchase', store:'Rajmahal Jewellers - Mall Road',
      purityTest:const PurityTest(method:'Touchstone', actualPurity:'17.5K', purityPercent:'72.9%', testedBy:'Sneha Reddy'),
      meltingRecord:const MeltingRecord(meltedWeight:'8.20', meltDate:'2026-03-07', meltedBy:'Ravi Kumar'),
      kycDone:false, notes:'Walk-in customer selling old chain'),
    OldGoldEntry(id:'OG003', customer:'Vikram Singh', customerId:'CUS004',
      weight:32.00, purity:'22K', rate:6180, totalNum:197760,
      date:'2026-03-04', type:'Exchange', store:'Rajmahal Jewellers - City Center',
      purityTest:const PurityTest(method:'XRF', actualPurity:'22K', purityPercent:'91.6%', testedBy:'Arjun Kapoor'),
      kycDone:true, notes:'KYC completed — PAN verified'),
  ].obs;

  final RxString ogFilter = 'all'.obs;

  // Schemes
  final RxList<Scheme> schemes = <Scheme>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedSchemes();
  }

  void _seedSchemes() {
    schemes.assignAll([
      Scheme(
        id:'SCH001', name:'Gold Savings Plan', duration:'11 months',
        durationMonths:11, monthlyAmtNum:5000, status:'Active',
        store:'Rajmahal Jewellers - Main',
        startDate:'2025-06-01', endDate:'2026-05-01',
        bonusMonth:'Yes (12th month free)',
        description:'Pay ₹5,000/month for 11 months, get 12th month free. Total value ₹60,000 for only ₹55,000 paid.',
        memberList:[
          SchemeMember(id:'SM001', name:'Priya Sharma', phone:'+91 98765 43210', joinDate:'2025-06-01', totalPaid:45000, status:'Active',
            payments:[
              SchemePayment(month:'Jun 2025',amount:5000,date:'2025-06-05',status:'Paid'),
              SchemePayment(month:'Jul 2025',amount:5000,date:'2025-07-03',status:'Paid'),
              SchemePayment(month:'Aug 2025',amount:5000,date:'2025-08-04',status:'Paid'),
              SchemePayment(month:'Sep 2025',amount:5000,date:'2025-09-02',status:'Paid'),
              SchemePayment(month:'Oct 2025',amount:5000,date:'2025-10-05',status:'Paid'),
              SchemePayment(month:'Nov 2025',amount:5000,date:'2025-11-03',status:'Paid'),
              SchemePayment(month:'Dec 2025',amount:5000,date:'2025-12-04',status:'Paid'),
              SchemePayment(month:'Jan 2026',amount:5000,date:'2026-01-06',status:'Paid'),
              SchemePayment(month:'Feb 2026',amount:5000,date:'2026-02-03',status:'Paid'),
              SchemePayment(month:'Mar 2026',amount:5000,date:null,status:'Due'),
              SchemePayment(month:'Apr 2026',amount:5000,date:null,status:'Upcoming'),
            ]),
          SchemeMember(id:'SM002', name:'Meera Patel', phone:'+91 54321 09876', joinDate:'2025-06-01', totalPaid:50000, status:'Active',
            payments:[
              SchemePayment(month:'Jun 2025',amount:5000,date:'2025-06-02',status:'Paid'),
              SchemePayment(month:'Jul 2025',amount:5000,date:'2025-07-01',status:'Paid'),
              SchemePayment(month:'Aug 2025',amount:5000,date:'2025-08-05',status:'Paid'),
              SchemePayment(month:'Sep 2025',amount:5000,date:'2025-09-08',status:'Paid'),
              SchemePayment(month:'Oct 2025',amount:5000,date:'2025-10-02',status:'Paid'),
              SchemePayment(month:'Nov 2025',amount:5000,date:'2025-11-06',status:'Paid'),
              SchemePayment(month:'Dec 2025',amount:5000,date:'2025-12-01',status:'Paid'),
              SchemePayment(month:'Jan 2026',amount:5000,date:'2026-01-04',status:'Paid'),
              SchemePayment(month:'Feb 2026',amount:5000,date:'2026-02-07',status:'Paid'),
              SchemePayment(month:'Mar 2026',amount:5000,date:'2026-03-05',status:'Paid'),
              SchemePayment(month:'Apr 2026',amount:5000,date:null,status:'Upcoming'),
            ]),
        ],
      ),
      Scheme(
        id:'SCH002', name:'Diamond Club', duration:'12 months',
        durationMonths:12, monthlyAmtNum:10000, status:'Active',
        store:'Rajmahal Jewellers - Main',
        startDate:'2025-09-01', endDate:'2026-09-01',
        bonusMonth:'Yes (13th month free)',
        description:'Premium scheme: Pay ₹10,000/month for 12 months, get 13th month bonus.',
        memberList:[
          SchemeMember(id:'SM003', name:'Anita Desai', phone:'+91 76543 21098', joinDate:'2025-09-01', totalPaid:60000, status:'Active',
            payments:[
              SchemePayment(month:'Sep 2025',amount:10000,date:'2025-09-01',status:'Paid'),
              SchemePayment(month:'Oct 2025',amount:10000,date:'2025-10-03',status:'Paid'),
              SchemePayment(month:'Nov 2025',amount:10000,date:'2025-11-05',status:'Paid'),
              SchemePayment(month:'Dec 2025',amount:10000,date:'2025-12-02',status:'Paid'),
              SchemePayment(month:'Jan 2026',amount:10000,date:'2026-01-08',status:'Paid'),
              SchemePayment(month:'Feb 2026',amount:10000,date:'2026-02-04',status:'Paid'),
              SchemePayment(month:'Mar 2026',amount:10000,date:null,status:'Due'),
              SchemePayment(month:'Apr 2026',amount:10000,date:null,status:'Upcoming'),
            ]),
        ],
      ),
      Scheme(
        id:'SCH003', name:'Silver Saver', duration:'11 months',
        durationMonths:11, monthlyAmtNum:2000, status:'Closed',
        store:'Rajmahal Jewellers - Mall Road',
        startDate:'2024-09-01', endDate:'2025-08-01',
        bonusMonth:'No Bonus',
        description:'Entry-level scheme for silver jewellery buyers.',
        memberList:[],
      ),
    ]);
  }

  // ─── Rates operations ───
  void updateRates({int? g22k, int? g24k, int? g18k, int? silver, int? platinum}) {
    if (g22k != null) metals[1].rate.value = g22k;
    if (g24k != null) metals[0].rate.value = g24k;
    if (g18k != null) metals[2].rate.value = g18k;
    if (silver != null) metals[4].rate.value = silver;
    if (platinum != null) metals[5].rate.value = platinum;
  }

  void addRateAlert(RateAlert alert) => rateAlerts.add(alert);
  void toggleAlert(String id) {
    final idx = rateAlerts.indexWhere((a) => a.id == id);
    if (idx != -1) { rateAlerts[idx].active = !rateAlerts[idx].active; rateAlerts.refresh(); }
  }
  void deleteAlert(String id) => rateAlerts.removeWhere((a) => a.id == id);

  // ─── Old Gold operations ───
  List<OldGoldEntry> get filteredOldGold {
    if (ogFilter.value == 'all') return oldGoldPurchases.toList();
    return oldGoldPurchases.where((p) => p.type.toLowerCase() == ogFilter.value).toList();
  }

  void addOldGold(OldGoldEntry entry) => oldGoldPurchases.insert(0, entry);

  // ─── Scheme operations ───
  Scheme? getScheme(String id) {
    try { return schemes.firstWhere((s) => s.id == id); } catch (_) { return null; }
  }

  void addScheme(Scheme s) { schemes.add(s); schemes.refresh(); }

  void updateScheme(String id, {String? name, int? monthlyAmt, String? status,
    String? endDate, String? description}) {
    final idx = schemes.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    if (name != null) schemes[idx].name = name;
    if (monthlyAmt != null) schemes[idx].monthlyAmtNum = monthlyAmt;
    if (status != null) schemes[idx].status = status;
    if (endDate != null) schemes[idx].endDate = endDate;
    if (description != null) schemes[idx].description = description;
    schemes.refresh();
  }

  void addMember(String schemeId, SchemeMember member) {
    final idx = schemes.indexWhere((s) => s.id == schemeId);
    if (idx == -1) return;
    schemes[idx].memberList.add(member);
    schemes.refresh();
  }

  void recordSchemePayment(String schemeId, String memberId) {
    final scheme = getScheme(schemeId);
    if (scheme == null) return;
    final member = scheme.memberList.firstWhereOrNull((m) => m.id == memberId);
    if (member == null) return;
    final due = member.nextDue;
    if (due == null) return;
    due.status = 'Paid';
    member.totalPaid += due.amount;
    schemes.refresh();
  }

  // ─── Helpers ───
  String fmt(int v) {
    if (v >= 10000000) return '₹${(v/10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '₹${(v/100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '₹${(v/1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  int get goldRate22k => metals[1].rate.value;
}
