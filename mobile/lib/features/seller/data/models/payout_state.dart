
enum PayoutState {
  paid('Versé'),
  pending('En attente'),
  refunded('Remboursé');

  const PayoutState(this.label);

  final String label;

  static PayoutState fromPaymentStatus(Object? v) {
    if (v == 'RELEASED') return PayoutState.paid;
    if (v == 'REFUNDED') return PayoutState.refunded;
    return PayoutState.pending;
  }
}
