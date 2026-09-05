class CareItem {
  final String id;
  final String personId;
  final String personName;
  final String title;
  final DateTime dueDate;
  final String kind;
  final String source;

  const CareItem({
    required this.id,
    required this.personId,
    required this.personName,
    required this.title,
    required this.dueDate,
    required this.kind,
    required this.source,
  });
}
