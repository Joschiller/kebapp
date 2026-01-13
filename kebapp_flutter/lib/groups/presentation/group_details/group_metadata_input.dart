import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/groups/presentation/group_details/time_input_button.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/groups/state/edit_group_cubit.dart';
import 'package:kebapp_flutter/utils.dart';

class GroupMetadataInput extends StatefulWidget {
  const GroupMetadataInput({
    super.key,
    required this.id,
  });

  final int? id;

  @override
  State<GroupMetadataInput> createState() => _GroupMetadataInputState();
}

class _GroupMetadataInputState extends State<GroupMetadataInput> {
  final _titleController = TextEditingController();
  var _timeOfDay = TimeOfDay(hour: 12, minute: 0);
  final _locationController = TextEditingController();

  var _isValid = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _validate() {
    final isValid = _titleController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty;
    setState(() {
      _isValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => EditGroupCubit(widget.id),
        lazy: false,
        child: BlocConsumer<EditGroupCubit, EditGroupCubitState>(
          listener: (context, state) {
            switch (state) {
              case EditGroupCubitLoaded(group: final group):
                _titleController.text = group.title;
                setState(() {
                  _timeOfDay = group.timeOfDay.toTimeOfDay();
                });
                _locationController.text = group.location;
                _validate();
              default:
                break;
            }
          },
          builder: (context, groupState) => PageWrapper(
            pageTitle: widget.id == null ? 'Create Group' : 'Edit Group',
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: switch (groupState) {
                EditGroupCubitLoading() => Center(
                    child: CircularProgressIndicator(),
                  ),
                EditGroupCubitNoPermission() => SizedBox.shrink(),
                EditGroupCubitLoaded() => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration:
                                    const InputDecoration(hintText: 'Title'),
                                onChanged: (value) => _validate(),
                              ),
                              SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Time of Day'),
                                  SizedBox(width: 16),
                                  TimeInputButton(
                                    value: _timeOfDay,
                                    onChange: (value) => setState(() {
                                      _timeOfDay = value;
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _locationController,
                                decoration:
                                    const InputDecoration(hintText: 'Location'),
                                onChanged: (value) => _validate(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextButton(
                              onPressed: _isValid
                                  ? () async {
                                      await context
                                          .read<EditGroupCubit>()
                                          .upsertGroup(
                                            GroupDto(
                                              id: widget.id ?? -1,
                                              title:
                                                  _titleController.text.trim(),
                                              timeOfDay: _timeOfDay.toInt(),
                                              location: _locationController.text
                                                  .trim(),
                                              // Members are ignored
                                              members: groupState.group.members,
                                            ),
                                          );
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              },
            ),
          ),
        ),
      );
}
