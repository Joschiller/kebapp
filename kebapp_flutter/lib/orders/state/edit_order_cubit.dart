import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class EditOrderCubitState {}

class EditOrderCubitLoading extends EditOrderCubitState {}

class EditOrderCubitNoPermission extends EditOrderCubitState {}

class EditOrderCubitLoaded extends EditOrderCubitState {
  final OrderDto? order;

  EditOrderCubitLoaded({required this.order});
}

class EditOrderCubit extends Cubit<EditOrderCubitState> {
  EditOrderCubit(this.groupId) : super(EditOrderCubitLoading()) {
    load();
  }

  final int groupId;

  Future<void> load() async {
    try {
      final order = await client.groupRead.getOrderByGroupId(groupId);

      emit(
        EditOrderCubitLoaded(
          order: order,
        ),
      );
    } catch (e) {
      emit(EditOrderCubitNoPermission());
    }
  }

  Future<void> upsertOrder(OrderDto order) async {
    try {
      await client.groupWrite.upsertOrder(groupId, order).then((_) => load());
    } catch (e) {
      // ignore
    }
  }

  Future<void> deleteOrder() async {
    try {
      await client.groupWrite.deleteOrder(groupId).then((_) => load());
    } catch (e) {
      // ignore
    }
  }
}
