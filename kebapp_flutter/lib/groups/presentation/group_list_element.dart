import 'package:flutter/material.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/utils.dart';

class GroupListElement extends StatelessWidget {
  const GroupListElement({super.key, required this.group});

  final GroupDto group;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8),
                  (group.timeOfDay - TimeOfDay.now().toInt()).abs() <= 10
                      ? Icon(
                          Icons.alarm,
                          size: 24,
                        )
                      : Icon(
                          Icons.schedule,
                          size: 16,
                        ),
                  SizedBox(width: 2),
                  Text(
                    '(${(group.timeOfDay / 60).toInt().toString().padLeft(2, '0')}:${(group.timeOfDay % 60).toString().padLeft(2, '0')})',
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${group.members.where((m) => m.accepted).length} members',
                  )
                ],
              ),
            ],
          ),
        ),
      );
}
