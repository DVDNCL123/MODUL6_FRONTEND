import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import SharedPreferences

import '../models/produk.dart';
import '../services/api_service.dart';
import 'produk_form_page.dart'; // Import halaman form

class ProdukListPage extends StatefulWidget {
  const ProdukListPage({super.key});

  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Produk>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  void _loadProduk() {
    setState(() {
      _futureProduk = _apiService.getProduk();
    });
  }

  // -----------------------------------------------------------
  // Fungsi Logout
  // -----------------------------------------------------------
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari memori
    if (!mounted) return;
    // Kembali ke halaman login dan hapus riwayat navigasi
    Navigator.pushReplacementNamed(context, '/login');
  }

  // -----------------------------------------------------------
  // Fungsi Navigasi ke Form (Create atau Edit)
  // -----------------------------------------------------------
  Future<void> _navigateToForm({Produk? produk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdukFormPage(produk: produk)),
    );

    if (result == true) {
      _loadProduk(); // Refresh list jika ada perubahan
    }
  }

  // -----------------------------------------------------------
  // Fungsi Hapus Produk
  // -----------------------------------------------------------
  Future<void> _delete(Produk produk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus ${produk.namaProduk}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteProduk(produk.id.toString());
      _loadProduk(); // Refresh setelah hapus
    }
  }

  // -----------------------------------------------------------
  // UI Tampilan
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        // 2. Tambahkan Tombol Logout di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Konfirmasi Logout
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                _logout();
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Produk>>(
        future: _futureProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 3. Penanganan Error Token (Auto Logout 401)
            // Jika pesan error mengandung "401", berarti token expired/invalid
            if (snapshot.error.toString().contains('401')) {
              // Gunakan addPostFrameCallback untuk menghindari error saat build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logout();// Panggil fungsi logout yang sudah kita buat tadi
              });
              return const Center(
                child: Text('Sesi habis, harap login kembali...'),
              );
            }

            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data Kosong'));
          }

          final produkList = snapshot.data!;

          return ListView.builder(
            itemCount: produkList.length,
            itemBuilder: (context, index) {
              final produk = produkList[index];

              return ListTile(
                title: Text(produk.namaProduk),
                subtitle: Text('Rp ${produk.harga}'),
                onTap: () => _navigateToForm(produk: produk), // Edit
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(produk), // Delete
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Mode Tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
