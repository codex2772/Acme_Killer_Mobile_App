class BillingItem {
  String name = "";

  double weight = 0;
  double rate = 0;
  double making = 0;

  int get total {
    final metal = weight * rate;
    final makingCharge = metal * making / 100;
    return (metal + makingCharge).round();
  }
}
