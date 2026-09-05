import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/person.dart';
import 'models/care_item.dart';
import 'data/health_rules.dart';
import 'services/care_engine.dart';

const navy = Color(0xFF0B4F9C);
const bg = Color(0xFFF5F7FA);
const green = Color(0xFF2E9B61);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
  await store.load();
  await NotificationService.rescheduleAll();
  runApp(const FamilyDoctorApp());
}

final store = AppStore();

class AppStore extends ChangeNotifier {
  List<Person> people = [];
  Position? residence;
  final Set<String> completedCareIds = <String>{};
  bool notificationsEnabled = true;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final completed = p.getStringList('completed_cares');
    if (completed != null) completedCareIds.addAll(completed);
    notificationsEnabled = p.getBool('notifications_enabled') ?? true;
    final raw = p.getString('people');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          people = decoded
              .whereType<Map<String, dynamic>>()
              .map(Person.fromJson)
              .toList();
        }
      } catch (_) {
        // Keep the app usable even if old/corrupted local data cannot be decoded.
        people = [];
      }
    }
    final lat = p.getDouble('lat');
    final lon = p.getDouble('lon');
    if (lat != null && lon != null) residence = Position(latitude: lat, longitude: lon, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
    notifyListeners();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('people', jsonEncode(people.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool('notifications_enabled', value);
    if (!value) {
      await NotificationService.cancelAll();
    } else {
      await NotificationService.rescheduleAll();
    }
    notifyListeners();
  }

  Future<void> setCareCompleted(String id, bool value) async {
    if (value) {
      completedCareIds.add(id);
    } else {
      completedCareIds.remove(id);
    }
    final p = await SharedPreferences.getInstance();
    await p.setStringList('completed_cares', completedCareIds.toList());
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    people.clear();
    completedCareIds.clear();
    residence = null;
    notificationsEnabled = true;
    await NotificationService.cancelAll();
    notifyListeners();
  }

  Future<void> setResidence(Position x) async {
    residence = x;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('lat', x.latitude);
    await p.setDouble('lon', x.longitude);
    notifyListeners();
  }

  Future<void> add(Person x) async {
    people.add(x);
    await save();
    await NotificationService.rescheduleAll();
  }

  Future<void> remove(String id) async {
    people.removeWhere((x) => x.id == id);
    completedCareIds.removeWhere((key) => key.startsWith('$id-'));
    await save();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('completed_cares', completedCareIds.toList());
    await NotificationService.rescheduleAll();
  }
}

class NotificationService {
  static final plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationDetails(
    'family_health',
    'پزشک خانواده',
    channelDescription: 'یادآوری‌های سلامت',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show(String title, String body) async {
    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> schedule(CareItem item) async {
    if (!store.notificationsEnabled || store.completedCareIds.contains(item.id)) return;
    final due = tz.TZDateTime(tz.local, item.dueDate.year, item.dueDate.month, item.dueDate.day, 9);
    if (due.isBefore(tz.TZDateTime.now(tz.local))) return;
    await plugin.zonedSchedule(
      id: item.id.hashCode.abs(),
      title: item.title,
      body: item.personName,
      scheduledDate: due,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() => plugin.cancelAll();

  static Future<void> rescheduleAll() async {
    await cancelAll();
    if (!store.notificationsEnabled) return;
    final now = DateTime.now();
    for (final person in store.people) {
      for (final item in CareEngine.build(person, now)) {
        await schedule(item);
      }
    }
  }
}

class FamilyDoctorApp extends StatelessWidget {
  const FamilyDoctorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'پزشک خانواده', theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: bg, colorScheme: ColorScheme.fromSeed(seedColor: navy), fontFamily: 'Arial', inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: navy, width: 1.2)))), home: const HomePage());
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  int tab = 0;
  @override Widget build(BuildContext c) {
    final pages = [const Dashboard(), const PeoplePage(), const CalendarPage(), const HealthCenterPage()];
    return Scaffold(body: SafeArea(child: pages[tab]), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'سلامت'),
      NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'افراد من'),
      NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'تقویم'),
      NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'مرکز سلامت'),
    ]));
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override Widget build(BuildContext c) => AnimatedBuilder(animation: store, builder: (c, _) {
    final cares = store.people.expand((p) => CareEngine.build(p, DateTime.now())).toList()..sort((a,b)=>a.dueDate.compareTo(b.dueDate));
    final today = DateTime.now();
    final todayCares = cares.where((x)=>_sameDay(x.dueDate, today)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), children: [
      Row(children: [const CircleAvatar(radius: 25, backgroundColor: navy, child: Icon(Icons.favorite, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('پزشک خانواده', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: navy)), Text('سلامت خانواده، ساده و به‌موقع', style: TextStyle(color: Colors.black54))])), IconButton(onPressed: () => NotificationService.show('پزشک خانواده', 'یادآوری‌های سلامت شما آماده است.'), icon: const Icon(Icons.notifications_none)), IconButton(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SettingsPage())), icon: const Icon(Icons.settings_outlined))]),
      const SizedBox(height: 22),
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('کارهای امروز', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), if (todayCares.isEmpty) const ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: Color(0xFFE8F0FA), child: Icon(Icons.check, color: navy)), title: Text('موردی برای امروز ندارید'), subtitle: Text('تقویم سلامت شما به‌صورت خودکار محاسبه می‌شود.')) else ...todayCares.take(4).map((x)=>CareTile(item:x))])),
      const SizedBox(height: 18),
      Row(children: [const Expanded(child: Text('افراد من', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), TextButton.icon(onPressed: ()=>Navigator.push(c, MaterialPageRoute(builder: (_)=>const AddPersonPage())), icon: const Icon(Icons.add), label: const Text('افزودن'))]),
      const SizedBox(height: 8),
      if (store.people.isEmpty) _emptyAdd(c) else ...store.people.map((p)=>PersonTile(person:p)),
      const SizedBox(height: 18),
      const Text('این برنامه برای یادآوری و هدایت به خدمات سلامت است و جایگزین تشخیص یا درمان پزشک نیست.', style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  });
  static bool _sameDay(DateTime a, DateTime b)=>a.year==b.year&&a.month==b.month&&a.day==b.day;
  Widget _emptyAdd(BuildContext c)=>Card(elevation:0, child: InkWell(onTap:()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>const AddPersonPage())), borderRadius:BorderRadius.circular(20), child:const Padding(padding:EdgeInsets.all(24), child:Row(children:[CircleAvatar(radius:28,backgroundColor:Color(0xFFE8F0FA),child:Icon(Icons.person_add,color:navy)),SizedBox(width:15),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('اولین فرد را اضافه کنید',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),Text('نام، تاریخ تولد و چند سؤال ضروری کافی است.',style:TextStyle(color:Colors.black54))]))]))));
}

