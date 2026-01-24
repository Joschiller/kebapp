class SessionInfo {
  final int? userId;
  final String? userName;
  final bool canRead;
  final bool canWrite;
  final bool canWriteUserName;
  final bool isAdmin;

  SessionInfo({
    required this.userId,
    required this.userName,
    required this.canRead,
    required this.canWrite,
    required this.canWriteUserName,
    required this.isAdmin,
  });

  bool get isUnlocked => canRead || canWrite || canWriteUserName || isAdmin;
}
