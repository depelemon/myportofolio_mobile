import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode);

  final int statusCode;
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  static const _projectsPath = '/api/v1/projects/';
  static const _timeout = Duration(seconds: 15);

  Uri _uri(String path) => Uri.parse(baseUrl).resolve(path);

  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(_uri(_projectsPath), headers: {'Accept': 'application/json'})
        .timeout(_timeout);
    final json = _decode(response) as List<dynamic>;
    return [
      for (final item in json) Project.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _post(
      _projectsPath,
      token: token,
      body: project.toJson(),
    );
    return Project.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _post(
      '/api/v1/auth/token/',
      body: {'username': username, 'password': password},
    );
    final json = _decode(response) as Map<String, dynamic>;
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Invalid token response');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    await _post('/api/v1/auth/logout/', token: token);
  }

  Future<http.Response> _post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client
        .post(
          _uri(path),
          headers: {
            'Accept': 'application/json',
            if (body != null) 'Content-Type': 'application/json; charset=UTF-8',
            if (token != null) 'Authorization': 'Token $token',
          },
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    return response;
  }

  Object? _decode(http.Response response) {
    _ensureSuccess(response);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }
  }

  void close() => _client.close();
}