class CareTile extends StatelessWidget {
  final CareItem item;
  const CareTile({super.key, required this.item});
  @override
  Widget build(BuildContext c) => AnimatedBuilder(
    animation: store,
    builder: (c, _) {
      final done = store.completedCareIds.contains(item.id);
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: done ? const Color(0xFFE7F5EC) : const Color(0xFFE8F0FA),
          child: Icon(done ? Icons.check : Icons.event_available, color: done ? green : navy),
        ),
        title: Text('${item.title}، ${item.personName}', style: TextStyle(decoration: done ? TextDecoration.lineThrough : null)),
        subtitle: Text(_date(item.dueDate)),
        trailing: Checkbox(
          value: done,
          onChanged: (v) => store.setCareCompleted(item.id, v == true),
        ),
      );
    },
  );
}
String _date(DateTime d){final j=Jalali.fromDateTime(d);return '${j.year}/${j.month.toString().padLeft(2,'0')}/${j.day.toString().padLeft(2,'0')}';}

class PersonTile extends StatelessWidget { final Person person; const PersonTile({super.key,required this.person}); String age(){try{final b=Jalali.fromDateTime(person.birthDate);final n=Jalali.now();var y=n.year-b.year;if(n.month<b.month||(n.month==b.month&&n.day<b.day))y--;return '$y سال';}catch(_){return '';}} @override Widget build(BuildContext c)=>Card(elevation:0,child:ListTile(leading:CircleAvatar(backgroundColor:person.gender=='زن'?const Color(0xFFFFEAF0):const Color(0xFFE8F0FA),child:Icon(person.gender=='زن'?Icons.female:Icons.male,color:navy)),title:Text('${person.firstName} ${person.lastName}',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(age()),trailing:const Icon(Icons.chevron_left),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>PersonDetails(person:person))))); }

