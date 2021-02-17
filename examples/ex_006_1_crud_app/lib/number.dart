import 'dart:convert';

class Number {
  final String id;
  final int number;
  Number({
    required this.id,
    required this.number,
  });

  Number copyWith({
    String? id,
    int? number,
  }) {
    return Number(
      id: id ?? this.id,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
    };
  }

  factory Number.fromMap(Map<String, dynamic> map) {
    return Number(
      id: map['id'],
      number: map['number'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Number.fromJson(String source) => Number.fromMap(json.decode(source));

  @override
  String toString() => 'Number(id: $id, number: $number)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Number && o.id == id && o.number == number;
  }

  @override
  int get hashCode => id.hashCode ^ number.hashCode;
}

enum NumType { even, odd, all }

class NumberParam {
  final String userId;
  final NumType numType;
  NumberParam({
    required this.userId,
    required this.numType,
  });

  NumberParam copyWith({
    String? userId,
    NumType? numType,
  }) {
    return NumberParam(
      userId: userId ?? this.userId,
      numType: numType ?? this.numType,
    );
  }
}
