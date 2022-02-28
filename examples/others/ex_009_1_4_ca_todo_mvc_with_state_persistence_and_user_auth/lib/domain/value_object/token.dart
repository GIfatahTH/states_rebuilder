import 'dart:convert';

import '../common/extensions.dart';

class Token {
  final String? _token;
  final String? refreshToken;
  final DateTime? expiryDate;

  Token({
    String? token,
    required this.expiryDate,
    required this.refreshToken,
  }) : _token = token;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token == null || expiryDate == null) {
      return null;
    }
    if (expiryDate!.isAfter(DateTimeX.current)) {
      return _token;
    }
    return null;
  }

  Token copyWith({
    String? token,
    String? refreshToken,
    DateTime? expiryDate,
  }) {
    return Token(
      token: token ?? this._token,
      expiryDate: expiryDate ?? this.expiryDate,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': _token,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'refreshToken': refreshToken,
    };
  }

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      token: map['token'],
      refreshToken: map['refreshToken'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Token.fromJson(String source) => Token.fromMap(json.decode(source));

  @override
  String toString() => 'Token(token: $_token, expiryDate: $expiryDate)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Token && o._token == _token && o.expiryDate == expiryDate;
  }

  @override
  int get hashCode => _token.hashCode ^ expiryDate.hashCode;
}
