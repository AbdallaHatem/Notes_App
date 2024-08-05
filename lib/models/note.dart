class Note {
  int? id;
  String title;
  String content;
  int color; // Add color property

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
    );
  }
}
