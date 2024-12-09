import 'package:hive/hive.dart';

part 'NodeModel.g.dart';

@HiveType(typeId: 0)
class Node {
  @HiveField(0)
  int id;

  @HiveField(1)
  List<String> variant;

  @HiveField(2)
  List<Option> options;

  @HiveField(3)
  String? action;

  @HiveField(4)
  String? person;

  @HiveField(5)
  int act;

  Node({required this.id, required this.variant, required this.options, required this.action, required this.person, required this.act});
}

@HiveType(typeId: 1)
class Option {
  @HiveField(0)
  String text;

  @HiveField(1)
  int? nextNode;

  Option({required this.text, this.nextNode});
}