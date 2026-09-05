class Person {
  String id, firstName, lastName, gender;
  DateTime birthDate, createdAt;
  List<String> conditions;
  bool pregnant;
  DateTime? pregnancyStartDate;

  Person({required this.id, required this.firstName, required this.lastName, required this.birthDate, required this.createdAt, required this.gender, required this.conditions, this.pregnant=false, this.pregnancyStartDate});
  Map<String,dynamic> toJson()=>{'id':id,'firstName':firstName,'lastName':lastName,'birthDate':birthDate.toIso8601String(),'createdAt':createdAt.toIso8601String(),'gender':gender,'conditions':conditions,'pregnant':pregnant,'pregnancyStartDate':pregnancyStartDate?.toIso8601String()};
  factory Person.fromJson(Map<String,dynamic> j)=>Person(id:j['id'] as String,firstName:j['firstName'] as String,lastName:j['lastName'] as String,birthDate:DateTime.parse(j['birthDate'] as String),createdAt:DateTime.parse((j['createdAt'] as String?) ?? DateTime.now().toIso8601String()),gender:j['gender'] as String,conditions:List<String>.from(j['conditions'] ?? const <String>[]),pregnant:(j['pregnant'] as bool?) ?? false,pregnancyStartDate:j['pregnancyStartDate'] == null ? null : DateTime.tryParse(j['pregnancyStartDate'] as String));
}
