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

Future<void> putUserProgress(int nodeId, int uniqueID, String text, String option, String person, int act) async {
  await userProgressBox.put(nodeId, UserProgressNode(id: nodeId, uniqueID: uniqueID, text: text, option: option, person: person, act: act));
}

Future<void> clearUserProgress() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // This clears all SharedPreferences data
  await userProgressBox.clear(); // This will remove all entries from the box
}

Future<void> deleteLastXOfUserProgress(int count) async {
  // Get all keys from the box, sorted in ascending order
  final keys = userProgressBox.keys.toList()..sort();

  // If there are fewer entries than requested count, adjust the count
  final numberOfItemsToDelete = count > keys.length ? keys.length : count;

  // Delete the last N items by getting the last N keys
  for (int i = 0; i < numberOfItemsToDelete; i++) {
    final keyToDelete = keys[keys.length - 1 - i];
    await userProgressBox.delete(keyToDelete);
  }
}


