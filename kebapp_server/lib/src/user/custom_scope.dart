import 'package:serverpod/serverpod.dart';

class CustomScope extends Scope {
  const CustomScope(super.name);

  static const userRead = CustomScope('userRead');
  static const userWrite = CustomScope('userWrite');
  static const userWriteUserName = CustomScope('userWrite.userName');
  static const adminMeals = CustomScope('admin.meals');
  static const adminRights = CustomScope('admin.rights');
  static const adminVerificationCodes = CustomScope('admin.verificationCodes');
}
