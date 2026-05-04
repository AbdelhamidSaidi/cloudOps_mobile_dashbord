class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  AuthToken({required this.accessToken, this.refreshToken, this.expiresIn});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_in': expiresIn,
  };
}
