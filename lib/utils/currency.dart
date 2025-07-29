import 'dart:math';

String formatCurrency(String value, int decimals) {
  try {
    final doubleBalance = double.tryParse(value) ?? 0.0;

    final formattedBalance = doubleBalance / pow(10, decimals);

    return formattedBalance.toStringAsFixed(2);
  } catch (e) {
    return '0.00';
  }
}
