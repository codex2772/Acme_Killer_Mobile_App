class PaymentSplit {
  final String mode;
  final int amount;
  final String? reference;

  const PaymentSplit({required this.mode, required this.amount, this.reference});
}
