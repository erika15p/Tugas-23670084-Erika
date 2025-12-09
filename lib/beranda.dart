import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Halaman_Utama extends StatefulWidget {
  const Halaman_Utama({super.key});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();

  final List<String> _kelasList = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _prodiList = [
    'Informatika',
    'Mesin',
    'Sipil',
    'Arsitektur',
  ];

  String? _selectedKelas;
  String? _selectedProdi;
  String _jenisKelamin = 'Pria';

  List<Map<String, dynamic>> _items = [];
  static const String _prefsKey = 'data_mahasiswa_v2';
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _npmController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw != null) {
      setState(() {
        _items = raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _items.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_prefsKey, encoded);
  }

  void _addOrUpdateItem() {
    final nama = _namaController.text.trim();
    final alamat = _alamatController.text.trim();
    final npm = _npmController.text.trim();

    if (nama.isEmpty || npm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama dan NPM wajib diisi')));
      return;
    }

    if (_editingIndex == null) {
      final newItem = {
        'nama': nama,
        'alamat': alamat,
        'npm': npm,
        'kelas': _selectedKelas ?? '-',
        'prodi': _selectedProdi ?? '-',
        'jk': _jenisKelamin,
        'createdAt': DateTime.now().toIso8601String(),
      };
      setState(() {
        _items.insert(0, newItem);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan')),
      );
    } else {
      final oldKey =
          _items[_editingIndex!]['createdAt'] ??
          DateTime.now().toIso8601String();
      final updated = {
        'nama': nama,
        'alamat': alamat,
        'npm': npm,
        'kelas': _selectedKelas ?? '-',
        'prodi': _selectedProdi ?? '-',
        'jk': _jenisKelamin,
        'createdAt': oldKey,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      setState(() {
        _items[_editingIndex!] = updated;
        _editingIndex = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));
    }

    _saveData();
    _clearForm();
  }

  Future<void> _removeItem(int index) async {
    final removed = _items.removeAt(index);
    await _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${removed['nama'] ?? 'Item'} dihapus')),
    );
    setState(() {});
  }

  void _startEdit(int index) {
    final item = _items[index];
    setState(() {
      _editingIndex = index;
      _namaController.text = item['nama'] ?? '';
      _alamatController.text = item['alamat'] ?? '';
      _npmController.text = item['npm'] ?? '';
      _selectedKelas = item['kelas'];
      _selectedProdi = item['prodi'];
      _jenisKelamin = item['jk'] ?? 'Pria';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mode Edit: perbarui lalu tekan Update')),
    );
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _npmController.clear();
    setState(() {
      _selectedKelas = null;
      _selectedProdi = null;
      _jenisKelamin = 'Pria';
      _editingIndex = null;
    });
  }

  void _showDetailDialog(Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['nama'] ?? 'Detail'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Nama : ${item['nama'] ?? '-'}'),
              Text('Alamat : ${item['alamat'] ?? '-'}'),
              Text('NPM : ${item['npm'] ?? '-'}'),
              Text('Kelas : ${item['kelas'] ?? '-'}'),
              Text('Prodi : ${item['prodi'] ?? '-'}'),
              Text('Jenis Kelamin : ${item['jk'] ?? '-'}'),
              Text('Dibuat : ${item['createdAt'] ?? '-'}'),
              Text('Diperbarui : ${item['updatedAt'] ?? '-'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startEdit(index);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeItem(index);
            },
            child: const Text('Hapus'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 900;
        final double horizontalPadding = isWide ? 32 : 12;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text(
              'Dashboard Mahasiswa',
              style: TextStyle(color: Colors.white), // <-- teks putih
            ),
            centerTitle: true,
            backgroundColor: Colors.indigo,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 4, child: _buildFormCard()),
                                const SizedBox(width: 20),
                                Expanded(flex: 6, child: _buildListCard()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildFormCard(),
                                const SizedBox(height: 18),
                                _buildListCard(),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingIndex == null
                  ? 'Form Input Mahasiswa'
                  : 'Edit Data Mahasiswa',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _npmController,
              decoration: InputDecoration(
                labelText: 'NPM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdownKelas()),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownProdi()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Jenis Kelamin:'),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Pria',
                      groupValue: _jenisKelamin,
                      onChanged: (v) => setState(() => _jenisKelamin = v!),
                    ),
                    const Text('Pria'),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Perempuan',
                      groupValue: _jenisKelamin,
                      onChanged: (v) => setState(() => _jenisKelamin = v!),
                    ),
                    const Text('Perempuan'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addOrUpdateItem,
                    icon: Icon(
                      _editingIndex == null ? Icons.save : Icons.update,
                    ),
                    label: Text(
                      _editingIndex == null ? 'Simpan' : 'Update',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_editingIndex != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _clearForm,
                    child: const Text('Batal'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard() {
    final list = _items;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Daftar Mahasiswa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Menampilkan ${list.length} data'),
            ),
            const Divider(height: 1),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, idx) {
                  final item = list[idx];
                  return Dismissible(
                    key: Key(item['createdAt'] ?? idx.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red.shade50,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    onDismissed: (_) => _removeItem(idx),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade200,
                        child: Text(
                          _initials(item['nama']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(item['nama'] ?? '-'),
                      subtitle: Text(
                        '${item['npm'] ?? '-'} • ${item['prodi'] ?? '-'}',
                      ),
                      onTap: () => _showDetailDialog(item, idx),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownKelas() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Kelas',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      value: _selectedKelas,
      items: _kelasList
          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
          .toList(),
      onChanged: (v) => setState(() => _selectedKelas = v),
    );
  }

  Widget _buildDropdownProdi() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Program Studi',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      value: _selectedProdi,
      items: _prodiList
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (v) => setState(() => _selectedProdi = v),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
