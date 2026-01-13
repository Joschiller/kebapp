import 'package:equatable/equatable.dart';
import 'package:kebapp_client/kebapp_client.dart';

class OrderDisplayInformation extends Equatable {
  final int mealId;
  final String remarks;
  final List<int> mealInputOptionIds;

  const OrderDisplayInformation({
    required this.mealId,
    required this.remarks,
    required this.mealInputOptionIds,
  });

  @override
  List<Object?> get props => [
        mealId,
        remarks,
        mealInputOptionIds..sort(),
      ];
}

extension OrderDtoToOrderDisplayInformation on OrderDto {
  OrderDisplayInformation get displayInformation => OrderDisplayInformation(
        mealId: mealId,
        remarks: remarks,
        mealInputOptionIds: mealInputOptionIds,
      );
}
