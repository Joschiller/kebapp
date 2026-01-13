import 'package:kebapp_client/kebapp_client.dart';

extension MealInputOptionDtoToString on MealInputOptionDto {
  String get labelWithPrice => additionalPrice == 0
      ? description
      : '$description (+ ${(additionalPrice / 100).toStringAsFixed(2)} €)';
}
