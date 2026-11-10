import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/report_model.dart';
import '../../services/report_service.dart';

class EditReportScreen extends StatefulWidget {
  final ReportModel report;

  const EditReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _fotoController;

  final ReportService _reportService = ReportService();

  late String _jenisLaporan;
  late String _kategori;
  late DateTime _tanggalKejadian;

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

  @override
  void initState() {
    super.initState();

    final report = widget.report;

    _namaController = TextEditingController(text: report.namaBarang);
    _deskripsiController =
        TextEditingController(text: report.deskripsi);
    _lokasiController = TextEditingController(text: report.lokasi);
    _fotoController = TextEditingController(text: report.fotoBarang);

    _jenisLaporan = report.jenisLaporan;
    _kategori = _kategoriList.contains(report.kategori)
        ? report.kategori
        : 'Lainnya';
    _tanggalKejadian = report.tanggalKejadian;
  }

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

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _reportService.updateReport(
        widget.report.id,
        {
          'namaBarang': _namaController.text.trim(),
          'jenisLaporan': _jenisLaporan,
          'kategori': _kategori,
          'deskripsi': _deskripsiController.text.trim(),
          'lokasi': _lokasiController.text.trim(),
          'fotoBarang': _fotoController.text.trim(),
          'tanggalKejadian':
              Timestamp.fromDate(_tanggalKejadian),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil diperbarui!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui laporan: $e'),
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
    _fotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Informasi Barang',
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
                  onPressed:
                      _isLoading ? null : _simpanPerubahan,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
