import 'package:acme_killer_mobile_app/services/settings_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../../../services/rates_service.dart';
import '../../../services/api_client.dart';
import '../../../core/controllers/store_controller.dart';

// ─── Models (unchanged) ───────────────────────────────────────────
class MetalRate {
  final String metal;
  final int colorValue;
  RxInt rate;
  RxString change;
  RxBool trendUp;
  MetalRate({
    required this.metal,
    required this.colorValue,
    required int initialRate,
    String initialChange = '',
    bool initialTrendUp = true,
  }) : rate = initialRate.obs,
       change = initialChange.obs,
       trendUp = initialTrendUp.obs;

  int get tolaRate => (rate.value * 11.664).round();
  String get formattedRate => '₹${_fmt(rate.value)}/g';
  String get formattedTola => '₹${_fmt(tolaRate)}/tola';
  static String _fmt(int v) {
    if (v >= 1000)
      return v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    return v.toString();
  }
}

class RateHistoryEntry {
  final String date;
  final int gold22k, gold24k, platinum;
  final double silver;
  const RateHistoryEntry({
    required this.date,
    required this.gold22k,
    required this.gold24k,
    required this.silver,
    required this.platinum,
  });
}

class RateAlert {
  final String id, metal, condition, customer;
  final int threshold;
  bool active;
  RateAlert({
    required this.id,
    required this.metal,
    required this.condition,
    required this.threshold,
    required this.customer,
    required this.active,
  });
}

class PurityTest {
  final String method, actualPurity, purityPercent, testedBy;
  const PurityTest({
    required this.method,
    required this.actualPurity,
    required this.purityPercent,
    required this.testedBy,
  });
}

class MeltingRecord {
  final String meltedWeight, meltDate, meltedBy;
  const MeltingRecord({
    required this.meltedWeight,
    required this.meltDate,
    required this.meltedBy,
  });
}

class OldGoldEntry {
  final String id, customer, date, type, store, notes;
  final String? customerId;
  final double weight;
  final String purity;
  final int rate, totalNum;
  final PurityTest? purityTest;
  final MeltingRecord? meltingRecord;
  final bool kycDone;
  int? backendId;
  OldGoldEntry({
    required this.id,
    required this.customer,
    this.customerId,
    required this.weight,
    required this.purity,
    required this.rate,
    required this.totalNum,
    required this.date,
    required this.type,
    required this.store,
    this.purityTest,
    this.meltingRecord,
    required this.kycDone,
    required this.notes,
    this.backendId,
  });
  String get formattedTotal {
    if (totalNum >= 100000)
      return '₹${(totalNum / 100000).toStringAsFixed(1)}L';
    if (totalNum >= 1000) return '₹${(totalNum / 1000).toStringAsFixed(0)}K';
    return '₹$totalNum';
  }
}

class SchemePayment {
  final String month;
  final int amount;
  final String? date;
  String status;
  SchemePayment({
    required this.month,
    required this.amount,
    this.date,
    required this.status,
  });
}

class SchemeMember {
  final String id, name, phone, joinDate;
  int totalPaid;
  String status;
  final List<SchemePayment> payments;
  int? backendId;
  SchemeMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinDate,
    required this.totalPaid,
    required this.status,
    required this.payments,
    this.backendId,
  });
  bool get hasDue => payments.any((p) => p.status == 'Due');
  SchemePayment? get nextDue {
    try {
      return payments.firstWhere((p) => p.status == 'Due');
    } catch (_) {
      return null;
    }
  }
}

class Scheme {
  String id,
      name,
      duration,
      status,
      store,
      startDate,
      endDate,
      bonusMonth,
      description;
  int durationMonths, monthlyAmtNum;
  List<SchemeMember> memberList;
  int? backendId;
  Scheme({
    required this.id,
    required this.name,
    required this.duration,
    required this.durationMonths,
    required this.monthlyAmtNum,
    required this.status,
    required this.store,
    required this.startDate,
    required this.endDate,
    required this.bonusMonth,
    required this.description,
    required this.memberList,
    this.backendId,
  });
  String get monthlyAmt {
    final v = monthlyAmtNum;
    if (v >= 1000)
      return '₹${v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    return '₹$v';
  }

