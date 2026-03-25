import 'package:get/get.dart';
import '../../../services/enquiries_service.dart';

// ════════════════════════════════════════════════════════════════════
// EnquiriesController — mirrors Electron enquiries.js
// ════════════════════════════════════════════════════════════════════
class EnquiriesController extends GetxController {
  final EnquiriesService _svc = Get.find<EnquiriesService>();

  final RxList<Enquiry>  enquiries    = <Enquiry>[].obs;
  final RxBool           isLoading    = false.obs;
  final RxString         searchQuery  = ''.obs;
  final RxString         activeFilter = 'all'.obs; // all | open | responded | closed
  final Rx<Enquiry?>     selected     = Rx<Enquiry?>(null);

  @override
  void onInit() {
    super.onInit();
    _seedDemo();
    fetchFromApi();
  }

  // ── API LOAD — mirrors Electron: enquiries:list → GET /api/enquiries ──
  Future<void> fetchFromApi() async {
    isLoading.value = true;
    try {
      final result = await _svc.list();
      if (result.success && result.data is List) {
        final list = (result.data as List)
            .map((e) => Enquiry.fromBackend(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) enquiries.assignAll(list);
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> refresh() => fetchFromApi();

  // ── RESPOND — mirrors Electron: enquiries:respond → PUT /api/enquiries/:id/respond ──
  Future<bool> respond(dynamic id, String responseText) async {
    try {
      final result = await _svc.respond(id, {
        'adminResponse': responseText,
        'status': 'RESPONDED',
      });
      if (result.success) {
        _updateLocalStatus(id, 'Responded', adminResponse: responseText);
        return true;
      }
      return false;
    } catch (_) { return false; }
  }

  // ── CLOSE — mirrors Electron: enquiries:close → PATCH /api/enquiries/:id/close ──
  Future<bool> close(dynamic id) async {
    try {
      final result = await _svc.close(id);
      if (result.success) {
        _updateLocalStatus(id, 'Closed');
        return true;
      }
      return false;
    } catch (_) { return false; }
  }

  void _updateLocalStatus(dynamic id, String newStatus, {String? adminResponse}) {
    final idx = enquiries.indexWhere((e) => e.id.toString() == id.toString());
    if (idx == -1) return;
    final old = enquiries[idx];
    enquiries[idx] = Enquiry(
      id: old.id, customer: old.customer, customerId: old.customerId,
      phone: old.phone, email: old.email,
      jewelryItemId: old.jewelryItemId, jewelryItemName: old.jewelryItemName,
      jewelryItemSku: old.jewelryItemSku,
      subject: old.subject, message: old.message, imageUrl: old.imageUrl,
      status: newStatus,
      statusRaw: newStatus.toUpperCase(),
      adminResponse: adminResponse ?? old.adminResponse,
      respondedBy: adminResponse != null ? 'Admin' : old.respondedBy,
      respondedAt: adminResponse != null ? DateTime.now().toIso8601String() : old.respondedAt,
      store: old.store, date: old.date, time: old.time,
      createdAt: old.createdAt, updatedAt: DateTime.now().toIso8601String(),
    );
    enquiries.refresh();
  }

  // ── Filtered list — mirrors Electron filter logic ────────────────
  List<Enquiry> get filteredEnquiries {
    var list = enquiries.toList();

    final f = activeFilter.value;
    if (f == 'open')       list = list.where((e) => e.isOpen).toList();
    else if (f == 'responded') list = list.where((e) => e.isResponded).toList();
    else if (f == 'closed')    list = list.where((e) => e.isClosed).toList();

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((e) =>
          e.customer.toLowerCase().contains(q) ||
          e.subject.toLowerCase().contains(q) ||
          e.message.toLowerCase().contains(q) ||
          e.phone.contains(q) ||
          (e.jewelryItemName ?? '').toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // ── Stats ─────────────────────────────────────────────────────────
  int get openCount       => enquiries.where((e) => e.isOpen).length;
  int get respondedCount  => enquiries.where((e) => e.isResponded).length;
  int get closedCount     => enquiries.where((e) => e.isClosed).length;
  int get totalCount      => enquiries.length;

  // ── Demo seed data — shown while API loads ────────────────────────
  void _seedDemo() {
    enquiries.assignAll([
      Enquiry(
        id: 1, customer: 'Priya Sharma', customerId: 'CUS001',
        phone: '+91 98765 43210', email: 'priya@example.com',
        jewelryItemId: 'INV001', jewelryItemName: '22K Gold Necklace',
        jewelryItemSku: 'JE-NK-001',
        subject: 'Price inquiry for gold necklace',
        message: 'Hello, I am interested in the 22K Gold Necklace. Can you please share the current price and any ongoing offers?',
        imageUrl: null,
        status: 'Open', statusRaw: 'OPEN',
        adminResponse: null, respondedBy: null, respondedAt: null,
        store: 'Rajmahal Jewellers - Main',
        date: '2026-03-12', time: '10:30',
        createdAt: '2026-03-12T10:30:00', updatedAt: '2026-03-12T10:30:00',
      ),
      Enquiry(
        id: 2, customer: 'Rahul Mehta', customerId: 'CUS002',
        phone: '+91 87654 32109', email: 'rahul@example.com',
        jewelryItemId: 'INV003', jewelryItemName: 'Platinum Wedding Band',
        jewelryItemSku: 'JE-RG-001',
        subject: 'Customisation request for wedding band',
        message: 'I would like to know if customisation is possible for the platinum band. Specifically, can we engrave names?',
        imageUrl: null,
        status: 'Responded', statusRaw: 'RESPONDED',
        adminResponse: 'Yes, we offer engraving services at ₹500 extra. Please visit the store or call us to discuss.',
        respondedBy: 'Arjun Kapoor',
        respondedAt: '2026-03-11T15:45:00',
        store: 'Rajmahal Jewellers - Mall Road',
        date: '2026-03-11', time: '14:20',
        createdAt: '2026-03-11T14:20:00', updatedAt: '2026-03-11T15:45:00',
      ),
      Enquiry(
        id: 3, customer: 'Anita Desai', customerId: 'CUS003',
        phone: '+91 76543 21098', email: null,
        jewelryItemId: 'INV004', jewelryItemName: 'Kundan Bridal Set',
        jewelryItemSku: 'JE-ST-001',
        subject: 'Bridal set availability check',
        message: 'Is the kundan bridal set still available? I need it for a wedding in April.',
        imageUrl: null,
        status: 'Open', statusRaw: 'OPEN',
        adminResponse: null, respondedBy: null, respondedAt: null,
        store: 'Rajmahal Jewellers - Main',
        date: '2026-03-10', time: '09:15',
        createdAt: '2026-03-10T09:15:00', updatedAt: '2026-03-10T09:15:00',
      ),
      Enquiry(
        id: 4, customer: 'Vikram Singh', customerId: 'CUS004',
        phone: '+91 65432 10987', email: 'vikram@example.com',
        jewelryItemId: null, jewelryItemName: null, jewelryItemSku: null,
        subject: 'Old gold exchange rates',
        message: 'What is the current exchange rate for 22K old gold? I have about 30 grams to exchange.',
        imageUrl: null,
        status: 'Closed', statusRaw: 'CLOSED',
        adminResponse: 'Current rate for 22K is ₹6,150/gram. Please bring original bill and ID proof.',
        respondedBy: 'Sneha Reddy',
        respondedAt: '2026-03-09T11:00:00',
        store: 'Rajmahal Jewellers - City Center',
        date: '2026-03-09', time: '08:45',
        createdAt: '2026-03-09T08:45:00', updatedAt: '2026-03-09T11:00:00',
      ),
    ]);
  }
}
