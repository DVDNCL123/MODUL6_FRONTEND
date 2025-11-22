import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/produk.dart';

class ApiService {
  // Sesuaikan IP jika menggunakan device fisik
  static const String _baseUrl = "http://10.0.2.2:8080";

  // Helper: Menyiapkan Header dengan Token Bearer
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Placeholder untuk metode selanjutnya
  Future<ApiResponse> registrasi(
    String nama,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/registrasi');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nama': nama, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        // 201 Created
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        return ApiResponse(
          status: false,
          data: 'Gagal: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(status: false, data: 'Error: $e');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        var errorData = json.decode(response.body);
        return LoginResponse(
          status: false,
          token: errorData['data'] ?? 'Login gagal',
          userEmail: '',
          userId: 0,
        );
      }
    } catch (e) {
      return LoginResponse(
        status: false,
        token: 'Error: $e',
        userEmail: '',
        userId: 0,
      );
    }
  }

  Future<List<Produk>> getProduk() async {
    final url = Uri.parse('$_baseUrl/produk');
    final headers = await _getAuthHeaders(); // Ambil token
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['data'];
      return jsonData.map((json) => Produk.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<ApiResponse> createProduk(Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk');
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(produk.toJson()),
    );

    if (response.statusCode == 201) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      return ApiResponse(status: false, data: 'Gagal: ${response.statusCode}');
    }
  }

  Future<ApiResponse> updateProduk(String id, Produk produk) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    final headers = await _getAuthHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(produk.toJson()),
    );
    if (response.statusCode == 200)
      return ApiResponse.fromJson(json.decode(response.body));
    return ApiResponse(status: false, data: 'Gagal Update');
  }

  Future<ApiResponse> deleteProduk(String id) async {
    final url = Uri.parse('$_baseUrl/produk/$id');
    final headers = await _getAuthHeaders();
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200)
      return ApiResponse.fromJson(json.decode(response.body));
    return ApiResponse(status: false, data: 'Gagal Delete');
  }
}
