int generateCacheBusterValue() {
  return (DateTime.now().millisecondsSinceEpoch / 1000 / 60) ~/ 5;
}


String getTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  // Less than a minute
  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  // Less than an hour
  if (difference.inHours < 1) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  }

  // Less than 24 hours
  if (difference.inHours < 24) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  }

  // Yesterday
  if (difference.inDays == 1) {
    return 'Yesterday at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Less than 7 days
  if (difference.inDays < 7) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  }

  // More than 7 days
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
}
