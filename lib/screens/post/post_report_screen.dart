import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';

class PostReportScreen extends StatefulWidget {
  const PostReportScreen({super.key});

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _lokasiPenyimpananController = TextEditingController();
  final _fotoController = TextEditingController();

  final ReportService _reportService = ReportService();

  String _jenisLaporan = 'Hilang';
  String _kategori = 'Elektronik';
  DateTime _tanggalKejadian = DateTime.now();
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Elektronik',
    'Dompet',
    'Dokumen',
    'Aksesoris',
    'Pakaian',
    'Tas',
    'Kunci',
    'Lainnya',
  ];

  Future<void> _pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggalKejadian,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (tanggal != null) {
      setState(() {
        _tanggalKejadian = tanggal;
      });
    }
  }

  Future<void> _kirimLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final laporan = ReportModel(
        userId: '',
        namaBarang: _namaController.text.trim(),
        jenisLaporan: _jenisLaporan,
        kategori: _kategori,
        deskripsi: _deskripsiController.text.trim(),
        fotoBarang: _fotoController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        lokasiPenyimpanan: _jenisLaporan == 'Ditemukan'
            ? _lokasiPenyimpananController.text.trim()
            : null,
        tanggalKejadian: _tanggalKejadian,
      );

      await _reportService.addReport(laporan);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil disimpan!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan laporan: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _lokasiPenyimpananController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Barang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _jenisLaporan,
                decoration: const InputDecoration(
                  labelText: 'Jenis Laporan',
                  border: OutlineInputBorder(),
                ),
                items: ['Hilang', 'Ditemukan'].map((jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(jenis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _jenisLaporan = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori Barang',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _kategori = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Barang',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Kejadian',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi wajib diisi';
                  }
                  return null;
                },
              ),

              if (_jenisLaporan == 'Ditemukan') ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lokasiPenyimpananController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Penyimpanan (Opsional)',
                    hintText: 'Contoh: Pos satpam, ruang TU, atau sekretariat',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(
                  labelText: 'URL Foto Barang (Opsional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Kejadian'),
                subtitle: Text(
                  '${_tanggalKejadian.day}/'
                  '${_tanggalKejadian.month}/'
                  '${_tanggalKejadian.year}',
                ),
                trailing: IconButton(
                  onPressed: _pilihTanggal,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimLaporan,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Kirim Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
