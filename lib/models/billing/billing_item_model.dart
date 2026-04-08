// mirrors Electron: makingInput.dataset.makingType = 'FLAT' | 'PERCENTAGE'
enum MakingType { flat, percentage }

class BillingItem {
  String name;
  String inventoryId; // local SKU string e.g. 'INV42'
  int? backendId; // actual DB integer id — used for API payload
  double weight;
  double rate;
  double making;
  MakingType makingType; // FLAT = flat ₹, PERCENTAGE = % of metalValue
  String purity;
  int stoneCharges;
  int otherCharges;

  BillingItem({
    this.name = '',
    this.inventoryId = '',
    this.backendId,
    this.weight = 0,
    this.rate = 0,
    this.making = 12,
    this.makingType = MakingType.percentage, // default: user enters %
    this.purity = '22K',
    this.stoneCharges = 0,
    this.otherCharges = 0,
  });

  int get metalValue => (weight * rate).round();

  // mirrors Electron recalcInvoice():
  //   FLAT       → makingValue = making          (flat ₹ from inventory)
  //   PERCENTAGE → makingValue = metalValue * making / 100  (user entered %)
  int get makingValue => makingType == MakingType.flat
      ? making.round()
      : (metalValue * making / 100).round();

  int get total => metalValue + makingValue + stoneCharges + otherCharges;

  // Display label for the Making field
  String get makingLabel => makingType == MakingType.flat
      ? '₹${making.round()}'
      : '${making.toStringAsFixed(1)}%';

  factory BillingItem.fromJson(Map<String, dynamic> j) => BillingItem(
    name: j['name']?.toString() ?? '',
    inventoryId: j['jewelryItemId']?.toString() ?? '',
    weight: (j['weight'] ?? 0).toDouble(),
    rate: (j['rate'] ?? 0).toDouble(),
    // Backend sends flat ₹ in makingCharges
    making: (j['makingCharge'] ?? j['makingCharges'] ?? 0).toDouble(),
    makingType: MakingType.flat,
    purity: j['purity']?.toString() ?? '22K',
  );
}
