const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatQty(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString().replaceAll('.', ',');
