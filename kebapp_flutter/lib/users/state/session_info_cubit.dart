import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/main.dart';
import 'package:kebapp_flutter/models/session_info.dart';

class SessionInfoCubit extends Cubit<SessionInfo?> {
  final Future<void> Function() doSignout;
  final Future<void> Function() doRefresh;

  SessionInfoCubit({
    required this.doSignout,
    required this.doRefresh,
  }) : super(null);

  void update(SessionInfo? info) => emit(info);

  Future<void> updateUsername(String newUserName) =>
      client.username.updateUsername(newUserName).then((_) => doRefresh());
}