class AddPersonPage extends StatefulWidget { const AddPersonPage({super.key}); @override State<AddPersonPage> createState()=>_AddPersonPageState(); }
class _AddPersonPageState extends State<AddPersonPage> {
  int step=0; final first=TextEditingController(), last=TextEditingController(); Jalali? dob; String gender=''; final conditions=<String>{}; bool pregnant=false; Jalali? pregnancyStart;
  Future<void> pickDate() async { final x=await showPersianDatePicker(context:context,initialDate:dob??Jalali.now(),firstDate:Jalali(1300),lastDate:Jalali(1500)); if(x!=null)setState(()=>dob=x); }
  void next(){ if(step==0&&(first.text.trim().isEmpty||last.text.trim().isEmpty))return; if(step==1&&dob==null)return; if(step==2&&gender.isEmpty)return; if(step<3)setState(()=>step++); else finish(); }
  Future<void> finish() async { final p=Person(id:DateTime.now().microsecondsSinceEpoch.toString(),firstName:first.text.trim(),lastName:last.text.trim(),birthDate:dob!.toGregorian().toDateTime(),createdAt:DateTime.now(),gender:gender,conditions:conditions.toList(),pregnant:pregnant,pregnancyStartDate:pregnancyStart?.toGregorian().toDateTime()); await store.add(p); for(final item in CareEngine.build(p,DateTime.now())) { await NotificationService.schedule(item); } if(mounted)Navigator.pop(context); }
  @override Widget build(BuildContext c){final total=4;final title=step==0?'اطلاعات فرد':step==1?'تاریخ تولد':step==2?'جنسیت':'بیماری خاص';return Scaffold(appBar:AppBar(title:Text(title)),body:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[LinearProgressIndicator(value:(step+1)/total,minHeight:5,borderRadius:BorderRadius.circular(5)),const SizedBox(height:30),Expanded(child:_body()),FilledButton(onPressed:next,child:Padding(padding:const EdgeInsets.all(14),child:Text(step==3?'ذخیره':'ادامه',style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold))))])));}
  Widget _body(){if(step==0)return Column(children:[TextField(controller:first,decoration:const InputDecoration(labelText:'نام')),const SizedBox(height:16),TextField(controller:last,decoration:const InputDecoration(labelText:'نام خانوادگی'))]);if(step==1)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.calendar_month,size:70,color:navy),const SizedBox(height:18),Text(dob==null?'تاریخ تولد را انتخاب کنید':'${dob!.year}/${dob!.month.toString().padLeft(2,'0')}/${dob!.day.toString().padLeft(2,'0')}',style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:20),OutlinedButton.icon(onPressed:pickDate,icon:const Icon(Icons.calendar_today),label:const Text('انتخاب تاریخ'))]));if(step==2)return Column(children:[const Text('جنسیت را انتخاب کنید',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:20),_gender('زن',Icons.female),_gender('مرد',Icons.male)]);if(step==3)return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('وضعیت‌های مهم سلامت',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('مواردی را انتخاب کنید که مراقبت یا یادآوری مشخصی برای آن‌ها لازم است.',style:TextStyle(color:Colors.black54)),const SizedBox(height:8),if(gender=='زن')SwitchListTile(contentPadding:EdgeInsets.zero,value:pregnant,onChanged:(v)=>setState(()=>pregnant=v),title:const Text('بارداری فعلی'),subtitle:const Text('برای فعال شدن برنامه مراقبت مادران')),if(pregnant&&gender=='زن')ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.calendar_month,color:navy),title:Text(pregnancyStart==null?'تاریخ شروع بارداری/آخرین قاعدگی را وارد کنید':'شروع: ${pregnancyStart!.year}/${pregnancyStart!.month}/${pregnancyStart!.day}'),onTap:()async{final x=await showPersianDatePicker(context:context,initialDate:pregnancyStart??Jalali.now(),firstDate:Jalali(1300),lastDate:Jalali(1500));if(x!=null)setState(()=>pregnancyStart=x);}),Expanded(child:ListView(children:[...conditionOptions.map((x)=>CheckboxListTile(value:conditions.contains(x),onChanged:(v)=>setState(()=>v==true?conditions.add(x):conditions.remove(x)),title:Text(x),controlAffinity:ListTileControlAffinity.leading))]))];}
  @override void dispose(){ first.dispose(); last.dispose(); super.dispose(); }
  Widget _gender(String g,IconData i)=>Card(color:gender==g?const Color(0xFFE8F0FA):Colors.white,elevation:0,child:ListTile(onTap:()=>setState(()=>gender=g),leading:Icon(i,color:navy,size:34),title:Text(g,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),trailing:gender==g?const Icon(Icons.check_circle,color:green):null));
}

