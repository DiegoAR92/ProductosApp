import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyD01sawu6G7v1z0Ci_JXwgoKY8ng-uqQq0';
  final storage = new FlutterSecureStorage();

  // Si devolvemos algo es un error. Un null es todo OK
  Future<String> createUser(String email, String password) async {
    final Map<String, dynamic> authDate = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    final url =
        Uri.https(_baseUrl, '/v1/accounts:signUp', {'key': _firebaseToken});
    final resp = await http.post(url, body: json.encode(authDate));
    final Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp.containsKey('idToken')) {
      await storage.write(key: 'idToken', value: decodedResp['idToken']);
      return null;
    } else {
      return decodedResp['error']['message'];
    }
  }

  Future<String> login(String email, String password) async {
    final Map<String, dynamic> authDate = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    final url = Uri.https(
        _baseUrl, '/v1/accounts:signInWithPassword', {'key': _firebaseToken});
    final resp = await http.post(url, body: json.encode(authDate));
    final Map<String, dynamic> decodedResp = json.decode(resp.body);
    if (decodedResp.containsKey('idToken')) {
      await storage.write(key: 'idToken', value: decodedResp['idToken']);
      return null;
    } else {
      return decodedResp['error']['message'];
    }
  }

  Future logout() async {
    await storage.delete(key: 'idToken');
  }

  Future<String> readToken() async {
    return await storage.read(key: 'idToken') ?? '';
  }
}