  int get members => memberList.length;
  int get maturityValue => monthlyAmtNum * durationMonths;
  int get totalCollected => memberList.fold(0, (s, m) => s + m.totalPaid);
  int get dueCount => memberList.where((m) => m.hasDue).length;
}

// ════════════════════════════════════════════════════════════════════
// RatesSchemesController
// mirrors Electron rates_oldgold_schemes.js
// ════════════════════════════════════════════════════════════════════
class RatesSchemesController extends GetxController {
  final StoreController _store = Get.find<StoreController>();

  final List<MetalRate> metals = [
    MetalRate(metal: 'Gold 24K', colorValue: 0xFFF0D060, initialRate: 0),
    MetalRate(metal: 'Gold 22K', colorValue: 0xFFD4AF37, initialRate: 0),
    MetalRate(metal: 'Gold 18K', colorValue: 0xFFB8941E, initialRate: 0),
    MetalRate(metal: 'Gold 14K', colorValue: 0xFF94750F, initialRate: 0),
    MetalRate(metal: 'Silver (925)', colorValue: 0xFF94A3B8, initialRate: 0),
    MetalRate(metal: 'Platinum (950)', colorValue: 0xFFE2E8F0, initialRate: 0),
    MetalRate(metal: 'Rhodium', colorValue: 0xFFC084FC, initialRate: 0),
    MetalRate(metal: 'Rose Gold 18K', colorValue: 0xFFF472B6, initialRate: 0),
    MetalRate(metal: 'White Gold 18K', colorValue: 0xFF60A5FA, initialRate: 0),
  ];

  final RxList<RateHistoryEntry> rateHistory = <RateHistoryEntry>[
    const RateHistoryEntry(
      date: '2026-03-12',
      gold22k: 6285,
      gold24k: 7350,
      silver: 92.0,
      platinum: 3150,
    ),
    const RateHistoryEntry(
      date: '2026-03-11',
      gold22k: 6270,
      gold24k: 7332,
      silver: 91.5,
      platinum: 3145,
    ),
    const RateHistoryEntry(
      date: '2026-03-10',
      gold22k: 6247,
      gold24k: 7305,
      silver: 91.0,
      platinum: 3165,
    ),
  ].obs;

  final RxList<RateAlert> rateAlerts = <RateAlert>[
    RateAlert(
      id: 'RA001',
      metal: 'Gold 22K',
      condition: 'below',
      threshold: 6200,
      customer: 'Priya Sharma',
      active: true,
    ),
    RateAlert(
      id: 'RA002',
      metal: 'Gold 24K',
      condition: 'above',
      threshold: 7500,
      customer: 'Anita Desai',
      active: true,
    ),
  ].obs;

  final RxList<OldGoldEntry> oldGoldPurchases = <OldGoldEntry>[].obs;
  final RxString ogFilter = 'all'.obs;
  final RxList<Scheme> schemes = <Scheme>[].obs;
  final RxBool isLoadingRates = false.obs;
  final RxBool isFetchingLive = false.obs;

  @override
  void onInit() {
    super.onInit();
    _seedSchemes();
    _seedOldGold();
    // Load all from API in parallel (mirrors Electron parallel Promise.all)
    _loadRates();
    _loadOldGold();
    _loadSchemes();
  }

