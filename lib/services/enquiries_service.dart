import 'package:get/get.dart';
import 'api_client.dart';

// ════════════════════════════════════════════════════════════════════
// EnquiriesService — mirrors Electron ipc-handlers.js enquiries:*
// NEW in latest Electron build — Customer enquiries from Flutter app
//
//   enquiries:list    → GET   /api/enquiries
//   enquiries:get     → GET   /api/enquiries/:id
//   enquiries:respond → PUT   /api/enquiries/:id/respond
//   enquiries:close   → PATCH /api/enquiries/:id/close
//
// Backend statuses: OPEN | RESPONDED | CLOSED
// ════════════════════════════════════════════════════════════════════
class EnquiriesService extends GetxService {
  ApiClient get _api => Get.find<ApiClient>();

  Future<ApiResult<dynamic>> list()                                => _api.request('GET',   '/api/enquiries');
  Future<ApiResult<dynamic>> get(dynamic id)                       => _api.request('GET',   '/api/enquiries/$id');
  Future<ApiResult<dynamic>> respond(dynamic id, Map<String, dynamic> data) =>
      _api.request('PUT',   '/api/enquiries/$id/respond', body: data);
  Future<ApiResult<dynamic>> close(dynamic id)                     => _api.request('PATCH', '/api/enquiries/$id/close');
}

// ════════════════════════════════════════════════════════════════════
// Enquiry model — mirrors Electron mapBackendEnquiry()
// ════════════════════════════════════════════════════════════════════
class Enquiry {
  final dynamic id;
  final String  customer;
  final dynamic customerId;
  final String  phone;
  final String? email;
  final dynamic jewelryItemId;
  final String? jewelryItemName;
  final String? jewelryItemSku;
  final String  subject;
  final String  message;
  final String? imageUrl;
  final String  status;     // Open | Responded | Closed
  final String  statusRaw;  // OPEN | RESPONDED | CLOSED
  final String? adminResponse;
  final String? respondedBy;
  final String? respondedAt;
  final String  store;
  final String  date;
  final String  time;
  final String  createdAt;
  final String  updatedAt;

  const Enquiry({
    required this.id,
    required this.customer,
    this.customerId,
    required this.phone,
    this.email,
    this.jewelryItemId,
    this.jewelryItemName,
    this.jewelryItemSku,
    required this.subject,
    required this.message,
    this.imageUrl,
    required this.status,
    required this.statusRaw,
    this.adminResponse,
    this.respondedBy,
    this.respondedAt,
    required this.store,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Parse from backend JSON — mirrors Electron mapBackendEnquiry() ──
  factory Enquiry.fromBackend(Map<String, dynamic> e, {String fallbackStore = ''}) {
    const statusMap = {'OPEN': 'Open', 'RESPONDED': 'Responded', 'CLOSED': 'Closed'};
    final rawStatus = e['status']?.toString() ?? 'OPEN';
    final createdAt = e['createdAt']?.toString() ?? '';

    return Enquiry(
      id:              e['id'],
      customer:        e['customerName']?.toString() ?? 'Customer #${e['customerId'] ?? '?'}',
      customerId:      e['customerId'],
      phone:           e['customerPhone']?.toString() ?? '',
      email:           e['customerEmail']?.toString(),
      jewelryItemId:   e['jewelryItemId'],
      jewelryItemName: e['jewelryItemName']?.toString(),
      jewelryItemSku:  e['jewelryItemSku']?.toString(),
      subject:         e['subject']?.toString() ?? 'Enquiry',
      message:         e['message']?.toString() ?? '',
      imageUrl:        e['imageUrl']?.toString(),
      status:          statusMap[rawStatus] ?? rawStatus,
      statusRaw:       rawStatus,
      adminResponse:   e['adminResponse']?.toString(),
      respondedBy:     e['respondedBy']?.toString(),
      respondedAt:     e['respondedAt']?.toString(),
      store:           e['_storeName']?.toString() ?? fallbackStore,
      date:            createdAt.length >= 10 ? createdAt.substring(0, 10) : '',
      time:            createdAt.length >= 16 ? createdAt.substring(11, 16) : '',
      createdAt:       createdAt,
      updatedAt:       e['updatedAt']?.toString() ?? '',
    );
  }

  bool get isOpen       => status == 'Open';
  bool get isResponded  => status == 'Responded';
  bool get isClosed     => status == 'Closed';
  bool get hasImage     => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasResponse  => adminResponse != null && adminResponse!.isNotEmpty;
  bool get hasLinkedItem => jewelryItemName != null && jewelryItemName!.isNotEmpty;
}
