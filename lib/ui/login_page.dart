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
  bool _isLoading = false;
  final _apiService = ApiService();

  Future<void> _doLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Toko')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  ElevatedButton(
                    onPressed: _doLogin,
                    child: const Text('Masuk'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/registrasi'),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ],
              ),
      ),
    );
  }
}
