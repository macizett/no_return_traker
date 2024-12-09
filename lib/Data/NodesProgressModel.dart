import 'package:hive/hive.dart';

part 'NodesProgressModel.g.dart';

@HiveType(typeId: 3)
class UserProgressNode {
  @HiveField(0)
  int id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String option;

  @HiveField(3)
  String person;

  @HiveField(4)
  int act;

  UserProgressNode({required this.id, required this.text, required this.option, required this.person, required this.act});
}