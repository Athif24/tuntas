class DailyTask {
  final DateTime date;
  final int completedCount;
  final bool isFuture;

  const DailyTask({
    required this.date,
    required this.completedCount,
    required this.isFuture,
  });
}
