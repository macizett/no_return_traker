import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'Global.dart';
import 'NodeModel.dart';

Future<void> loadJsonToHive() async {
  // Wait for the language setting to resolve
  final String lang = await languageSetting();

  // Now use the resolved language string to construct the path
  final String jsonFile = await rootBundle.loadString('assets/database/dialog_nodes_$lang.json');
  final data = json.decode(jsonFile);

  if (nodeBox.isEmpty) {
    for (var node in data['nodes']) {
      List<String> variants = [];
      for (var variantItem in node['variant']) {
        variants.add(variantItem['text']);
      }

      List<Option> options = [];
      for (var option in node['options']) {
        options.add(Option(
          text: option['text'],
          nextNode: option['nextoption'],
        ));
      }

      nodeBox.put(node['id'], Node(
          id: node['id'],
          variant: variants,
          options: options,
          action: node['action'],
          person: node['person'],
          act: node['act']
      ));
    }
  }
}