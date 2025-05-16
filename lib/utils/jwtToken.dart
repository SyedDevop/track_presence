import 'dart:convert';

class JwtToken {
  final String raw; // the full JWT string
  final String sub;
  final String id;
  final String type;
  final String name;
  final String department;
  final String designation;
  final String iss;
  final int iat;
  final int exp;

  JwtToken._({
    required this.raw,
    required this.sub,
    required this.id,
    required this.type,
    required this.name,
    required this.department,
    required this.designation,
    required this.iss,
    required this.iat,
    required this.exp,
  });

  /// Factory to decode a raw JWT and construct a JwtToken.
  /// Throws FormatException if the token is malformed.
  factory JwtToken.fromRawToken(String token) {
    final claims = JwtToken.decode(token);
    // Extract and validate required claims
    if (!claims.containsKey('sub') ||
        !claims.containsKey('id') ||
        !claims.containsKey('type') ||
        !claims.containsKey('name') ||
        !claims.containsKey('department') ||
        !claims.containsKey('designation') ||
        !claims.containsKey('iss') ||
        !claims.containsKey('iat') ||
        !claims.containsKey('exp')) {
      throw const FormatException('Missing one or more required JWT claims');
    }

    return JwtToken._(
      raw: token,
      sub: claims['sub'] as String,
      id: claims['id'] as String,
      type: claims['type'] as String,
      name: claims['name'] as String,
      department: claims['department'] as String,
      designation: claims['designation'] as String,
      iss: claims['iss'] as String,
      iat: claims['iat'] as int,
      exp: claims['exp'] as int,
    );
  }

  /// Decode a string JWT token into a `Map<String, dynamic>`
  /// containing the decoded JSON payload.
  ///
  /// Note: header and signature are not returned by this method.
  ///
  /// Throws [FormatException] if parameter is not a valid JWT token.
  static Map<String, dynamic> decode(String token) {
    final parts = token.split("."); // Split the token by '.'
    if (parts.length != 3) {
      throw const FormatException('Invalid token structure');
    }
    try {
      // Decode payload (the middle part)
      final payloadBase64 = parts[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = json.decode(payloadJson);
      return claims;
    } catch (error) {
      throw const FormatException('Invalid payload');
    }
  }

  /// Decode a string JWT token into a `Map<String, dynamic>`
  /// containing the decoded JSON payload.
  ///
  /// Note: header and signature are not returned by this method.
  ///
  /// Returns null if the token is not valid
  static Map<String, dynamic>? tryDecode(String token) {
    try {
      return decode(token);
    } catch (error) {
      return null;
    }
  }

  /// Returns true if the current time is past the `exp` claim.
  bool isExpired() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  /// Checks that the issuer matches your expected value.
  bool validateIssuer(String expectedIssuer) => iss == expectedIssuer;

  /// Combined validity check: expiry + (optional) issuer
  bool isValid({String? expectedIssuer}) {
    if (isExpired()) return false;
    if (expectedIssuer != null && !validateIssuer(expectedIssuer)) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'JwtToken(sub: $sub, id: $id, type: $type, '
        'name: $name, department: $department, '
        'designation: $designation, iss: $iss, '
        'iat: $iat, exp: $exp)';
  }
}
