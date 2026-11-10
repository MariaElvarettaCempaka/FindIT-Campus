import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report_model.dart';

class ReportService {
  final CollectionReference<Map<String, dynamic>> _reports =
      FirebaseFirestore.instance.collection('reports');

  final CollectionReference<Map<String, dynamic>> _notificationReads =
      FirebaseFirestore.instance.collection('notification_reads');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Menambahkan laporan baru.
  Future<String> addReport(ReportModel report) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final newReport = ReportModel(
      userId: user.uid,
      namaBarang: report.namaBarang,
      jenisLaporan: report.jenisLaporan,
      kategori: report.kategori,
      deskripsi: report.deskripsi,
      fotoBarang: report.fotoBarang,
      lokasi: report.lokasi,
      tanggalKejadian: report.tanggalKejadian,
      status: report.status,
      tanggalSelesai: report.tanggalSelesai,
    );

    final document = await _reports.add(newReport.toMap());

    return document.id;
  }

  // Mengambil semua laporan.
  Stream<List<ReportModel>> getReports() {
    return _reports
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Mengambil laporan milik pengguna yang sedang login.
  Stream<List<ReportModel>> getMyReports() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _reports
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Mengambil status baca notifikasi milik pengguna.
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationReads() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _notificationReads
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  // Menandai notifikasi laporan sebagai sudah dibaca.
  Future<void> markNotificationAsRead(String reportId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final readId = '${user.uid}_$reportId';

    await _notificationReads.doc(readId).set({
      'userId': user.uid,
      'reportId': reportId,
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Memastikan laporan memang milik pengguna yang login.
  Future<DocumentSnapshot<Map<String, dynamic>>> _getOwnedReport(
    String reportId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception('Laporan tidak ditemukan.');
    }

    final data = document.data();

    if (data == null || data['userId'] != user.uid) {
      throw Exception(
        'Kamu tidak memiliki izin untuk laporan ini.',
      );
    }

    return document;
  }

  // Menandai laporan sebagai selesai.
  Future<void> markReportAsCompleted(String reportId) async {
    final document = await _getOwnedReport(reportId);
    final data = document.data();

    if (data == null) {
      throw Exception('Data laporan tidak ditemukan.');
    }

    if (data['status'] == 'Selesai') {
      throw Exception('Laporan sudah berstatus selesai.');
    }

    await _reports.doc(reportId).update({
      'status': 'Selesai',
      'tanggalSelesai': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Memperbarui laporan.
  Future<void> updateReport(
    String reportId,
    Map<String, dynamic> data,
  ) async {
    await _getOwnedReport(reportId);

    final updateData = Map<String, dynamic>.from(data);

    updateData.remove('userId');
    updateData.remove('createdAt');
    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _reports.doc(reportId).update(updateData);
  }

  // Menghapus laporan.
  Future<void> deleteReport(String reportId) async {
    await _getOwnedReport(reportId);

    await _reports.doc(reportId).delete();
  }
}
