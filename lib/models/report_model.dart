import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String namaBarang;
  final String jenisLaporan;
  final String kategori;
  final String deskripsi;
  final String fotoBarang;
  final String lokasi;
  final String? lokasiPenyimpanan;
  final DateTime tanggalKejadian;
  final String status;
  final DateTime? tanggalSelesai;

  ReportModel({
    this.id = '',
    required this.userId,
    required this.namaBarang,
    required this.jenisLaporan,
    required this.kategori,
    required this.deskripsi,
    required this.fotoBarang,
    required this.lokasi,
    this.lokasiPenyimpanan,
    required this.tanggalKejadian,
    this.status = 'Dalam Proses',
    this.tanggalSelesai,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'namaBarang': namaBarang,
      'jenisLaporan': jenisLaporan,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'fotoBarang': fotoBarang,
      'lokasi': lokasi,
      'lokasiPenyimpanan': lokasiPenyimpanan,
      'tanggalKejadian': Timestamp.fromDate(tanggalKejadian),
      'status': status,
      'tanggalSelesai': tanggalSelesai == null
          ? null
          : Timestamp.fromDate(tanggalSelesai!),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ReportModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    final tanggal = map['tanggalKejadian'];
    final selesai = map['tanggalSelesai'];

    return ReportModel(
      id: documentId,
      userId: map['userId'] ?? '',
      namaBarang: map['namaBarang'] ?? '',
      jenisLaporan: map['jenisLaporan'] ?? '',
      kategori: map['kategori'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      fotoBarang: map['fotoBarang'] ?? '',
      lokasi: map['lokasi'] ?? '',
      lokasiPenyimpanan: map['lokasiPenyimpanan'],
      tanggalKejadian: tanggal is Timestamp
          ? tanggal.toDate()
          : DateTime.now(),
      status: map['status'] ?? 'Dalam Proses',
      tanggalSelesai: selesai is Timestamp
          ? selesai.toDate()
          : null,
    );
  }
}
