class SessionInfo {
  final int? userId;
  final String? userName;
  final bool canRead;
  final bool canWrite;
  final bool canWriteUserName;
  final bool isAdmin;
  final bool canConfigureMeals;
  final bool canConfigureRights;
  final bool canViewPendingVerifications;

  SessionInfo({
    required this.userId,
    required this.userName,
    required this.canRead,
    required this.canWrite,
    required this.canWriteUserName,
    required this.isAdmin,
    required this.canConfigureMeals,
    required this.canConfigureRights,
    required this.canViewPendingVerifications,
  });

  bool get isUnlocked => canRead || canWrite || canWriteUserName || isAdmin;
}