  // ════════════════════════════════════════════════════════════════
  // RATES API — GET /api/rates + /api/rates/history + /api/rates/alerts
  // mirrors Electron renderTodayRates() parallel fetch
  // ════════════════════════════════════════════════════════════════
  Future<void> _loadRates() async {
    isLoadingRates.value = true;
    try {
      final svc = Get.find<RatesService>();
      final results = await Future.wait([
        svc.get(),
        svc.history(days: 30),
        svc.alertsList(),
      ]);

      // Rates
      if (results[0].success && results[0].data is Map) {
        final d = results[0].data as Map<String, dynamic>;
        if (d['gold24k'] != null)
          metals[0].rate.value = (d['gold24k'] as num).toInt();
        if (d['gold22k'] != null)
          metals[1].rate.value = (d['gold22k'] as num).toInt();
        if (d['gold18k'] != null)
          metals[2].rate.value = (d['gold18k'] as num).toInt();
        if (d['gold14k'] != null)
          metals[3].rate.value = (d['gold14k'] as num).toInt();
        if (d['silver'] != null)
          metals[4].rate.value = (d['silver'] as num).toInt();
        if (d['platinum'] != null)
          metals[5].rate.value = (d['platinum'] as num).toInt();
      }

      // History — compute live change strings from yesterday vs today
      if (results[1].success && results[1].data is List) {
        final rawHistory = results[1].data as List;
        final history = rawHistory.map((h) {
          final m = h as Map<String, dynamic>;
          return RateHistoryEntry(
            date: (m['date'] ?? '').toString().substring(0, 10),
            gold22k: (m['gold22k'] as num?)?.toInt() ?? 0,
            gold24k: (m['gold24k'] as num?)?.toInt() ?? 0,
            silver: (m['silver'] as num?)?.toDouble() ?? 0,
            platinum: (m['platinum'] as num?)?.toInt() ?? 0,
          );
        }).toList();
        if (history.isNotEmpty) {
          rateHistory.assignAll(history);

          // Compute change from previous day (mirrors Electron change display)
          if (history.length >= 2) {
            final today = history.first;
            final prev = history[1];
            _applyChange(0, today.gold24k, prev.gold24k);
            _applyChange(1, today.gold22k, prev.gold22k);
            _applyChange(4, today.silver.toInt(), prev.silver.toInt());
            _applyChange(5, today.platinum, prev.platinum);
          }
        }
      }

      // Alerts
      if (results[2].success && results[2].data is List) {
        final alerts = (results[2].data as List).map((a) {
          final m = a as Map<String, dynamic>;
          return RateAlert(
            id: m['id']?.toString() ?? '',
            metal: m['metal']?.toString() ?? '',
            condition: m['condition']?.toString() ?? 'below',
            threshold: (m['threshold'] as num?)?.toInt() ?? 0,
            customer: m['customerName']?.toString() ?? '',
            active: m['active'] == true,
          );
        }).toList();
        if (alerts.isNotEmpty) rateAlerts.assignAll(alerts);
      }
    } catch (e) {
      debugPrint('[RatesController] _loadRates failed: $e');
    }
    isLoadingRates.value = false;
  }

  // ── Fetch live rates — mirrors Electron rates:fetch-live ──
  Future<bool> fetchLiveRates() async {
    isFetchingLive.value = true;
    try {
      final result = await Get.find<RatesService>().fetchLive();
      if (result.success && result.data is Map) {
        final d = result.data as Map<String, dynamic>;
        updateRates(
          g24k: (d['gold24k'] as num?)?.toInt(),
          g22k: (d['gold22k'] as num?)?.toInt(),
          g18k: (d['gold18k'] as num?)?.toInt(),
          silver: (d['silver'] as num?)?.toInt(),
          platinum: (d['platinum'] as num?)?.toInt(),
        );
        isFetchingLive.value = false;
        return true;
      }
    } catch (e) {
      debugPrint('[RatesController] fetchLive failed: $e');
    }
    isFetchingLive.value = false;
    return false;
  }

  void updateRates({
    int? g22k,
    int? g24k,
    int? g18k,
    int? silver,
    int? platinum,
  }) {
    if (g24k != null) metals[0].rate.value = g24k;
    if (g22k != null) metals[1].rate.value = g22k;
    if (g18k != null) metals[2].rate.value = g18k;
    if (silver != null) metals[4].rate.value = silver;
    if (platinum != null) metals[5].rate.value = platinum;
  }

