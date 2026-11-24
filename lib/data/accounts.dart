import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A demo account kept in this browser only. There is no server yet, so this
/// is not real security. See docs/AUTH.md.
class AuthAccount {
  const AuthAccount({
    required this.id,
    required this.name,
    required this.provider,
    this.email = '',
    this.salt = '',
    this.hash = '',
  });

  final String id;
  final String name;

  /// email, google, apple, facebook or guest.
  final String provider;
  final String email;
  final String salt;
  final String hash;

  bool get isGuest => provider == 'guest';

  String get providerLabel => switch (provider) {
        'google' => 'Google',
        'apple' => 'Apple',
        'facebook' => 'Facebook',
        'guest' => 'Guest',
        _ => 'Email',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'provider': provider,
        'email': email,
        'salt': salt,
        'hash': hash,
      };

  factory AuthAccount.fromJson(Map<String, dynamic> j) => AuthAccount(
        id: j['id'] as String,
        name: j['name'] as String,
        provider: j['provider'] as String,
        email: (j['email'] as String?) ?? '',
        salt: (j['salt'] as String?) ?? '',
        hash: (j['hash'] as String?) ?? '',
      );
}

String newSalt() {
  final random = Random.secure();
  return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
}

String hashPassword(String password, String salt) =>
    sha256.convert(utf8.encode('$salt:$password')).toString();

bool looksLikeEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
