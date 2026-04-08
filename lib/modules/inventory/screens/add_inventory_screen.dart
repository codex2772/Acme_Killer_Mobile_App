import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/store_controller.dart';
import '../../../models/inventory_model.dart';
import '../controllers/inventory_controller.dart';
import '../../rates_schemes/controllers/rates_schemes_controller.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});
  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _ctrl = Get.find<InventoryController>();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _netWeight = TextEditingController();
  final _grossWeight = TextEditingController();
  final _stoneWeight = TextEditingController(text: '0');
  final _costPrice = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _makingCharge = TextEditingController(text: '12');
  final _quantity = TextEditingController(text: '1'); // NEW
  final _huid = TextEditingController();
  final _barcode = TextEditingController();
  final _hallmarkCert = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _stoneCarat = TextEditingController();
  final _stoneColor = TextEditingController();
  final _stoneCharges = TextEditingController(
    text: '0',
  ); // mirrors Electron inv-stonecharges

  String _category = 'Necklace';
  String _metal = 'Gold';
  String _purity = '22K';
  String _stoneType = '';
  String _stoneCut = '';
  String _stoneClarity = '';
  String _stoneCert = '';
  DateTime? _hallmarkDate;
  bool _stoneExpanded = false; // collapsible stone section
  bool _isSubmitting = false;

  // Image state — mirrors Electron inv-image-zone
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _imageMimeType;
  String? _uploadedImageUrl; // set after successful S3 upload
  // mirrors Electron: store selector for All Stores mode
  String? _selectedStoreName;
  int? _selectedStoreId;

  // Live price preview state — mirrors Electron inv-price-preview
  double _livePriceEstimate = 0;
  double _liveRate = 0;
  double _liveMetalValue = 0;
  double _liveMakingValue = 0;

  static const _categories = [
    'Necklace',
    'Ring',
    'Earring',
    'Bracelet',
    'Anklet',
    'Bangle',
    'Chain',
    'Pendant',
    'Set',
    'Mangalsutra',
    'Nose Ring',
    'Toe Ring',
    'Other',
  ];
  static const _metals = [
    'Gold',
    'Silver',
    'Platinum',
    'Diamond',
    'Rose Gold',
    'White Gold',
    'Other',
  ];
  static const _purities = [
    '24K',
    '22K',
    '18K',
    '14K',
    '925 Silver',
    '950 Platinum',
  ];
  static const _stoneTypes = [
    '',
    'Diamond',
    'Ruby',
    'Emerald',
    'Sapphire',
    'Kundan/Polki',
    'Pearl',
    'Other',
  ];
  static const _stoneCuts = [
    '',
    'Brilliant Round',
    'Princess',
    'Oval',
    'Cushion',
    'Pear',
    'Marquise',
    'Cabochon',
    'Uncut',
  ];
  static const _clarities = [
    '',
    'FL',
    'IF',
    'VVS1',
    'VVS2',
    'VS1',
    'VS2',
    'SI',
    'Eye Clean',
  ];
  static const _certs = ['None', 'GIA', 'IGI', 'AGS', 'HRD', 'Other'];

  // mirrors Electron: getRateForPurity(metal, purity)
  // reads from RatesSchemesController — the same live /api/rates data
  double _getRateForPurity(String metal, String purity) {
    try {
      final rates = Get.find<RatesSchemesController>();
      int liveRate = 0;
      if (metal == 'Gold' || metal == 'Rose Gold' || metal == 'White Gold') {
        switch (purity) {
          case '24K':
            liveRate = rates.metals[0].rate.value;
            break;
          case '22K':
            liveRate = rates.metals[1].rate.value;
            break;
          case '18K':
            liveRate = rates.metals[2].rate.value;
            break;
          case '14K':
            liveRate = rates.metals[3].rate.value;
            break;
          default:
            liveRate = rates.metals[1].rate.value;
        }
      } else if (metal == 'Silver') {
        liveRate = rates.metals[4].rate.value;
      } else if (metal == 'Platinum') {
        liveRate = rates.metals[5].rate.value;
      }

      if (liveRate > 0) return liveRate.toDouble(); // ← live rate available

      // Rate is 0 — API hasn't responded yet, trigger load in background
      debugPrint(
        '[AddInventory] Rate=0 for $purity, triggering refreshRates...',
      );
      rates.refreshRates();
    } catch (e) {
      debugPrint('[AddInventory] RatesSchemesController not found: $e');
    }
    // Return 0 — price preview stays hidden until live rate arrives
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    // Default store from current context
    try {
      final store = Get.find<StoreController>();
      _selectedStoreName = store.selectedStoreName;
      _selectedStoreId = store.selectedStore.value?.id;
    } catch (_) {}

    // When live rates arrive (from API), recalculate price preview automatically
    // This handles the case where AddInventory opened before rates loaded
    try {
      final rates = Get.find<RatesSchemesController>();
      ever(rates.metals[1].rate, (_) {
        if (mounted) _updateLivePrice();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _netWeight,
      _grossWeight,
      _stoneWeight,
      _costPrice,
      _sellingPrice,
      _makingCharge,
      _quantity,
      _huid,
      _barcode,
      _hallmarkCert,
      _location,
      _description,
      _stoneCarat,
      _stoneColor,
      _stoneCharges,
    ])
      c.dispose();
    super.dispose();
  }

  // mirrors Electron updatePricePreview():
  //   metalValue = netWt × rate
  //   makingValue = metalValue × making%
  //   total = metalValue + makingValue + stoneCharges
  void _updateLivePrice() {
    final nw = double.tryParse(_netWeight.text) ?? 0;
    final making = double.tryParse(_makingCharge.text) ?? 12;
    final stoneCh = double.tryParse(_stoneCharges.text) ?? 0;
    final rate = _getRateForPurity(_metal, _purity); // ← LIVE rate
    final metal = nw * rate;
    final makingV = metal * making / 100;
    final total = metal + makingV + stoneCh;
    setState(() {
      _livePriceEstimate = total;
      _liveRate = rate;
      _liveMetalValue = metal;
      _liveMakingValue = makingV;
      // Auto-fill selling price if blank
      if (_sellingPrice.text.isEmpty || _sellingPrice.text == '0') {
        _sellingPrice.text = total.round().toString();
      }
    });
  }

  // mirrors Electron: imageZone click → file picker → showImagePreview()
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final mimeType = picked.name.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      // mirrors Electron: file.size > 5MB check
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        Get.snackbar(
          'Image too large',
          'Please select an image under 5MB',
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _imageFileName = picked.name;
        _imageMimeType = mimeType;
        _uploadedImageUrl = null; // reset until uploaded
      });
    } catch (e) {
      debugPrint('[AddInventory] Image pick failed: $e');
    }
  }

  void _removeImage() => setState(() {
    _imageBytes = null;
    _imageFileName = null;
    _imageMimeType = null;
    _uploadedImageUrl = null;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final newId =
        'INV${(_ctrl.inventory.length + 1).toString().padLeft(3, '0')}';
    final storeNm = _selectedStoreName ?? 'Rajmahal Jewellers - Main';
    final item = InventoryItem(
      id: newId,
      name: _name.text.trim(),
      category: _category,
      metal: _metal,
      purity: _purity,
      netWeight: double.tryParse(_netWeight.text) ?? 0,
      grossWeight: double.tryParse(_grossWeight.text) ?? 0,
      stoneWeight: double.tryParse(_stoneWeight.text) ?? 0,
      makingCharge: double.tryParse(_makingCharge.text) ?? 12,
      huid: _huid.text.trim(),
      barcode: _barcode.text.trim().isEmpty
          ? 'JE-$newId'
          : _barcode.text.trim(),
      status: 'In Stock',
      store: storeNm,
      costPrice: int.tryParse(_costPrice.text) ?? 0,
      sellingPrice: int.tryParse(_sellingPrice.text) ?? 0,
      showcaseLocation: _location.text.trim(),
      hallmarkCert: _hallmarkCert.text.trim(),
      hallmarkDate: _hallmarkDate,
      dateAdded: DateTime.now(),
      description: _description.text.trim(),
      quantity: int.tryParse(_quantity.text) ?? 1,
      stoneDetails: _stoneType.isEmpty
          ? null
          : {
              'type': _stoneType,
              'carat': _stoneCarat.text,
              'cut': _stoneCut,
              'clarity': _stoneClarity,
              'color': _stoneColor.text,
              'certification': _stoneCert,
            },
    );

    // ── Try API save — mirrors Electron renderAddInventory form submit ──
    bool savedToBackend = false;
    final auth = Get.find<AuthController>();
    if (!auth.isDemo.value) {
      try {
        // Fetch category + metalType IDs from lookups
        final cats = await _ctrl.fetchCategories();
        final metals = await _ctrl.fetchMetalTypes();

        int catId = 1;
        int metalId = 1;

        final catMatch = cats.firstWhere(
          (c) => (c['name']?.toString() ?? '').toLowerCase().contains(
            _category.toLowerCase(),
          ),
          orElse: () => cats.isNotEmpty ? cats.first : {},
        );
        if (catMatch['id'] != null) catId = catMatch['id'] as int;

        final metalMatch = metals.firstWhere(
          (m) => (m['name']?.toString() ?? '').toLowerCase().contains(
            _metal.toLowerCase(),
          ),
          orElse: () => metals.isNotEmpty ? metals.first : {},
        );
        if (metalMatch['id'] != null) metalId = metalMatch['id'] as int;

        // ── Upload image first — mirrors Electron: upload then save item ──
        if (_imageBytes != null && _imageFileName != null) {
          final url = await _ctrl.uploadImage(
            _imageBytes!,
            _imageFileName!,
            _imageMimeType ?? 'image/jpeg',
          );
          if (url != null) {
            _uploadedImageUrl = url;
            debugPrint('[AddInventory] Image uploaded: $url');
          } else {
            debugPrint(
              '[AddInventory] Image upload failed, saving without image',
            );
          }
        }

        final result = await _ctrl.createItem(
          name: item.name,
          description: item.description,
          categoryId: catId,
          metalTypeId: metalId,
          netWeight: item.netWeight,
          grossWeight: item.grossWeight,
          makingCharges: item.makingCharge,
          stoneCharges: double.tryParse(_stoneCharges.text) ?? 0,
          quantity: item.safeQty,
          hsnCode: '7113',
          barcode: item.barcode,
          imageUrl: _uploadedImageUrl, // ← S3 URL or null
          targetStoreId: _selectedStoreId,
        );
        savedToBackend = result['success'] == true;
      } catch (_) {}
    }

    // ── Always add to local state too ──
    _ctrl.addItem(item);
    setState(() => _isSubmitting = false);
    Get.back();
    Get.snackbar(
      'Item Added',
      savedToBackend
          ? '"${item.name}" saved to database!'
          : '"${item.name}" added locally!',
      backgroundColor: AppColors.bgCard,
      colorText: savedToBackend ? AppColors.success : AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Jewelry Item',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Store selector — mirrors Electron All Stores mode ──
            Builder(
              builder: (_) {
                try {
                  final storeCtrl = Get.find<StoreController>();
                  final isAllStores =
                      storeCtrl.selectedStore.value == null &&
                      storeCtrl.stores.length > 1;
                  if (!isAllStores) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _section('Store Assignment', Icons.store_outlined),
                      _dropdown(
                        'Assign to Store *',
                        storeCtrl.stores.map((s) => s.name).toList(),
                        _selectedStoreName ?? storeCtrl.stores.first.name,
                        (v) => setState(() {
                          _selectedStoreName = v;
                          _selectedStoreId = storeCtrl.stores
                              .firstWhere((s) => s.name == v)
                              .id;
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              },
            ),

            _section('Item Information', Icons.inventory_2_outlined),
            _field(_name, 'Item Name *', validator: _req),
            _row2(
              _dropdown(
                'Category',
                _categories,
                _category,
                (v) => setState(() => _category = v!),
              ),
              _dropdown(
                'Metal Type',
                _metals,
                _metal,
                (v) => setState(() {
                  _metal = v!;
                  _updateLivePrice();
                }),
              ),
            ),
            _dropdown(
              'Purity',
              _purities,
              _purity,
              (v) => setState(() {
                _purity = v!;
                _updateLivePrice();
              }),
            ),

            const SizedBox(height: 8),
            _section('Weight & Quantity', Icons.scale_outlined),
            _row3(
              _numField(
                _netWeight,
                'Net Weight (g) *',
                validator: _req,
                onChanged: (_) => _updateLivePrice(),
              ),
              _numField(_grossWeight, 'Gross Weight (g) *', validator: _req),
              _numField(_stoneWeight, 'Stone Weight (g)'),
            ),
            // ── Quantity field — mirrors Electron: default 1 ──
            _numField(_quantity, 'Quantity *', validator: _req),

            const SizedBox(height: 8),
            _section('Pricing', Icons.currency_rupee),
            // ── Live price preview — mirrors Electron inv-price-preview ──
            if (_livePriceEstimate > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Row: Rate/g | Metal Value | Making
                    Row(
                      children: [
                        _priceCell(
                          'Rate/g ($_purity)',
                          '₹${_liveRate.round()}',
                        ),
                        _priceCell(
                          'Metal Value',
                          '₹${_liveMetalValue.round()}\n${_netWeight.text}g × ₹${_liveRate.round()}',
                        ),
                        _priceCell(
                          'Making (${_makingCharge.text}%)',
                          '₹${_liveMakingValue.round()}',
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Selling Price',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${_livePriceEstimate.round()}',
                          style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            _row3(
              _numField(_costPrice, 'Cost Price (₹) *', validator: _req),
              _numField(_sellingPrice, 'Selling Price (₹) *', validator: _req),
              _numField(
                _makingCharge,
                'Making %',
                onChanged: (_) => _updateLivePrice(),
              ),
            ),
            // Stone charges — mirrors Electron inv-stonecharges field
            _numField(
              _stoneCharges,
              'Stone Charges (₹)',
              onChanged: (_) => _updateLivePrice(),
            ),

            const SizedBox(height: 8),
            _section('Identification', Icons.tag_outlined),
            _row3(
              _field(_huid, 'HUID *', validator: _req),
              _field(_barcode, 'Barcode'),
              _field(_hallmarkCert, 'Hallmark Cert'),
            ),
            _row2(_field(_location, 'Showcase Location'), _datePicker()),

            const SizedBox(height: 8),
            // ── Collapsible stone section — mirrors Electron stone-toggle ──
            GestureDetector(
              onTap: () => setState(() => _stoneExpanded = !_stoneExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.diamond_outlined,
                      color: AppColors.goldPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Stone Details (Optional)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _stoneExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  _row3(
                    _dropdown(
                      'Stone Type',
                      _stoneTypes,
                      _stoneType,
                      (v) => setState(() => _stoneType = v!),
                    ),
                    _numField(_stoneCarat, 'Carat'),
                    _dropdown(
                      'Cut',
                      _stoneCuts,
                      _stoneCut,
                      (v) => setState(() => _stoneCut = v!),
                    ),
                  ),
                  _row3(
                    _dropdown(
                      'Clarity',
                      _clarities,
                      _stoneClarity,
                      (v) => setState(() => _stoneClarity = v!),
                    ),
                    _field(_stoneColor, 'Color (e.g. D, E-F)'),
                    _dropdown(
                      'Certification',
                      _certs,
                      _stoneCert.isEmpty ? 'None' : _stoneCert,
                      (v) => setState(() => _stoneCert = v == 'None' ? '' : v!),
                    ),
                  ),
                ],
              ),
              crossFadeState: _stoneExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            const SizedBox(height: 8),
            _section('Item Photo', Icons.photo_camera_outlined),
            // ── Image zone — mirrors Electron inv-image-zone ──
            _imageBytes == null
                ? GestureDetector(
                    onTap: () => _showImageSourceSheet(),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.textMuted,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Camera or Gallery • Max 5MB',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _showImageSourceSheet(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 8),
            _section('Notes', Icons.notes_outlined),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextFormField(
                controller: _description,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Any additional notes...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.black,
                          ),
                    label: Text(
                      _isSubmitting ? 'Saving...' : 'Save Item',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      disabledBackgroundColor: AppColors.goldPrimary
                          .withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Bottom sheet: Camera or Gallery — standard mobile pattern
  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Photo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _sourceBtn(Icons.camera_alt_outlined, 'Camera', () {
                    Get.back();
                    _pickImage(ImageSource.camera);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sourceBtn(
                    Icons.photo_library_outlined,
                    'Gallery',
                    () {
                      Get.back();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.goldPrimary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Price breakdown cell — mirrors Electron price preview grid ──
  Widget _priceCell(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  // ─── Helpers ───
  Widget _section(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: AppColors.goldPrimary, size: 15),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  Widget _inputDeco(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
      const SizedBox(height: 10),
    ],
  );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? Function(String?)? validator,
  }) => _inputDeco(
    label,
    TextFormField(
      controller: ctrl,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );

  Widget _numField(
    TextEditingController ctrl,
    String label, {
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) => _inputDeco(
    label,
    TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );

  Widget _dropdown(
    String label,
    List<String> items,
    String val,
    ValueChanged<String?> onChanged,
  ) => _inputDeco(
    label,
    DropdownButtonFormField<String>(
      value: val,
      dropdownColor: AppColors.bgSecondary,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: items
          .map(
            (i) => DropdownMenuItem(
              value: i,
              child: Text(
                i,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _datePicker() => _inputDeco(
    'Hallmark Date',
    GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (c, w) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.goldPrimary,
              ),
            ),
            child: w!,
          ),
        );
        if (d != null) setState(() => _hallmarkDate = d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textMuted,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _hallmarkDate == null
                  ? 'Select date'
                  : '${_hallmarkDate!.day}/${_hallmarkDate!.month}/${_hallmarkDate!.year}',
              style: TextStyle(
                color: _hallmarkDate == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _row2(Widget a, Widget b) => Row(
    children: [
      Expanded(
        child: Padding(padding: const EdgeInsets.only(right: 6), child: a),
      ),
      Expanded(
        child: Padding(padding: const EdgeInsets.only(left: 6), child: b),
      ),
    ],
  );

  Widget _row3(Widget a, Widget b, Widget c) => Row(
    children: [
      Expanded(
        child: Padding(padding: const EdgeInsets.only(right: 4), child: a),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: b,
        ),
      ),
      Expanded(
        child: Padding(padding: const EdgeInsets.only(left: 4), child: c),
      ),
    ],
  );

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
