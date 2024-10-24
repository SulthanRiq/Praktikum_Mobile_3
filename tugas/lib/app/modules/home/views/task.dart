class Task {
  String id;
  String title;

  Task({required this.id, required this.title});

  factory Task.fromFirestore(Map<String, dynamic> json, String id) {
    return Task(
      id: id,
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
    };
  }
}
