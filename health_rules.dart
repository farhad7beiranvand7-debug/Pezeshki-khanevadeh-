/// کاتالوگ مراقبت های سطح اول «پزشک خانواده».
///
/// این فایل برای ساخت یادآوری های عمومی است و جایگزین فرم/بوکلت رسمی سامانه سیب
/// یا تصمیم بالینی پزشک نیست. محتوای سنی و گروه های خدمت بر اساس بسته خدمات سطح اول
/// و راهنماهای کشوری در docs/SOURCES.md تنظیم شده و باید با ابلاغ جدید وزارت بهداشت
/// قابل به‌روزرسانی باشد.
class HealthRule {
  final String id;
  final String title;
  final String kind;
  final String source;
  final int? minAgeMonths;
  final int? maxAgeMonths;
  final int? everyDays;
  final int? monthsAfterBirth;
  final int? yearsAfterBirth;
  final String? condition;
  final String? gender;
  final bool pregnancyOnly;

  const HealthRule({
    required this.id,
    required this.title,
    required this.kind,
    required this.source,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.everyDays,
    this.monthsAfterBirth,
    this.yearsAfterBirth,
    this.condition,
    this.gender,
    this.pregnancyOnly = false,
  });
}

const vaccineRules = <HealthRule>[
  HealthRule(id:'v-birth', title:'واکسیناسیون بدو تولد', kind:'vaccine', monthsAfterBirth:0, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-2m', title:'واکسیناسیون ۲ ماهگی: واکسن‌های روتین + روتاویروس + پنوموکوک', kind:'vaccine', monthsAfterBirth:2, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-4m', title:'واکسیناسیون ۴ ماهگی: واکسن‌های روتین + روتاویروس + پنوموکوک', kind:'vaccine', monthsAfterBirth:4, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-6m', title:'واکسیناسیون ۶ ماهگی: واکسن‌های روتین + روتاویروس', kind:'vaccine', monthsAfterBirth:6, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-12m', title:'واکسیناسیون ۱۲ ماهگی: MMR + پنوموکوک', kind:'vaccine', monthsAfterBirth:12, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-18m', title:'واکسیناسیون ۱۸ ماهگی: سه‌گانه + فلج اطفال + MMR', kind:'vaccine', monthsAfterBirth:18, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-5-6y', title:'واکسیناسیون ۵ تا ۶ سالگی: سه‌گانه + فلج اطفال', kind:'vaccine', yearsAfterBirth:6, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-10y', title:'بررسی وضعیت واکسیناسیون نوجوان', kind:'vaccine', yearsAfterBirth:10, source:'بسته خدمات سطح اول + برنامه ایمن سازی کشوری'),
  HealthRule(id:'v-14-16y', title:'یادآور واکسن دوگانه بزرگسالان/نوجوانان و بررسی سابقه واکسیناسیون', kind:'vaccine', yearsAfterBirth:15, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
  HealthRule(id:'v-adult-td', title:'بررسی وضعیت واکسن دوگانه بزرگسالان و یادآورهای لازم', kind:'vaccine', minAgeMonths:19*12, everyDays:3650, source:'برنامه و راهنمای ایمن سازی کشوری ۱۴۰۳'),
];

/// وضعیت‌هایی که در صورت ثبت، مسیر مراقبت مربوطه را فعال می‌کنند.
const conditionOptions = <String>[
  'فشار خون بالا',
  'دیابت',
  'پیش‌دیابت',
  'اختلال چربی خون',
  'آسم',
  'بیماری قلبی-عروقی',
  'بیماری مزمن کلیه',
  'چاقی یا اضافه وزن',
  'سابقه خانوادگی بیماری قلبی زودرس',
  'مصرف دخانیات',
  'اختلال سلامت روان',
];

const conditionRules = <HealthRule>[
  HealthRule(id:'c-htn', title:'پیگیری فشار خون بالا', kind:'condition', condition:'فشار خون بالا', everyDays:30, source:'بسته خدمات سطح اول؛ مراقبت فشارخون بالا'),
  HealthRule(id:'c-dm', title:'پیگیری دیابت', kind:'condition', condition:'دیابت', everyDays:90, source:'بسته خدمات سطح اول؛ مراقبت ادغام‌یافته دیابت'),
  HealthRule(id:'c-prediabetes', title:'پیگیری پیش‌دیابت و اصلاح سبک زندگی', kind:'condition', condition:'پیش‌دیابت', everyDays:90, source:'بسته خدمات سطح اول؛ ایراپن و مراقبت دیابت'),
  HealthRule(id:'c-lipid', title:'پیگیری اختلال چربی خون و خطر قلبی-عروقی', kind:'condition', condition:'اختلال چربی خون', everyDays:180, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'c-asthma', title:'پیگیری و مراقبت آسم', kind:'condition', condition:'آسم', everyDays:90, source:'بسته خدمات سطح اول؛ برنامه کشوری آسم در PHC'),
  HealthRule(id:'c-cvd', title:'پیگیری بیماری قلبی-عروقی', kind:'condition', condition:'بیماری قلبی-عروقی', everyDays:90, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'c-ckd', title:'پیگیری بیماری مزمن کلیه', kind:'condition', condition:'بیماری مزمن کلیه', everyDays:90, source:'بسته خدمات سطح اول؛ مراقبت بیماری‌های مزمن'),
  HealthRule(id:'c-obesity', title:'پیگیری اضافه وزن/چاقی و تغذیه', kind:'condition', condition:'چاقی یا اضافه وزن', everyDays:90, source:'بسته خدمات تغذیه و بسته خدمات سطح اول'),
  HealthRule(id:'c-family-cvd', title:'خطرسنجی قلبی-عروقی به علت سابقه خانوادگی', kind:'condition', condition:'سابقه خانوادگی بیماری قلبی زودرس', everyDays:365, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'c-smoking', title:'مداخله و پیگیری ترک دخانیات', kind:'condition', condition:'مصرف دخانیات', everyDays:30, source:'بسته خدمات سلامت روان، اجتماعی و اعتیاد'),
  HealthRule(id:'c-mental', title:'پیگیری سلامت روان', kind:'condition', condition:'اختلال سلامت روان', everyDays:30, source:'بسته خدمات سلامت روان، اجتماعی و اعتیاد'),
];

const preventiveRules = <HealthRule>[
  // نوزاد و کودک زیر ۸ سال
  HealthRule(id:'newborn-metabolic', title:'غربالگری نوزادان: کم‌کاری تیروئید، PKU و بیماری‌های متابولیک', kind:'screening', monthsAfterBirth:0, source:'بسته خدمات سطح اول؛ غربالگری نوزادان'),
  HealthRule(id:'newborn-hearing', title:'غربالگری شنوایی نوزاد', kind:'screening', monthsAfterBirth:0, source:'بسته خدمات سطح اول؛ غربالگری نوزادان'),
  HealthRule(id:'child-3d', title:'مراقبت نوزاد: ۳ تا ۵ روزگی', kind:'child', minAgeMonths:0, maxAgeMonths:1, everyDays:30, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-1m', title:'مراقبت کودک سالم: حدود ۱ ماهگی', kind:'child', monthsAfterBirth:1, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-2m', title:'مراقبت کودک سالم: ۲ ماهگی', kind:'child', monthsAfterBirth:2, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-4m', title:'مراقبت کودک سالم: ۴ ماهگی', kind:'child', monthsAfterBirth:4, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-6m', title:'مراقبت کودک سالم: ۶ ماهگی', kind:'child', monthsAfterBirth:6, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-9m', title:'مراقبت کودک سالم: ۹ ماهگی', kind:'child', monthsAfterBirth:9, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-12m', title:'مراقبت کودک سالم: ۱۲ ماهگی', kind:'child', monthsAfterBirth:12, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-18m', title:'مراقبت کودک سالم: ۱۸ ماهگی', kind:'child', monthsAfterBirth:18, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-24m', title:'مراقبت کودک سالم: ۲ سالگی', kind:'child', monthsAfterBirth:24, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-3y', title:'مراقبت کودک سالم: ۳ سالگی', kind:'child', yearsAfterBirth:3, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-4y', title:'مراقبت کودک سالم: ۴ سالگی', kind:'child', yearsAfterBirth:4, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-5y', title:'مراقبت کودک سالم: ۵ سالگی', kind:'child', yearsAfterBirth:5, source:'بسته خدمات کودک سالم'),
  HealthRule(id:'child-6y', title:'مراقبت کودک سالم: ۶ سالگی و آمادگی مدرسه', kind:'child', yearsAfterBirth:6, source:'بسته خدمات کودک سالم + سلامت مدارس'),
  HealthRule(id:'child-7y', title:'مراقبت کودک سالم: ۷ سالگی', kind:'child', yearsAfterBirth:7, source:'بسته خدمات کودک سالم'),

  // سلامت مدرسه: پایه‌های اول، چهارم، هفتم و دهم به‌صورت تقریبی بر اساس سن.
  HealthRule(id:'school-1', title:'غربالگری سلامت مدرسه: پایه اول', kind:'school', yearsAfterBirth:7, source:'بسته خدمات سلامت مدارس'),
  HealthRule(id:'school-4', title:'غربالگری سلامت مدرسه: پایه چهارم', kind:'school', yearsAfterBirth:10, source:'بسته خدمات سلامت مدارس'),
  HealthRule(id:'school-7', title:'غربالگری سلامت مدرسه: پایه هفتم', kind:'school', yearsAfterBirth:13, source:'بسته خدمات سلامت مدارس'),
  HealthRule(id:'school-10', title:'غربالگری سلامت مدرسه: پایه دهم', kind:'school', yearsAfterBirth:16, source:'بسته خدمات سلامت مدارس'),

  // جوانان ۱۸ تا ۲۹ سال
  HealthRule(id:'young-annual', title:'مراقبت دوره‌ای جوانان ۱۸ تا ۲۹ سال', kind:'preventive', minAgeMonths:18*12, maxAgeMonths:29*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ گروه سنی ۱۸ تا ۲۹ سال'),
  HealthRule(id:'young-nutrition', title:'ارزیابی تغذیه و BMI جوانان', kind:'nutrition', minAgeMonths:18*12, maxAgeMonths:29*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ تغذیه'),
  HealthRule(id:'young-mental', title:'ارزیابی سلامت روان و مصرف دخانیات/مواد/الکل', kind:'mental', minAgeMonths:18*12, maxAgeMonths:29*12+11, everyDays:365, source:'بسته خدمات سلامت روان، اجتماعی و اعتیاد'),

  // میانسالان ۳۰ تا ۵۹ سال
  HealthRule(id:'adult-risk', title:'خطرسنجی بیماری‌های قلبی و مغزی (ایراپن)', kind:'preventive', minAgeMonths:30*12, maxAgeMonths:59*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'adult-ncd', title:'غربالگری/پیگیری دیابت، فشار خون و اختلال چربی خون', kind:'preventive', minAgeMonths:30*12, maxAgeMonths:59*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'adult-body', title:'اندازه‌گیری قد، وزن، BMI و دور کمر', kind:'preventive', minAgeMonths:30*12, maxAgeMonths:59*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ ایراپن'),
  HealthRule(id:'adult-activity', title:'ارزیابی فعالیت بدنی و آموزش سبک زندگی سالم', kind:'preventive', minAgeMonths:30*12, maxAgeMonths:59*12+11, everyDays:365, source:'بسته خدمات سطح اول'),
  HealthRule(id:'adult-mental', title:'ارزیابی سلامت روان و مصرف دخانیات/مواد/الکل', kind:'mental', minAgeMonths:30*12, maxAgeMonths:59*12+11, everyDays:365, source:'بسته خدمات سطح اول'),
  HealthRule(id:'crc-50', title:'غربالگری سرطان روده بزرگ (۵۰ تا ۷۰ سال)', kind:'screening', minAgeMonths:50*12, maxAgeMonths:70*12+11, everyDays:365, source:'بسته خدمات سطح اول و گزارش معاونت بهداشت ۱۴۰۴'),
  HealthRule(id:'women-breast', title:'غربالگری سرطان پستان برای زنان واجد شرایط', kind:'screening', gender:'زن', minAgeMonths:30*12, maxAgeMonths:70*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ برنامه تشخیص زودهنگام سرطان'),
  HealthRule(id:'women-cervix', title:'غربالگری سرطان دهانه رحم برای زنان واجد شرایط', kind:'screening', gender:'زن', minAgeMonths:30*12, maxAgeMonths:70*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ برنامه تشخیص زودهنگام سرطان'),
  HealthRule(id:'menopause', title:'ارزیابی علائم و عوارض یائسگی در صورت وجود', kind:'women', gender:'زن', minAgeMonths:40*12, maxAgeMonths:70*12+11, everyDays:365, source:'بسته خدمات سلامت میانسالان'),

  // سالمندان
  HealthRule(id:'elderly-annual', title:'مراقبت جامع سالمندان ۶۰ سال و بالاتر', kind:'elderly', minAgeMonths:60*12, everyDays:365, source:'بسته خدمات سطح اول؛ بسته مراقبت‌های ادغام‌یافته سالمندان'),
  HealthRule(id:'elderly-fall', title:'ارزیابی خطر زمین‌خوردن و تعادل', kind:'elderly', minAgeMonths:60*12, everyDays:365, source:'بسته خدمات سطح اول؛ بسته مراقبت سالمندان'),
  HealthRule(id:'elderly-depression', title:'غربالگری افسردگی سالمندان', kind:'elderly', minAgeMonths:60*12, everyDays:365, source:'بسته خدمات سطح اول؛ بسته مراقبت سالمندان'),
  HealthRule(id:'elderly-nutrition', title:'غربالگری و مراقبت تغذیه‌ای سالمندان', kind:'nutrition', minAgeMonths:60*12, everyDays:365, source:'بسته خدمات سطح اول؛ بسته تغذیه و سالمندان'),
  HealthRule(id:'elderly-senses', title:'ارزیابی بینایی، شنوایی و عملکرد روزمره سالمند', kind:'elderly', minAgeMonths:60*12, everyDays:365, source:'بسته مراقبت‌های ادغام‌یافته سالمندان'),

  // خدمات سلامت دهان
  HealthRule(id:'fertility-health', title:'مشاوره باروری سالم و فرزندآوری در زنان واجد شرایط', kind:'women', gender:'زن', minAgeMonths:10*12, maxAgeMonths:54*12+11, everyDays:365, source:'بسته خدمتی ازدواج، باروری سالم و فرزندآوری'),
  HealthRule(id:'preconception', title:'مراقبت پیش از بارداری در صورت تصمیم به بارداری', kind:'pregnancy', gender:'زن', minAgeMonths:10*12, maxAgeMonths:54*12+11, everyDays:365, source:'بسته خدمات سطح اول؛ مراقبت پیش از بارداری'),
  HealthRule(id:'oral-under3', title:'مراقبت سلامت دهان کودک زیر ۳ سال', kind:'oral', maxAgeMonths:35, everyDays:180, source:'بسته خدمات سلامت دهان و دندان'),
  HealthRule(id:'oral-3to6', title:'وارنیش فلوراید کودک ۳ تا ۶ سال', kind:'oral', minAgeMonths:36, maxAgeMonths:83, everyDays:180, source:'بسته خدمات سطح اول؛ سلامت دهان و دندان'),
  HealthRule(id:'oral-school', title:'معاینه دهان و دندان و اقدامات پیشگیرانه مدرسه', kind:'oral', minAgeMonths:84, maxAgeMonths:179, everyDays:365, source:'بسته خدمات سلامت دهان و دندان مدارس'),
  HealthRule(id:'oral-preg', title:'مراقبت سلامت دهان و دندان پیش از بارداری/بارداری/پس از زایمان', kind:'oral', gender:'زن', pregnancyOnly:true, everyDays:180, source:'بسته خدمات سطح اول؛ سلامت دهان و دندان مادران'),
];

const pregnancyRules = <HealthRule>[
  HealthRule(id:'preg-midwife-1', title:'مراقبت بارداری ۱ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-2', title:'مراقبت بارداری ۲ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-3', title:'مراقبت بارداری ۳ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-4', title:'مراقبت بارداری ۴ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-5', title:'مراقبت بارداری ۵ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-6', title:'مراقبت بارداری ۶ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-7', title:'مراقبت بارداری ۷ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-midwife-8', title:'مراقبت بارداری ۸ از ۸ (ماما)', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سلامت مادران؛ تعداد و زمان مراجعه باید با ماما تطبیق داده شود'),
  HealthRule(id:'preg-doctor-1', title:'ویزیت پزشک در بارداری ۱ از ۳', kind:'pregnancy', pregnancyOnly:true, everyDays:84, source:'گزارش معاونت بهداشت درباره بسته مراقبت مادران ۱۴۰۴'),
  HealthRule(id:'preg-doctor-2', title:'ویزیت پزشک در بارداری ۲ از ۳', kind:'pregnancy', pregnancyOnly:true, everyDays:84, source:'گزارش معاونت بهداشت درباره بسته مراقبت مادران ۱۴۰۴'),
  HealthRule(id:'preg-doctor-3', title:'ویزیت پزشک در بارداری ۳ از ۳', kind:'pregnancy', pregnancyOnly:true, everyDays:84, source:'گزارش معاونت بهداشت درباره بسته مراقبت مادران ۱۴۰۴'),
  HealthRule(id:'preg-nutrition', title:'ارزیابی و مشاوره تغذیه بارداری', kind:'pregnancy', pregnancyOnly:true, everyDays:28, source:'بسته خدمات سطح اول؛ خدمات کارشناس تغذیه'),
  HealthRule(id:'preg-oral', title:'مراقبت دهان و دندان بارداری', kind:'pregnancy', pregnancyOnly:true, everyDays:180, source:'بسته خدمات سلامت دهان و دندان'),
  HealthRule(id:'preg-labs', title:'بررسی آزمایش‌ها و غربالگری‌های لازم بارداری طبق بسته و نظر ماما/پزشک', kind:'pregnancy', pregnancyOnly:true, everyDays:84, source:'بسته خدمات سلامت مادران'),
];
