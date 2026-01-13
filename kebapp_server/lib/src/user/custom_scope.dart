import 'package:serverpod/serverpod.dart';

class CustomScope extends Scope {
  const CustomScope(super.name);

  static const userRead = CustomScope('userRead');
  static const userWrite = CustomScope('userWrite');
}
