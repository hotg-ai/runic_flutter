import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

class HFAuth {
  static FlutterAppAuth appAuth = FlutterAppAuth();
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static String auth0Domain = '';
  static String auth0ClientID = '';
  static String auth0RedirectUri = '';
  static Uri authorizationEndpoint = Uri.parse('');
  static Uri tokenEndpoint = Uri.parse('');
  static String auth0Issuer = '';
  static Map<String, dynamic> idToken = {};
  static Map<String, dynamic> profile = {};
  static bool isLoggedIn = false;
  static bool asked = false;
  static init() async {
    print(">>>>>>initLogin");
    String data = await rootBundle.loadString("assets/auth.json");
    final Map<String, dynamic> auth = jsonDecode(data);
    auth0Domain = auth["AUTH0_DOMAIN"];
    auth0ClientID = auth["AUTH0_CLIENT_ID"];
    auth0RedirectUri = auth["AUTH0_REDIRECT_URI"];
    authorizationEndpoint = Uri.parse('https://$auth0Domain/authorize');
    tokenEndpoint = Uri.parse('https://$auth0Domain/oauth/token');
    auth0Issuer = 'https://$auth0Domain';
    final storedRefreshToken = await secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) {
      print("storedRefreshToken null");
      isLoggedIn = false;
      return;
    }
    if (asked) {
      print("asked $asked");
      return;
    }
    try {
      final response = await appAuth.token(TokenRequest(
        auth0ClientID,
        auth0RedirectUri,
        issuer: auth0Issuer,
        refreshToken: storedRefreshToken,
      ));
      idToken = parseIdToken(response!.idToken!);
      profile = await getUserDetails(response.accessToken!);

      await secureStorage.write(
          key: 'refresh_token', value: response.refreshToken);
      isLoggedIn = true;
      print("isLoggedIn $isLoggedIn");
    } catch (e, s) {
      print('error on refresh token: $e - stack: $s');
      await logout();
    }
    asked = true;
  }

  static Future<bool> checkLogin() async {
    final storedRefreshToken = await secureStorage.read(key: 'refresh_token');
    print("storedRefreshToken $storedRefreshToken");
    isLoggedIn = storedRefreshToken != null;
    return isLoggedIn;
  }

  static logout() async {
    await secureStorage.delete(key: 'refresh_token');
    isLoggedIn = false;
    asked = true;
  }

  static login() async {
    print(">>>>>>login");
    if (asked) {
      print("asked $asked");
      return;
    }
    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(auth0ClientID, auth0RedirectUri,
            issuer: auth0Issuer,
            scopes: ['openid', 'profile', 'offline_access'],
            promptValues: ['login']),
      );
      idToken = parseIdToken(result!.idToken!);
      profile = await getUserDetails(result.accessToken!);

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);
      isLoggedIn = true;
    } catch (e, s) {
      isLoggedIn = false;
      print('login error: $e - stack: $s');
    }
    asked = true;
  }

  static Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  static Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    final url = Uri.parse('https://$auth0Domain/userinfo');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }
}
