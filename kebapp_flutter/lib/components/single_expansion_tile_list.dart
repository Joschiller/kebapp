import 'package:flutter/material.dart';

class SingleExpansionTileList extends StatelessWidget {
  const SingleExpansionTileList({super.key, required this.children});

  final Map<String, Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: ExpansionPanelList.radio(
          children: children.entries
              .map(
                (e) => ExpansionPanelRadio(
                  value: e.key,
                  headerBuilder: (context, isExpanded) => ListTile(
                    title: Text(e.key),
                  ),
                  body: e.value,
                  canTapOnHeader: true,
                ),
              )
              .toList(),
        ),
      );
}
