class InvoiceNumberGenerator {
  InvoiceNumberGenerator._();

  static String generate({
    required String businessName,
    required DateTime date,
    required int sequence,
  }) {
    final initial = _getInitials(businessName);
    final month = _formatMonth(date);
    final seq = sequence.toString().padLeft(4, '0');
    return 'INV/$initial/$month/$seq';
  }

  static String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    final word = words.first;
    if (word.length >= 2) {
      return word.substring(0, 2).toUpperCase();
    }
    return word.toUpperCase();
  }

  static String _formatMonth(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    return '$year$month';
  }
}
