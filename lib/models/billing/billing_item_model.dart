class BillingItem {
  String name;
  String inventoryId; // local SKU string e.g. 'INV42'
  int? backendId; // actual DB integer id — used for API payload
  double weight;
  double rate;
  double making;
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
    this.purity = '22K',
    this.stoneCharges = 0,
    this.otherCharges = 0,
  });

  int get metalValue => (weight * rate).round();
  int get makingValue => (metalValue * making / 100).round();
  int get total => metalValue + makingValue + stoneCharges + otherCharges;

  factory BillingItem.fromJson(Map<String, dynamic> j) => BillingItem(
    name: j['name']?.toString() ?? '',
    inventoryId: j['jewelryItemId']?.toString() ?? '',
    weight: (j['weight'] ?? 0).toDouble(),
    rate: (j['rate'] ?? 0).toDouble(),
    making: (j['makingCharge'] ?? 12).toDouble(),
    purity: j['purity']?.toString() ?? '22K',
  );
}
