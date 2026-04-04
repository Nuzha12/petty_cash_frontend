class LoginRequest{
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson(){
    return {
      "username": username,
      "password": password,
    };
  }
}

class LoginResponse{
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json){
    return LoginResponse(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
    );
  }
}