class PersonDetails extends StatelessWidget { final Person person; const PersonDetails({super.key,required this.person}); @override Widget build(BuildContext c){final cares=CareEngine.build(person,DateTime.now());return Scaffold(appBar:AppBar(title:Text('${person.firstName} ${person.lastName}'),actions:[IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{final ok=await showDialog<bool>(context:c,builder:(d)=>AlertDialog(title:const Text('حذف فرد'),content:const Text('اطلاعات این فرد از این دستگاه حذف شود؟'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('انصراف')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('حذف'))]));if(ok==true){await store.remove(person.id);if(c.mounted)Navigator.pop(c);}})]),body:ListView(padding:const EdgeInsets.all(20),children:[Card(elevation:0,child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[CircleAvatar(radius:38,backgroundColor:const Color(0xFFE8F0FA),child:Icon(person.gender=='زن'?Icons.female:Icons.male,size:42,color:navy)),const SizedBox(height:12),Text('${person.firstName} ${person.lastName}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),Text('${person.gender} • ${_date(person.birthDate)}',style:const TextStyle(color:Colors.black54))]))),const SizedBox(height:18),const Text('وضعیت‌های ثبت‌شده',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),if(person.conditions.isEmpty)const ListTile(leading:Icon(Icons.check_circle_outline,color:green),title:Text('هیچکدام')) else ...person.conditions.map((x)=>ListTile(leading:const Icon(Icons.check_circle_outline,color:green),title:Text(x))),if(person.pregnant)const ListTile(leading:Icon(Icons.pregnant_woman,color:navy),title:Text('بارداری فعال')),const SizedBox(height:18),const Text('مراقبت‌های محاسبه‌شده',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),if(cares.isEmpty)const ListTile(title:Text('موردی برای نمایش وجود ندارد.')) else ...cares.take(12).map((x)=>CareTile(item:x)),const SizedBox(height:12),Text('منبع قاعده: ${cares.isEmpty?'—':cares.first.source}',style:const TextStyle(fontSize:11,color:Colors.black45))]);}}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('تنظیمات')),
    body: AnimatedBuilder(
      animation: store,
      builder: (c, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: store.notificationsEnabled,
              onChanged: store.setNotificationsEnabled,
              title: const Text('یادآوری‌های سلامت'),
              subtitle: const Text('اعلان‌های برنامه را فعال یا غیرفعال کنید.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: navy),
              title: const Text('حریم خصوصی'),
              subtitle: const Text('اطلاعات نسخه فعلی روی همین دستگاه نگهداری می‌شود.'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
              title: const Text('حذف همه اطلاعات'),
              subtitle: const Text('تمام افراد، وضعیت مراقبت‌ها و محل ذخیره‌شده حذف می‌شود.'),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: c,
                  builder: (d) => AlertDialog(
                    title: const Text('حذف همه اطلاعات'),
                    content: const Text('این کار قابل بازگشت نیست. ادامه می‌دهید؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('انصراف')),
                      FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('حذف همه')),
                    ],
                  ),
                );
                if (ok == true) {
                  await store.deleteAllData();
                  if (c.mounted) Navigator.pop(c);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('پزشک خانواده • نسخه توسعه‌ای V1', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45)),
        ],
      ),
    ),
  );
}

class PeoplePage extends StatelessWidget { const PeoplePage({super.key}); @override Widget build(BuildContext c)=>AnimatedBuilder(animation:store,builder:(c,_)=>ListView(padding:const EdgeInsets.all(20),children:[Row(children:[const Expanded(child:Text('افراد من',style:TextStyle(fontSize:26,fontWeight:FontWeight.w800))),IconButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const AddPersonPage())),icon:const Icon(Icons.person_add))]),const SizedBox(height:12),if(store.people.isEmpty)const Text('هنوز فردی ثبت نشده است.') else ...store.people.map((p)=>PersonTile(person:p))])); }

