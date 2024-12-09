import 'package:shared_preferences/shared_preferences.dart';

import 'Global.dart';
import 'NodeModel.dart';
import 'NodesProgressModel.dart';

Future<Node?> getNodeById(int nodeId) async {
  var node = nodeBox.get(nodeId);
  return node;
}

Future<List<UserProgressNode>> getUserProgress() async {
  List<UserProgressNode> allProgress = userProgressBox.values.cast<UserProgressNode>().toList();
  return allProgress;
}

Future<void> putUserProgress(int nodeId, String text, String option, String person, int act) async {
  await userProgressBox.put(nodeId, UserProgressNode(id: nodeId, text: text, option: option, person: person, act: act));
}

Future<void> clearUserProgress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // This clears all SharedPreferences data
  await userProgressBox.clear(); // This will remove all entries from the box
}