  Future<bool> saveRates() async {
    try {
      final r = await Get.find<RatesService>().update({
        'gold24k': metals[0].rate.value,
        'gold22k': metals[1].rate.value,
        'gold18k': metals[2].rate.value,
        'gold14k': metals[3].rate.value,
        'silver': metals[4].rate.value,
        'platinum': metals[5].rate.value,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  void addRateAlert(RateAlert alert) => rateAlerts.add(alert);
  void toggleAlert(String id) {
    final idx = rateAlerts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      rateAlerts[idx].active = !rateAlerts[idx].active;
      rateAlerts.refresh();
    }
  }

  void deleteAlert(String id) => rateAlerts.removeWhere((a) => a.id == id);

  // Compute and apply the change string + trend for a metal
  // mirrors Electron: formatRateChange(current, previous)
  void _applyChange(int idx, int current, int previous) {
    if (previous <= 0 || current <= 0) return;
    final diff = current - previous;
    metals[idx].change.value = diff == 0
        ? 'No change'
        : diff > 0
        ? '+₹$diff'
        : '-₹${diff.abs()}';
    metals[idx].trendUp.value = diff >= 0;
  }

  // Public refresh — called when Rates screen opens to get latest data
  Future<void> refreshRates() => _loadRates();

  // ════════════════════════════════════════════════════════════════
  // OLD GOLD API — GET /api/old-gold, POST /api/old-gold
  // ════════════════════════════════════════════════════════════════
  Future<void> _loadOldGold() async {
    try {
      final r = await Get.find<OldGoldService>().list();
      if (r.success && r.data is List && (r.data as List).isNotEmpty) {
        final items = (r.data as List).map((e) {
          final m = e as Map<String, dynamic>;
          final entry = OldGoldEntry(
            id: m['id']?.toString() ?? '',
            customer: m['customerName']?.toString() ?? '',
            customerId: m['customerId']?.toString(),
            weight: (m['weight'] as num?)?.toDouble() ?? 0,
            purity: m['purity']?.toString() ?? '',
            rate: (m['rate'] as num?)?.toInt() ?? 0,
            totalNum: (m['total'] as num?)?.toInt() ?? 0,
            date: (m['date'] ?? '').toString().substring(0, 10),
            type: m['type']?.toString() ?? 'Purchase',
            store: m['storeName']?.toString() ?? '',
            kycDone: m['kycDone'] == true,
            notes: m['notes']?.toString() ?? '',
            backendId: m['id'] as int?,
          );
          return entry;
        }).toList();
        oldGoldPurchases.assignAll(items);
      }
    } catch (e) {
      debugPrint('[RatesController] load failed: $e');
    }
  }

  Future<bool> addOldGold(OldGoldEntry entry) async {
    oldGoldPurchases.insert(0, entry);
    try {
      final r = await Get.find<OldGoldService>().create({
        'customerName': entry.customer,
        'customerId': entry.customerId,
        'weight': entry.weight,
        'purity': entry.purity,
        'rate': entry.rate,
        'total': entry.totalNum,
        'date': entry.date,
        'type': entry.type,
        'kycDone': entry.kycDone,
        'notes': entry.notes,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  List<OldGoldEntry> get filteredOldGold {
    if (ogFilter.value == 'all') return oldGoldPurchases.toList();
    return oldGoldPurchases
        .where((p) => p.type.toLowerCase() == ogFilter.value)
        .toList();
  }

  // ════════════════════════════════════════════════════════════════
  // SCHEMES API — fetchAllStores with moduleCode='SCHEMES'
  // mirrors Electron: fetchAllStores(() => schemes.list(), 'SCHEMES')
  // ════════════════════════════════════════════════════════════════
  Future<void> _loadSchemes() async {
    try {
      final svc = Get.find<SchemesService>();
      final storeCtx = Get.find<StoreContextService>();
      final stores = _store.stores;

      final List<Map<String, dynamic>> allRaw = [];

      if (stores.length > 1 && _store.selectedStore.value == null) {
        for (final s in stores) {
          // Mirror Electron: skip stores where SCHEMES module is disabled
          // (ModuleGatingService handles this automatically via X-Store-Id header)
          storeCtx.switchStore(s.id);
          final r = await svc.list();
          if (r.success && r.data is List) {
            for (final item in (r.data as List)) {
              final m = Map<String, dynamic>.from(item as Map);
              m['_storeName'] = s.name;
              allRaw.add(m);
            }
          }
        }
        storeCtx.clearStore();
      } else {
        final r = await svc.list();
        if (r.success && r.data is List)
          allRaw.addAll(List<Map<String, dynamic>>.from(r.data as List));
      }

      if (allRaw.isNotEmpty) {
        final mapped = allRaw
            .map(
              (m) => Scheme(
                id: m['id']?.toString() ?? '',
                name: m['name']?.toString() ?? '',
                duration: '${m['durationMonths'] ?? 11} months',
                durationMonths: (m['durationMonths'] as num?)?.toInt() ?? 11,
                monthlyAmtNum: (m['monthlyAmount'] as num?)?.toInt() ?? 0,
                status: m['status']?.toString() ?? 'Active',
                store: m['_storeName']?.toString() ?? '',
                startDate: (m['startDate'] ?? '').toString().substring(0, 10),
                endDate: (m['endDate'] ?? '').toString().substring(0, 10),
                bonusMonth: m['bonusMonth']?.toString() ?? '',
                description: m['description']?.toString() ?? '',
                memberList: [],
                backendId: m['id'] as int?,
              ),
            )
            .toList();
        schemes.assignAll(mapped);
        // Load members for each scheme
        for (final scheme in schemes) {
          if (scheme.backendId != null) _loadSchemeMembers(scheme);
        }
      }
    } catch (e) {
      debugPrint('[RatesController] load failed: $e');
    }
  }

  Future<void> _loadSchemeMembers(Scheme scheme) async {
    try {
      final r = await Get.find<SchemesService>().members(scheme.backendId);
      if (r.success && r.data is List) {
        final members = (r.data as List).map((m) {
          final mm = m as Map<String, dynamic>;
          return SchemeMember(
            id: mm['id']?.toString() ?? '',
            name: mm['customerName']?.toString() ?? '',
            phone: mm['customerPhone']?.toString() ?? '',
            joinDate: (mm['joinDate'] ?? '').toString().substring(0, 10),
            totalPaid: (mm['totalPaid'] as num?)?.toInt() ?? 0,
            status: mm['status']?.toString() ?? 'Active',
            payments: [],
            backendId: mm['id'] as int?,
          );
        }).toList();
        scheme.memberList = members;
        schemes.refresh();
      }
    } catch (e) {
      debugPrint('[RatesController] load failed: $e');
    }
  }

  Scheme? getScheme(String id) {
    try {
      return schemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addScheme(Scheme s) async {
    schemes.add(s);
    schemes.refresh();
    try {
      final r = await Get.find<SchemesService>().create({
        'name': s.name,
        'duration': s.duration,
        'durationMonths': s.durationMonths,
        'monthlyAmount': s.monthlyAmtNum,
        'startDate': s.startDate,
        'endDate': s.endDate,
        'bonusMonth': s.bonusMonth,
        'description': s.description,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  Future<bool> updateScheme(
    String id, {
    String? name,
    int? monthlyAmt,
    String? status,
    String? endDate,
    String? description,
  }) async {
    final idx = schemes.indexWhere((s) => s.id == id);
    if (idx == -1) return false;
    if (name != null) schemes[idx].name = name;
    if (monthlyAmt != null) schemes[idx].monthlyAmtNum = monthlyAmt;
    if (status != null) schemes[idx].status = status;
    if (endDate != null) schemes[idx].endDate = endDate;
    if (description != null) schemes[idx].description = description;
    schemes.refresh();
    final bid = schemes[idx].backendId;
    if (bid == null) return false;
    try {
      final r = await Get.find<SchemesService>().update(bid, {
        'name': schemes[idx].name,
        'status': schemes[idx].status,
        'endDate': schemes[idx].endDate,
        'description': schemes[idx].description,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  Future<bool> addMember(String schemeId, SchemeMember member) async {
    final idx = schemes.indexWhere((s) => s.id == schemeId);
    if (idx == -1) return false;
    schemes[idx].memberList.add(member);
    schemes.refresh();
    final bid = schemes[idx].backendId;
    if (bid == null) return false;
    try {
      final r = await Get.find<SchemesService>().addMember(bid, {
        'customerName': member.name,
        'customerPhone': member.phone,
        'joinDate': member.joinDate,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  Future<bool> recordSchemePayment(String schemeId, String memberId) async {
    final scheme = getScheme(schemeId);
    if (scheme == null) return false;
    final member = scheme.memberList.firstWhereOrNull((m) => m.id == memberId);
    if (member == null) return false;
    final due = member.nextDue;
    if (due == null) return false;
    due.status = 'Paid';
    member.totalPaid += due.amount;
    schemes.refresh();
    final sbid = scheme.backendId;
    final mbid = member.backendId;
    if (sbid == null || mbid == null) return false;
    try {
      final r = await Get.find<SchemesService>().recordPayment(sbid, mbid, {
        'amount': due.amount,
      });
      return r.success;
    } catch (e) {
      debugPrint('[RatesController] API call failed: $e');
      return false;
    }
  }

  String fmt(int v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹$v';
  }

  int get goldRate22k => metals[1].rate.value;

  void _seedSchemes() {
    schemes.assignAll([
      Scheme(
        id: 'SCH001',
        name: 'Gold Savings Plan',
        duration: '11 months',
        durationMonths: 11,
        monthlyAmtNum: 5000,
        status: 'Active',
        store: 'Rajmahal Jewellers - Main',
        startDate: '2025-06-01',
        endDate: '2026-05-01',
        bonusMonth: 'Yes (12th month free)',
        description: 'Pay ₹5,000/month for 11 months, get 12th month free.',
        memberList: [
          SchemeMember(
            id: 'SM001',
            name: 'Priya Sharma',
            phone: '+91 98765 43210',
            joinDate: '2025-06-01',
            totalPaid: 45000,
            status: 'Active',
            payments: [
              SchemePayment(month: 'Mar 2026', amount: 5000, status: 'Due'),
              SchemePayment(
                month: 'Apr 2026',
                amount: 5000,
                status: 'Upcoming',
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  void _seedOldGold() {
    oldGoldPurchases.assignAll([
      OldGoldEntry(
        id: 'OG001',
        customer: 'Priya Sharma',
        customerId: 'CUS001',
        weight: 15.20,
        purity: '22K',
        rate: 6150,
        totalNum: 93480,
        date: '2026-03-08',
        type: 'Exchange',
        store: 'Rajmahal Jewellers - Main',
        purityTest: const PurityTest(
          method: 'XRF',
          actualPurity: '21.8K',
          purityPercent: '90.8%',
          testedBy: 'Arjun Kapoor',
        ),
        kycDone: true,
        notes: 'Old bangles exchanged for new necklace',
      ),
      OldGoldEntry(
        id: 'OG002',
        customer: 'Walk-in',
        weight: 8.50,
        purity: '18K',
        rate: 5020,
        totalNum: 42670,
        date: '2026-03-06',
        type: 'Purchase',
        store: 'Rajmahal Jewellers - Mall Road',
        kycDone: false,
        notes: 'Walk-in customer selling old chain',
      ),
    ]);
  }
}
