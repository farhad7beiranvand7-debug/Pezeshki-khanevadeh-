import '../data/health_rules.dart';
import '../models/care_item.dart';
import '../models/person.dart';

class CareEngine {
  static List<CareItem> build(Person person, DateTime now) {
    final result = <CareItem>[];
    final name = '${person.firstName} ${person.lastName}'.trim();
    final start = _startWindow(now);
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 365));
    final ageMonths = _ageInMonths(person.birthDate, now);

    void add(HealthRule rule, DateTime due) {
      if (due.isBefore(start) || due.isAfter(end)) return;
      if (rule.gender != null && rule.gender != person.gender) return;
      if (rule.minAgeMonths != null && ageMonths < rule.minAgeMonths!) return;
      if (rule.maxAgeMonths != null && ageMonths > rule.maxAgeMonths!) return;
      result.add(_item(person, name, rule, due));
    }

    // مراقبت‌های ثابت بر اساس سن و واکسیناسیون.
    for (final rule in [...vaccineRules, ...preventiveRules]) {
      if (rule.pregnancyOnly || rule.condition != null) continue;
      if (rule.monthsAfterBirth != null) {
        add(rule, _addMonths(person.birthDate, rule.monthsAfterBirth!));
      } else if (rule.yearsAfterBirth != null) {
        add(rule, DateTime(person.birthDate.year + rule.yearsAfterBirth!, person.birthDate.month, person.birthDate.day));
      } else if (rule.everyDays != null && _eligible(rule, ageMonths)) {
        add(rule, _nextPeriodic(person.createdAt, rule.everyDays!, now));
      }
    }

    // مراقبت نوزاد در روزهای اول تولد؛ اگر کودک بعداً وارد برنامه شود، در پنجره ۳۰ روزه هم نمایش داده می‌شود.
    if (ageMonths < 2) {
      final newborn3to5 = person.birthDate.add(const Duration(days: 3));
      final rule = const HealthRule(id:'child-3to5', title:'مراقبت نوزاد: ۳ تا ۵ روزگی', kind:'child', source:'بسته خدمات کودک سالم');
      add(rule, newborn3to5);
    }

    // بیماری‌های مزمن و عوامل خطر ثبت‌شده.
    for (final rule in conditionRules) {
      if (rule.condition != null && person.conditions.contains(rule.condition) && rule.everyDays != null) {
        add(rule, _nextPeriodic(person.createdAt, rule.everyDays!, now));
      }
    }

    // مراقبت‌های بارداری: اگر تاریخ شروع بارداری/آخرین قاعدگی ثبت شده باشد، از آن زمان برنامه‌ریزی می‌شود.
    if (person.pregnant && person.pregnancyStartDate != null && person.gender == 'زن') {
      final pregnancyStart = person.pregnancyStartDate!;
      for (var i = 0; i < pregnancyRules.length; i++) {
        final rule = pregnancyRules[i];
        DateTime due;
        if (i < 8) {
          // هشت مراقبت ماما در بازه تقریبی ۴ هفته‌ای؛ زمان دقیق توسط ماما تعیین می‌شود.
          due = pregnancyStart.add(Duration(days: 42 + (i * 28)));
        } else if (i < 11) {
          due = pregnancyStart.add(Duration(days: 70 + ((i - 8) * 84)));
        } else {
          due = pregnancyStart.add(Duration(days: 42 + ((i - 11) * 28)));
        }
        add(rule, due);
      }
      // مراقبت پس از زایمان در روز ۱۰ و ۴۰ به صورت یادآوری مادر.
      final postpartum10 = pregnancyStart.add(const Duration(days: 280 + 10));
      final postpartum40 = pregnancyStart.add(const Duration(days: 280 + 40));
      add(HealthRule(id:'postpartum-10', title:'مراقبت پس از زایمان: حدود روز ۱۰', kind:'postpartum', pregnancyOnly:true, source:'بسته خدمات مادران'), postpartum10);
      add(HealthRule(id:'postpartum-40', title:'مراقبت پس از زایمان: حدود روز ۴۰', kind:'postpartum', pregnancyOnly:true, source:'بسته خدمات مادران'), postpartum40);
    }

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return _dedupe(result);
  }

  static bool _eligible(HealthRule r, int ageMonths) =>
      (r.minAgeMonths == null || ageMonths >= r.minAgeMonths!) &&
      (r.maxAgeMonths == null || ageMonths <= r.maxAgeMonths!);

  static List<CareItem> _dedupe(List<CareItem> items) {
    final seen = <String>{};
    return items.where((x) => seen.add('${x.personId}-${x.title}-${x.dueDate.year}-${x.dueDate.month}-${x.dueDate.day}')).toList();
  }

  static CareItem _item(Person person, String name, HealthRule rule, DateTime due) => CareItem(
    id: '${person.id}-${rule.id}-${due.millisecondsSinceEpoch}',
    personId: person.id,
    personName: name,
    title: rule.title,
    dueDate: due,
    kind: rule.kind,
    source: rule.source,
  );

  static DateTime _nextPeriodic(DateTime anchor, int days, DateTime now) {
    var d = DateTime(anchor.year, anchor.month, anchor.day);
    if (!d.isAfter(now)) {
      final elapsed = now.difference(d).inDays;
      final cycles = (elapsed ~/ days) + 1;
      d = d.add(Duration(days: cycles * days));
    }
    return d;
  }

  static DateTime _startWindow(DateTime now) => DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));

  static int _ageInMonths(DateTime birth, DateTime now) {
    var months = (now.year - birth.year) * 12 + now.month - birth.month;
    if (now.day < birth.day) months--;
    return months.clamp(0, 2000);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final total = date.year * 12 + (date.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final day = date.day.clamp(1, _daysInMonth(year, month));
    return DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
}
