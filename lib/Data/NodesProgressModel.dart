import 'package:hive/hive.dart';

part 'NodesProgressModel.g.dart';

@HiveType(typeId: 3)
class UserProgressNode {
  @HiveField(0)
  int id;

  @HiveField(1)
  int uniqueID;

  @HiveField(2)
  String text;

  @HiveField(3)
  String option;

  @HiveField(4)
  String person;

  @HiveField(5)
  int act;

  UserProgressNode({required this.id, required this.uniqueID, required this.text, required this.option, required this.person, required this.act});
}