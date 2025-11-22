import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Daftar Produk')),

      body: FutureBuilder<List<Produk>>(
        future: _futureProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
