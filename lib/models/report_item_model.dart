import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data laporan barang untuk FindIT Campus.
/// Mendukung konversi dari dan ke Google Cloud Firestore sesuai ERD resmi.
class ReportItemModel {
  final String id;
  final String userId;
  final String title;
  final String? titleLower;
  final String category;
  final String location;
  final String campus;
  final String? campusLocationId;
  final String date;
  final String timeAgo;
  final String? timeSession;
  final String description;
  final String reporterName;
  final String reporterRole;
  final String reporterPhone;
  final String? reporterPhotoUrl;
  final String? imageAsset;
  final String? imageUrl;
  final List<String> images;
  final bool isLost;
  String status; // 'Dalam Proses' atau 'Selesai'
  final bool isOwner;
  String? resolvedDate;
  final int viewsCount;
  final int responsesCount;
  final String activeDays;

  // Atribut khusus barang temuan (Found items)
  final String? storageType; // 'satpam', 'student', 'official'
  final String? storageLabel;
  final String? holderName;
  final String? holderPhone;
  final String? operatingHours;
  final String? mapsUrl;
  final String? requiredProof;
  final String? claimRequirement;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportItemModel({
    required this.id,
    this.userId = '',
    required this.title,
    this.titleLower,
    required this.category,
    required this.location,
    this.campus = 'Ketintang',
    this.campusLocationId,
    required this.date,
    required this.timeAgo,
    this.timeSession,
    required this.description,
    required this.reporterName,
    this.reporterRole = 'Mahasiswa UNESA',
    this.reporterPhone = '081234567890',
    this.reporterPhotoUrl,
    this.imageAsset,
    this.imageUrl,
    this.images = const [],
    this.isLost = true,
    this.status = 'Dalam Proses',
    this.isOwner = false,
    this.resolvedDate,
    this.viewsCount = 0,
    this.responsesCount = 0,
    this.activeDays = '1 hari',
    this.storageType,
    this.storageLabel,
    this.holderName,
    this.holderPhone,
    this.operatingHours,
    this.mapsUrl,
    this.requiredProof,
    this.claimRequirement,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status.toLowerCase() == 'selesai';

  /// Helper untuk memformat selisih waktu secara dinamis
  static String formatTimeAgo(DateTime? dateTime, [String fallback = 'Baru saja']) {
    if (dateTime == null) return fallback;
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }

  ReportItemModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? titleLower,
    String? category,
    String? location,
    String? campus,
    String? campusLocationId,
    String? date,
    String? timeAgo,
    String? timeSession,
    String? description,
    String? reporterName,
    String? reporterRole,
    String? reporterPhone,
    String? reporterPhotoUrl,
    String? imageAsset,
    String? imageUrl,
    List<String>? images,
    bool? isLost,
    String? status,
    bool? isOwner,
    String? resolvedDate,
    int? viewsCount,
    int? responsesCount,
    String? activeDays,
    String? storageType,
    String? storageLabel,
    String? holderName,
    String? holderPhone,
    String? operatingHours,
    String? mapsUrl,
    String? requiredProof,
    String? claimRequirement,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      titleLower: titleLower ?? this.titleLower,
      category: category ?? this.category,
      location: location ?? this.location,
      campus: campus ?? this.campus,
      campusLocationId: campusLocationId ?? this.campusLocationId,
      date: date ?? this.date,
      timeAgo: timeAgo ?? this.timeAgo,
      timeSession: timeSession ?? this.timeSession,
      description: description ?? this.description,
      reporterName: reporterName ?? this.reporterName,
      reporterRole: reporterRole ?? this.reporterRole,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      reporterPhotoUrl: reporterPhotoUrl ?? this.reporterPhotoUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isLost: isLost ?? this.isLost,
      status: status ?? this.status,
      isOwner: isOwner ?? this.isOwner,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      viewsCount: viewsCount ?? this.viewsCount,
      responsesCount: responsesCount ?? this.responsesCount,
      activeDays: activeDays ?? this.activeDays,
      storageType: storageType ?? this.storageType,
      storageLabel: storageLabel ?? this.storageLabel,
      holderName: holderName ?? this.holderName,
      holderPhone: holderPhone ?? this.holderPhone,
      operatingHours: operatingHours ?? this.operatingHours,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      requiredProof: requiredProof ?? this.requiredProof,
      claimRequirement: claimRequirement ?? this.claimRequirement,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory untuk mengonversi DocumentSnapshot dari Cloud Firestore
  factory ReportItemModel.fromFirestore(
    DocumentSnapshot doc, {
    String? currentUserId,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    final createdAtDate = createdAtTimestamp?.toDate();
    final updatedAtTimestamp = data['updatedAt'] as Timestamp?;
    final updatedAtDate = updatedAtTimestamp?.toDate();

    final resolvedTimestamp = data['resolvedDate'] as Timestamp?;
    final resolvedDateStr = resolvedTimestamp != null
        ? '${resolvedTimestamp.toDate().day}/${resolvedTimestamp.toDate().month}/${resolvedTimestamp.toDate().year}'
        : data['resolvedDate']?.toString();

    final userId = data['userId']?.toString() ?? data['user_id']?.toString() ?? '';
    final isOwner = currentUserId != null && currentUserId.isNotEmpty && userId == currentUserId;

    return ReportItemModel(
      id: doc.id,
      userId: userId,
      title: data['title']?.toString() ?? data['Title']?.toString() ?? 'Barang Tanpa Judul',
      titleLower: data['titleLower']?.toString() ?? data['Titlelower']?.toString() ?? (data['title']?.toString().toLowerCase()),
      category: data['category']?.toString() ?? data['Category']?.toString() ?? 'Lainnya',
      location: data['location']?.toString() ?? data['Location']?.toString() ?? 'Kampus UNESA',
      campus: data['campus']?.toString() ?? data['Campus']?.toString() ?? 'Ketintang',
      campusLocationId: data['campusLocationId']?.toString() ?? data['Campuslocationid']?.toString(),
      date: data['date']?.toString() ?? data['Date']?.toString() ?? (createdAtDate != null ? '${createdAtDate.day}/${createdAtDate.month}/${createdAtDate.year}' : 'Hari ini'),
      timeAgo: formatTimeAgo(createdAtDate, data['timeAgo']?.toString() ?? 'Baru saja'),
      timeSession: data['timeSession']?.toString() ?? data['Timesession']?.toString(),
      description: data['description']?.toString() ?? data['Description']?.toString() ?? '',
      reporterName: data['reporterName']?.toString() ?? data['Reportname']?.toString() ?? 'Mahasiswa UNESA',
      reporterRole: data['reporterRole']?.toString() ?? data['ReportRole']?.toString() ?? 'Mahasiswa UNESA',
      reporterPhone: data['reporterPhone']?.toString() ?? data['Reportphone']?.toString() ?? '',
      reporterPhotoUrl: data['reporterPhotoUrl']?.toString() ?? data['ReporterPhotoUrl']?.toString(),
      imageAsset: data['imageAsset']?.toString(),
      imageUrl: data['imageUrl']?.toString() ?? data['Imageurl']?.toString(),
      images: (data['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (data['image'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (data['imageUrl'] != null ? [data['imageUrl'].toString()] : []),
      isLost: data['isLost'] as bool? ?? data['islost'] as bool? ?? true,
      status: data['status']?.toString() ?? data['Status']?.toString() ?? 'Dalam Proses',
      isOwner: isOwner || (data['isOwner'] == true),
      resolvedDate: resolvedDateStr,
      viewsCount: (data['viewsCount'] as num?)?.toInt() ?? (data['Viewscount'] as num?)?.toInt() ?? 0,
      responsesCount: (data['responsesCount'] as num?)?.toInt() ?? (data['Responsescount'] as num?)?.toInt() ?? 0,
      activeDays: data['activeDays']?.toString() ?? '1 hari',
      storageType: data['storageType']?.toString() ?? data['Storagetype']?.toString() ?? 'satpam',
      storageLabel: data['storageLabel']?.toString() ?? data['Storagelabel']?.toString(),
      holderName: data['holderName']?.toString() ?? data['Holdername']?.toString(),
      holderPhone: data['holderPhone']?.toString() ?? data['Holderphone']?.toString(),
      operatingHours: data['operatingHours']?.toString() ?? data['Operatinghours']?.toString(),
      mapsUrl: data['mapsUrl']?.toString() ?? data['mapsUrl']?.toString(),
      requiredProof: data['requiredProof']?.toString() ?? data['Requiredproof']?.toString(),
      claimRequirement: data['claimRequirement']?.toString() ?? data['ClaimRequirement']?.toString(),
      isVerified: data['isVerified'] as bool? ?? data['isVerified'] as bool? ?? false,
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
    );
  }

  /// Factory untuk mengonversi Map (mock feed / form submit) ke ReportItemModel
  factory ReportItemModel.fromMap(Map<String, dynamic> map, {bool isOwner = false}) {
    return ReportItemModel(
      id: map['id']?.toString() ?? 'rep_${DateTime.now().millisecondsSinceEpoch}',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Barang Hilang',
      titleLower: map['titleLower']?.toString() ?? map['title']?.toString().toLowerCase(),
      category: map['category']?.toString() ?? 'Lainnya',
      location: map['location']?.toString() ?? 'Kampus Ketintang UNESA',
      campus: map['campus']?.toString() ?? 'Ketintang',
      campusLocationId: map['campusLocationId']?.toString(),
      date: map['date']?.toString() ?? 'Hari ini',
      timeAgo: map['timeAgo']?.toString() ?? 'Baru saja',
      timeSession: map['timeSession']?.toString(),
      description: map['description']?.toString() ??
          'Barang ini dilaporkan hilang di area kampus. Mohon bantuannya bagi yang menemukan.',
      reporterName: map['reporterName']?.toString() ?? 'Pengguna FindIT',
      reporterRole: map['reporterRole']?.toString() ?? 'Mahasiswa UNESA',
      reporterPhone: map['reporterPhone']?.toString() ?? '081234567890',
      reporterPhotoUrl: map['reporterPhotoUrl']?.toString(),
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      images: (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isLost: map['isLost'] as bool? ?? (map['status']?.toString().toLowerCase().contains('found') != true),
      status: map['reportStatus']?.toString() ?? map['status']?.toString() ??
          (map['isCompleted'] == true ? 'Selesai' : 'Dalam Proses'),
      isOwner: isOwner || (map['isOwner'] == true),
      resolvedDate: map['resolvedDate']?.toString(),
      viewsCount: (map['viewsCount'] as num?)?.toInt() ?? 0,
      responsesCount: (map['responsesCount'] as num?)?.toInt() ?? 0,
      activeDays: map['activeDays']?.toString() ?? '1 hari',
      storageType: map['storageType']?.toString() ?? 'satpam',
      storageLabel: map['storageLabel']?.toString(),
      holderName: map['holderName']?.toString(),
      holderPhone: map['holderPhone']?.toString(),
      operatingHours: map['operatingHours']?.toString(),
      mapsUrl: map['mapsUrl']?.toString(),
      requiredProof: map['requiredProof']?.toString(),
      claimRequirement: map['claimRequirement']?.toString(),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  /// Konversi objek model ke Map format Firestore untuk disimpan
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'title': title,
      'titleLower': titleLower ?? title.toLowerCase(),
      'category': category,
      'location': location,
      'campus': campus,
      'campusLocationId': campusLocationId,
      'date': date,
      'timeSession': timeSession,
      'description': description,
      'reporterName': reporterName,
      'reporterRole': reporterRole,
      'reporterPhone': reporterPhone,
      'reporterPhotoUrl': reporterPhotoUrl,
      'imageUrl': imageUrl,
      'images': images,
      'isLost': isLost,
      'status': status,
      'resolvedDate': resolvedDate,
      'viewsCount': viewsCount,
      'responsesCount': responsesCount,
      'storageType': storageType,
      'storageLabel': storageLabel,
      'holderName': holderName,
      'holderPhone': holderPhone,
      'operatingHours': operatingHours,
      'mapsUrl': mapsUrl,
      'requiredProof': requiredProof,
      'claimRequirement': claimRequirement,
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Konversi model ke Map kompatibel untuk UI FoundScreen
  Map<String, dynamic> toFoundItemMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'campus': campus,
      'timeAgo': timeAgo,
      'storageType': storageType ?? 'satpam',
      'storageLabel': storageLabel ?? (storageType == 'satpam' ? 'Pos Satpam' : 'Dipegang Penemu'),
      'holderName': holderName ?? reporterName,
      'holderPhone': holderPhone ?? reporterPhone,
      'finderName': reporterName,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,
      'images': images.isNotEmpty ? images : (imageUrl != null ? [imageUrl!] : []),
      'snippet': description,
      'description': description,
      'claimRequirement': claimRequirement ?? 'Bawa kartu identitas mahasiswa / KTP asli.',
      'requiredProof': requiredProof ?? 'Tunjukkan bukti kepemilikan barang saat serah terima.',
      'operatingHours': operatingHours ?? '24 Jam / Jam Kerja Kampus',
      'isVerified': isVerified,
      'mapsUrl': mapsUrl,
    };
  }
}
