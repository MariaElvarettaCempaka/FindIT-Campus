/// Model data laporan barang untuk FindIT Campus.
/// Desain independen dan bersih (murni Dart/Flutter tanpa ketergantungan Firebase/Firestore).
class ReportItemModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String date;
  final String timeAgo;
  final String description;
  final String reporterName;
  final String reporterRole;
  final String reporterPhone;
  final String? imageAsset;
  final String? imageUrl;
  final bool isLost;
  String status; // 'Dalam Proses' atau 'Selesai'
  final bool isOwner;
  String? resolvedDate;
  final int viewsCount;
  final int responsesCount;
  final String activeDays;

  ReportItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.timeAgo,
    required this.description,
    required this.reporterName,
    this.reporterRole = 'Mahasiswa UNESA',
    this.reporterPhone = '081234567890',
    this.imageAsset,
    this.imageUrl,
    this.isLost = true,
    this.status = 'Dalam Proses',
    this.isOwner = false,
    this.resolvedDate,
    this.viewsCount = 14,
    this.responsesCount = 2,
    this.activeDays = '1 hari',
  });

  bool get isCompleted => status.toLowerCase() == 'selesai';

  ReportItemModel copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    String? date,
    String? timeAgo,
    String? description,
    String? reporterName,
    String? reporterRole,
    String? reporterPhone,
    String? imageAsset,
    String? imageUrl,
    bool? isLost,
    String? status,
    bool? isOwner,
    String? resolvedDate,
    int? viewsCount,
    int? responsesCount,
    String? activeDays,
  }) {
    return ReportItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      timeAgo: timeAgo ?? this.timeAgo,
      description: description ?? this.description,
      reporterName: reporterName ?? this.reporterName,
      reporterRole: reporterRole ?? this.reporterRole,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      isLost: isLost ?? this.isLost,
      status: status ?? this.status,
      isOwner: isOwner ?? this.isOwner,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      viewsCount: viewsCount ?? this.viewsCount,
      responsesCount: responsesCount ?? this.responsesCount,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  /// Factory untuk mengonversi Map (mock feed di home/search) ke ReportItemModel
  factory ReportItemModel.fromMap(Map<String, dynamic> map, {bool isOwner = false}) {
    return ReportItemModel(
      id: map['id']?.toString() ?? 'rep_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title']?.toString() ?? 'Barang Hilang',
      category: map['category']?.toString() ?? 'Lainnya',
      location: map['location']?.toString() ?? 'Kampus Ketintang UNESA',
      date: map['date']?.toString() ?? 'Hari ini',
      timeAgo: map['timeAgo']?.toString() ?? 'Baru saja',
      description: map['description']?.toString() ??
          'Barang ini dilaporkan hilang di area kampus. Mohon bantuannya bagi yang menemukan.',
      reporterName: map['reporterName']?.toString() ?? 'Pengguna FindIT',
      reporterRole: map['reporterRole']?.toString() ?? 'Mahasiswa UNESA',
      reporterPhone: map['reporterPhone']?.toString() ?? '081234567890',
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      isLost: map['isLost'] as bool? ?? (map['status']?.toString().toLowerCase().contains('found') != true),
      status: map['reportStatus']?.toString() ??
          (map['isCompleted'] == true ? 'Selesai' : 'Dalam Proses'),
      isOwner: isOwner || (map['isOwner'] == true),
      resolvedDate: map['resolvedDate']?.toString(),
      viewsCount: (map['viewsCount'] as num?)?.toInt() ?? 18,
      responsesCount: (map['responsesCount'] as num?)?.toInt() ?? 1,
      activeDays: map['activeDays']?.toString() ?? '1 hari',
    );
  }
}
