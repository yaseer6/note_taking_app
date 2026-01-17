import 'package:intl/intl.dart';

String formatDateForCard(DateTime date) {
  return '${date.day} ${DateFormat.MMM().format(date)}';
}
