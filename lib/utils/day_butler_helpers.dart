import 'package:flutter/services.dart';
import '../db_day_butler/db_day_butler_entity.dart';
import 'index.dart';
int daysUntilNext(int month, int day) {
  final today = DateTime.now();
  final todayNorm = DateTime(today.year, today.month, today.day);
  var target = DateTime(today.year, month, day);
  if (target.isBefore(todayNorm)) {
    target = DateTime(today.year + 1, month, day);
  }
  return target.difference(todayNorm).inDays;
}
int daysUntilSpecialDate(SpecialDate sd) {
  final date = DateTime.parse(sd.date);
  if (sd.type == 'Custom' && !sd.repeatYearly) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(todayNorm).inDays;
  }
  return daysUntilNext(date.month, date.day);
}
String formatCountdown(int days, String type) {
  if (days == 0) return type == 'Birthday' ? 'Today 🎂' : 'Today 🎉';
  if (days == 1) return 'Tomorrow';
  return 'in $days days';
}
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _fullMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
String formatDateDisplay(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  } catch (_) {
    return dateStr;
  }
}
String formatMonthDay(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    return '${_months[d.month - 1]} ${d.day}';
  } catch (_) {
    return dateStr;
  }
}
String formatDateFull(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    return '${_fullMonths[d.month - 1]} ${d.day}, ${d.year}';
  } catch (_) {
    return dateStr;
  }
}
String weekdayName(DateTime d) => _weekdays[d.weekday - 1];
String fullMonthName(int month) => _fullMonths[month - 1];
int? calcAge(String dateStr) {
  try {
    final birth = DateTime.parse(dateStr);
    if (birth.year < 1900) return null;
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
    return age >= 0 ? age : null;
  } catch (_) {
    return null;
  }
}
String calcZodiac(int month, int day) {
  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Aries';
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ Taurus';
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊ Gemini';
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋ Cancer';
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ Leo';
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ Virgo';
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎ Libra';
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏ Scorpio';
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐ Sagittarius';
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '♑ Capricorn';
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ Aquarius';
  return '♓ Pisces';
}
String calcChineseZodiac(int year) {
  const animals = ['🐀 Rat', '🐂 Ox', '🐯 Tiger', '🐇 Rabbit', '🐉 Dragon', '🐍 Snake', '🐎 Horse', '🐏 Goat', '🐒 Monkey', '🐓 Rooster', '🐕 Dog', '🐖 Pig'];
  return 'Year of ${animals[(year - 1900) % 12].split(' ').last}';
}
const avatarStyleColors = [
  0xFFE4577C, 0xFF5B9BD5, 0xFF2EAD6C, 0xFFF39C12,
  0xFF9B59B6, 0xFFE8A06A, 0xFF1ABC9C, 0xFFE67E22,
];
const _styleAvatarPrefix = 'style:';
int avatarColorFromName(String name) {
  if (name.isEmpty) return avatarStyleColors[0];
  int hash = 0;
  for (final c in name.codeUnits) {
    hash = (hash * 31 + c) & 0x7FFFFFFF;
  }
  return avatarStyleColors[hash % avatarStyleColors.length];
}
bool isStyleAvatarPath(String? path) =>
    path != null && path.startsWith(_styleAvatarPrefix);
String encodeStyleAvatarPath(int color) =>
    '$_styleAvatarPrefix${color.toRadixString(16)}';
int? parseStyleAvatarColor(String? path) {
  if (!isStyleAvatarPath(path)) return null;
  return int.tryParse(path!.substring(_styleAvatarPrefix.length), radix: 16);
}
int resolveAvatarColor(String name, String? avatarPath) {
  return parseStyleAvatarColor(avatarPath) ?? avatarColorFromName(name);
}
bool isAvatarPhotoPath(String? path) =>
    path != null && path.isNotEmpty && !isStyleAvatarPath(path);
String ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1: return '${n}st';
    case 2: return '${n}nd';
    case 3: return '${n}rd';
    default: return '${n}th';
  }
}
String eventTypeIcon(String type) {
  switch (type) {
    case 'Birthday': return '🎂';
    case 'Anniversary': return '💑';
    default: return '⭐';
  }
}
String eventDisplayName(SpecialDate sd) {
  if (sd.type == 'Custom') return sd.customName ?? 'Custom';
  return sd.type;
}
const prepChecklistKeys = ['gift', 'cake', 'flower', 'wish'];
const prepChecklistLabels = {
  'gift': '🎁 Buy Gift',
  'cake': '🎂 Order Cake',
  'flower': '🌹 Send Flowers',
  'wish': '✉️ Write Wish',
};
int prepIncompleteCount(Map<String, bool> map) =>
    prepChecklistKeys.where((k) => map[k] != true).length;
bool isPrepComplete(Map<String, bool> map) => prepIncompleteCount(map) == 0;
List<WishTemplate> rankBirthdayWishes(
  List<WishTemplate> wishes, {
  String? relationship,
  int? age,
}) {
  int score(WishTemplate w) {
    final c = w.content.toLowerCase();
    var s = 0;
    switch (relationship) {
      case 'Partner':
        if (c.contains('love') || c.contains('heart') || c.contains('loved')) s += 3;
        if (c.contains('amazing') || c.contains('wonderful')) s += 1;
        break;
      case 'Colleague':
        if (c.contains('best') || c.contains('wonderful') || c.contains('amazing')) s += 2;
        if (c.contains('loved') || c.contains('heart') || c.contains('friend')) s -= 1;
        break;
      case 'Friend':
        if (c.contains('friend') || c.contains('celebrate') || c.contains('joy')) s += 2;
        break;
      case 'Family':
        if (c.contains('loved') || c.contains('appreciated') || c.contains('heart')) s += 2;
        break;
    }
    if (age != null && age < 18) {
      if (c.contains('cheers') || c.contains('🥂') || c.contains('wine') || c.contains('drink')) {
        s -= 10;
      }
    }
    return s;
  }
  final sorted = List<WishTemplate>.from(wishes)
    ..sort((a, b) => score(b).compareTo(score(a)));
  return sorted;
}
String wishedTodayKey(int personId) {
  final d = DateTime.now();
  final stamp =
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  return 'wished_${personId}_$stamp';
}
String formatWishPreview({
  required String category,
  required String personName,
  required String content,
}) {
  switch (category) {
    case 'Birthday':
      return '🎂 Happy Birthday, $personName! $content';
    case 'Anniversary':
      return '🎉 Happy Anniversary, $personName! $content';
    case "Valentine's":
      return '💝 Happy Valentine\'s Day, $personName! $content';
    case 'Christmas':
      return '🎄 Merry Christmas, $personName! $content';
    default:
      return '🎉 $personName! $content';
  }
}
void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
  successToast('Copied!');
}
