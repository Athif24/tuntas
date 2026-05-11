class Task {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String type;
  final bool isCompleted;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date,
      'type': type,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      type: map['type'] as String,
      isCompleted: map['is_completed'] == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? type,
    bool? isCompleted,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
