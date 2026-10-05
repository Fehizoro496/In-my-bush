
enum SalesPeriod {
  week('7 j'),
  month('30 j'),
  halfYear('6 mois'),
  year('12 mois');

  const SalesPeriod(this.label);

  final String label;
}
