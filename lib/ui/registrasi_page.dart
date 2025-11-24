import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});
  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // 1. Menambahkan Controller Konfirmasi Password
  final _konfirmasiPasswordController = TextEditingController();

  bool _isLoading = false;
  final _apiService = ApiService();

  // -----------------------------------------------------------
  // Fungsi Registrasi
  // -----------------------------------------------------------
  void _doRegistrasi() async {
    setState(() {
      _isLoading = true;
    });

    // 2. Validasi Password Match
    // Cek apakah password dan konfirmasi password sama
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      setState(() {
        _isLoading = false;
      });

      // Tampilkan pesan error jika tidak sama
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak sama!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop proses, jangan lanjut kirim ke API
    }

    // Jika lolos validasi, lanjut kirim data ke API
    try {
      final response = await _apiService.registrasi(
        _namaController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.data)));

      if (response.status) {
        Navigator.pop(context); // Kembali ke Login jika sukses
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                // Tambahkan SingleChildScrollView agar tidak overflow saat keyboard muncul
                child: Column(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    // 3. Menambahkan TextField Konfirmasi Password di UI
                    TextField(
                      controller: _konfirmasiPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _doRegistrasi,
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
