import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  // -----------------------------------------------------------
  // Fungsi Menampilkan Loading Overlay
  // -----------------------------------------------------------
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa menutup dengan klik di luar
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Mohon tunggu..."),
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // Fungsi Menutup Loading Overlay
  // -----------------------------------------------------------
  void _hideLoadingOverlay() {
    Navigator.pop(context); // Menutup dialog
  }

  // -----------------------------------------------------------
  // Proses Login
  // -----------------------------------------------------------
  Future<void> _doLogin() async {
    // 1. Tampilkan Loading Overlay
    _showLoadingOverlay();

    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // 2. Tutup Loading Overlay setelah mendapat respon
      _hideLoadingOverlay();

      if (response.status) {
        // Simpan Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token);

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/produk',
        ); // Pindah ke Dashboard
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.token)));
      }
    } catch (e) {
      // Tutup Loading Overlay jika terjadi error
      _hideLoadingOverlay();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Toko')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Tidak perlu lagi pengecekan _isLoading di sini
        // karena kita menggunakan Dialog Overlay
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _doLogin, child: const Text('Masuk')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/registrasi'),
              child: const Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
