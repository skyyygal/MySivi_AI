String formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String getLastSeenTime(DateTime lastSeen) {
  final difference = DateTime.now().difference(lastSeen);
  if (difference.inMinutes < 1) return 'Online';
  if (difference.inHours < 1) return '${difference.inMinutes} mins ago';
  if (difference.inDays < 1) return '${difference.inHours} hrs ago';
  return '${difference.inDays} days ago';
}

String formatChatTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays} days ago';
}
