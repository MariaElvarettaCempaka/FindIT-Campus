import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_item_model.dart';

/// Service layer untuk mengelola operasi Firestore pada koleksi `reports`.
/// Modul Orang 2: Feed Publik (Beranda & Ditemukan), Pencarian, dan Statistik.
class ReportService {
  static final CollectionReference _reportsCollection =
      FirebaseFirestore.instance.collection('reports');

  /// Mendapatkan UID user yang sedang login saat ini
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Stream realtime untuk feed laporan publik.
  /// [isLost] : true untuk Beranda (Barang Hilang), false untuk Ditemukan.
  /// [campus] : Filter opsional ('Ketintang' atau 'Lidah Wetan').
  /// [category] : Filter opsional ('Dompet', 'Kunci', dll. Abaikan jika 'Semua').
  static Stream<List<ReportItemModel>> getReportsStream({
    required bool isLost,
    String? campus,
    String? category,
    bool onlyActive = true,
  }) {
    Query query = _reportsCollection.where('isLost', isEqualTo: isLost);

    if (onlyActive) {
      query = query.where('status', isEqualTo: 'Dalam Proses');
    }

    if (campus != null && campus.isNotEmpty && !campus.toLowerCase().contains('semua')) {
      query = query.where('campus', isEqualTo: campus);
    }

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'semua') {
      query = query.where('category', isEqualTo: category);
    }

    // Mengambil snapshot dan mengonversi ke List<ReportItemModel>
    return query.snapshots().map((snapshot) {
      final reports = snapshot.docs.map((doc) {
        return ReportItemModel.fromFirestore(
          doc,
          currentUserId: currentUserId,
        );
      }).toList();

      // Client-side sorting safety net: urutkan dari yang terbaru berdasarkan createdAt atau date
      reports.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.id.compareTo(a.id);
      });

      return reports;
    });
  }

  /// Stream laporan milik pengguna yang sedang login ("Laporan Kamu" di Beranda)
  static Stream<List<ReportItemModel>> getUserReports([String? targetUserId]) {
    final uid = targetUserId ?? currentUserId;
    if (uid == null || uid.isEmpty) {
      return Stream.value([]);
    }

    return _reportsCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs.map((doc) {
        return ReportItemModel.fromFirestore(
          doc,
          currentUserId: uid,
        );
      }).toList();

      reports.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.id.compareTo(a.id);
      });

      return reports;
    });
  }

  /// Pencarian laporan berdasarkan kata kunci teks (judul atau deskripsi)
  static Future<List<ReportItemModel>> searchReports(String keyword) async {
    final cleanQuery = keyword.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    try {
      // 1. Coba pencarian prefix pada field `titleLower`
      final querySnapshot = await _reportsCollection
          .where('titleLower', isGreaterThanOrEqualTo: cleanQuery)
          .where('titleLower', isLessThanOrEqualTo: '$cleanQuery\uf8ff')
          .limit(30)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) {
          return ReportItemModel.fromFirestore(
            doc,
            currentUserId: currentUserId,
          );
        }).toList();
      }
    } catch (_) {
      // Fallback ke client-side search jika index belum siap
    }

    // 2. Fallback query luas: ambil laporan terbaru lalu filter di memori
    try {
      final fallbackSnapshot = await _reportsCollection
          .limit(60)
          .get();

      return fallbackSnapshot.docs
          .map((doc) => ReportItemModel.fromFirestore(doc, currentUserId: currentUserId))
          .where((item) {
            final titleMatch = item.title.toLowerCase().contains(cleanQuery);
            final descMatch = item.description.toLowerCase().contains(cleanQuery);
            final locMatch = item.location.toLowerCase().contains(cleanQuery);
            final catMatch = item.category.toLowerCase().contains(cleanQuery);
            return titleMatch || descMatch || locMatch || catMatch;
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Menambahkan jumlah views saat laporan dibuka/ditekan
  static Future<void> incrementViewCount(String reportId) async {
    if (reportId.isEmpty) return;
    try {
      await _reportsCollection.doc(reportId).update({
        'viewsCount': FieldValue.increment(1),
      });
    } catch (_) {
      // Ignore error jika dokumen offline / permissions terbatas
    }
  }

  /// Mendapatkan detail satu laporan berdasarkan ID
  static Future<ReportItemModel?> getReportById(String reportId) async {
    try {
      final doc = await _reportsCollection.doc(reportId).get();
      if (!doc.exists) return null;
      return ReportItemModel.fromFirestore(doc, currentUserId: currentUserId);
    } catch (_) {
      return null;
    }
  }
}