class CalendarPage extends StatelessWidget { const CalendarPage({super.key}); @override Widget build(BuildContext c)=>AnimatedBuilder(animation:store,builder:(c,_) {final all=store.people.expand((p)=>CareEngine.build(p,DateTime.now())).toList()..sort((a,b)=>a.dueDate.compareTo(b.dueDate));return ListView(padding:const EdgeInsets.all(20),children:[const Text('تقویم سلامت',style:TextStyle(fontSize:26,fontWeight:FontWeight.w800)),const SizedBox(height:16),if(all.isEmpty)const Card(elevation:0,child:Padding(padding:EdgeInsets.all(24),child:Text('با افزودن اعضای خانواده، مراقبت‌های قابل محاسبه در اینجا نمایش داده می‌شوند.'))) else ...all.take(30).map((x)=>Card(elevation:0,child:CareTile(item:x))) ]);}); }

class HealthCenterPage extends StatelessWidget { const HealthCenterPage({super.key}); @override Widget build(BuildContext c)=>AnimatedBuilder(animation:store,builder:(c,_)=>ListView(padding:const EdgeInsets.all(20),children:[const Text('مرکز سلامت من',style:TextStyle(fontSize:26,fontWeight:FontWeight.w800)),const SizedBox(height:18),Card(elevation:0,child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[Icon(Icons.location_on,size:60,color:green),const SizedBox(height:12),Text(store.residence==null?'محل سکونت ثبت نشده است':'محل سکونت ثبت شده',style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),if(store.residence!=null)Text('${store.residence!.latitude.toStringAsFixed(5)}, ${store.residence!.longitude.toStringAsFixed(5)}',style:const TextStyle(color:Colors.black54)),const SizedBox(height:16),FilledButton.icon(onPressed:()=>_setLocation(c),icon:const Icon(Icons.my_location),label:const Text('ثبت محل سکونت با موقعیت فعلی')),const SizedBox(height:8),OutlinedButton.icon(onPressed:()=>_openMaps(c),icon:const Icon(Icons.map_outlined),label:const Text('یافتن مراکز سلامت نزدیک'))]))),const SizedBox(height:14),const Text('توجه: تعیین «مرکز سلامت تحت پوشش» نیازمند داده رسمی محدوده‌های تحت پوشش دانشگاه علوم پزشکی است. برنامه مختصات را به‌عنوان محل سکونت نگه می‌دارد و تا زمان اتصال به داده رسمی، مرکز را حدس نمی‌زند.',style:TextStyle(fontSize:12,color:Colors.black54))])); }
  Future<void> _setLocation(BuildContext c) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('ابتدا موقعیت مکانی دستگاه را روشن کنید.')));
        return;
      }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('دسترسی موقعیت مکانی داده نشد.')));
        return;
      }
      final x = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.balanced));
      await store.setResidence(x);
      if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('محل سکونت با موفقیت ذخیره شد.')));
    } catch (_) {
      if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('دریافت موقعیت مکانی ممکن نبود.')));
    }
  }
  Future<void> _openMaps(BuildContext c) async {final q=store.residence==null?'مرکز خدمات جامع سلامت ایران':'مرکز خدمات جامع سلامت نزدیک ${store.residence!.latitude},${store.residence!.longitude}';final u=Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}');if(!await launchUrl(u,mode:LaunchMode.externalApplication)&&c.mounted)ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content:Text('بازکردن نقشه ممکن نبود.')));}
}
