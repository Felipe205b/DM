class Book {
  final String id;
  final String userId;
  final String name;
  final int totalPages;
  final int daysToRead;
  final int pagesRead;
  final int daysRead;
  final List<bool> dailyProgress;

  Book({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalPages,
    required this.daysToRead,
    this.pagesRead = 0,
    this.daysRead = 0,
    List<bool>? dailyProgress,
  }) : dailyProgress = dailyProgress ?? List.filled(daysToRead, false);

  Book copyWith({
    String? id,
    String? userId,
    String? name,
    int? totalPages,
    int? daysToRead,
    int? pagesRead,
    int? daysRead,
    List<bool>? dailyProgress,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalPages: totalPages ?? this.totalPages,
      daysToRead: daysToRead ?? this.daysToRead,
      pagesRead: pagesRead ?? this.pagesRead,
      daysRead: daysRead ?? this.daysRead,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'totalPages': totalPages,
      'daysToRead': daysToRead,
      'pagesRead': pagesRead,
      'daysRead': daysRead,
      'dailyProgress': dailyProgress,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      totalPages: map['totalPages'],
      daysToRead: map['daysToRead'],
      pagesRead: map['pagesRead'] ?? 0,
      daysRead: map['daysRead'] ?? 0,
      dailyProgress: map['dailyProgress'] != null
          ? List<bool>.from(map['dailyProgress'])
          : List.filled(map['daysToRead'], false),
    );
  }
}
