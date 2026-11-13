import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/app_toast_stack.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../found/found_screen.dart';
import '../search/search_screen.dart';

/// Enum tipe laporan: Barang Hilang atau Barang Ditemukan
enum ReportType {
  lost, // Barang Hilang
  found, // Barang Ditemukan
}

/// Halaman Buat Laporan Barang Hilang & Ditemukan (Post Screen)
/// Implementasi presisi 1:1 sesuai desain Figma & spesifikasi tim:
/// 1. Foto barang (Kamera / Galeri dengan live preview)
/// 2. Judul / Nama barang
/// 3. Pilihan Kategori chip (Dompet, HP, Kunci, KTM, Lainnya)
/// 4. Nomor Telepon / WhatsApp (untuk koordinasi klaim & verifikasi)
/// 5. Status Penitipan Barang (Khusus Barang Ditemukan):
///    - Di Pos Satpam
///    - Dipegang Sendiri
///    - Di Loket / Tempat Tertentu
/// 6. Nama Pos / Tempat Penitipan & Link Google Maps (Opsional)
/// 7. Lokasi Kejadian & Hari/Tanggal (Indonesian DatePicker)
/// 8. Deskripsi detail barang
/// 9. Validasi error form reaktif (exact "required !!!" style)
class PostReportScreen extends StatefulWidget {
  final ReportType initialType;

  const PostReportScreen({
    super.key,
    this.initialType = ReportType.lost,
  });

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  late ReportType _selectedType;

  // Controllers untuk input teks utama
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Controllers untuk detail penitipan (khusus laporan ditemukan di pos/loket)
  final TextEditingController _storageLocationController =
      TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _mapsUrlController = TextEditingController();

  // Focus nodes untuk interaksi
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _storageLocationFocusNode = FocusNode();
  final FocusNode _holderNameFocusNode = FocusNode();
  final FocusNode _mapsUrlFocusNode = FocusNode();

  // State Kategori
  final List<String> _categories = [
    'Dompet',
    'HP',
    'Kunci',
    'KTM',
    'Lainnya',
  ];
  int _selectedCategoryIndex = 0;

  // State Status Penitipan Barang (Khusus Laporan Ditemukan)
  // Opsi: 'satpam' (Di Pos Satpam), 'student' (Dipegang Sendiri), 'official' (Di Loket / Posko)
  String _selectedStorageType = 'satpam';

  // State Gambar
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // State Validasi Error
  String? _nameError;
  String? _phoneError;
  String? _locationError;
  String? _dateError;
  String? _descriptionError;
  String? _storageLocationError;

  // State Tombol Publish
  bool _isPublishing = false;
  double _publishButtonScale = 1.0;

  // Navigasi Bottom Bar (Index 0: Home, 1: Hilang, 2: Ditemukan, 3: Profil)
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    // Listener untuk menghapus error seketika pengguna mengetik
    _nameController.addListener(() {
      if (_nameError != null && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameError = null);
      }
    });

    _phoneController.addListener(() {
      if (_phoneError != null && _phoneController.text.trim().isNotEmpty) {
        setState(() => _phoneError = null);
      }
    });

    _locationController.addListener(() {
      if (_locationError != null && _locationController.text.trim().isNotEmpty) {
        setState(() => _locationError = null);
      }
    });

    _dateController.addListener(() {
      if (_dateError != null && _dateController.text.trim().isNotEmpty) {
        setState(() => _dateError = null);
      }
    });

    _descriptionController.addListener(() {
      if (_descriptionError != null &&
          _descriptionController.text.trim().isNotEmpty) {
        setState(() => _descriptionError = null);
      }
    });

    _storageLocationController.addListener(() {
      if (_storageLocationError != null &&
          _storageLocationController.text.trim().isNotEmpty) {
        setState(() => _storageLocationError = null);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _storageLocationController.dispose();
    _holderNameController.dispose();
    _mapsUrlController.dispose();

    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _locationFocusNode.dispose();
    _dateFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _storageLocationFocusNode.dispose();
    _holderNameFocusNode.dispose();
    _mapsUrlFocusNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // INTERAKSI: PICK IMAGE (KAMERA / GALERI)
  // ===========================================================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
        if (mounted) {
          AppToast.info(
            context,
            title: 'Foto Terpilih',
            message: 'Foto barang berhasil ditambahkan.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          title: 'Gagal Memilih Foto',
          message: 'Terjadi kendala saat mengakses file foto.',
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unggah Foto Barang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih sumber pengambilan foto barang:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mint300.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.teal600,
                    ),
                  ),
                  title: Text(
                    'Ambil Foto dari Kamera',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.peach100.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.coral500,
                    ),
                  ),
                  title: Text(
                    'Pilih dari Galeri Foto',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      'Hapus Foto Terpilih',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // INTERAKSI: DATE PICKER FORMAT BAHASA INDONESIA
  // ===========================================================================
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal600,
              onPrimary: Colors.white,
              onSurface: AppColors.green950,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final formattedDate =
          '${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}';
      setState(() {
        _dateController.text = formattedDate;
        _dateError = null;
      });
    }
  }

  // ===========================================================================
  // VALIDASI & PUBLISH
  // ===========================================================================
  void _validateAndPublish() {
    setState(() {
      // Validasi exact string error sesuai screenshot Figma node:
      _nameError = _nameController.text.trim().isEmpty
          ? 'Item name required !!!'
          : null;
      _phoneError = _phoneController.text.trim().isEmpty
          ? 'Phone number required !!!'
          : null;
      _locationError = _locationController.text.trim().isEmpty
          ? 'Location required !!!'
          : null;
      _dateError = _dateController.text.trim().isEmpty
          ? 'Date required !!!'
          : null;
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Description required !!!'
          : null;

      // Validasi tempat penitipan jika memilih pos satpam / loket pada laporan ditemukan
      if (_selectedType == ReportType.found &&
          _selectedStorageType != 'student') {
        _storageLocationError = _storageLocationController.text.trim().isEmpty
            ? 'Storage location required !!!'
            : null;
      } else {
        _storageLocationError = null;
      }
      // CATATAN: _mapsUrlController adalah OPSIONAL (sesuai request: "bisa diisi atau tidak gitu iq")
    });

    final hasErrors = _nameError != null ||
        _phoneError != null ||
        _locationError != null ||
        _dateError != null ||
        _descriptionError != null ||
        _storageLocationError != null;

    if (hasErrors) {
      AppToast.error(
        context,
        title: 'Validasi Gagal',
        message: 'Mohon lengkapi semua kolom yang wajib diisi.',
      );
      return;
    }

    // Eksekusi publish
    setState(() => _isPublishing = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isPublishing = false);

      // Label penyimpanan ramah pembaca
      String storageLabel;
      if (_selectedType == ReportType.lost) {
        storageLabel = 'Dipegang Pemilik';
      } else if (_selectedStorageType == 'student') {
        storageLabel = 'Dipegang Penemu';
      } else if (_storageLocationController.text.trim().isNotEmpty) {
        storageLabel = _storageLocationController.text.trim();
      } else {
        storageLabel = _selectedStorageType == 'satpam'
            ? 'Pos Satpam Kampus'
            : 'Loket / Posko';
      }

      final reportData = {
        'title': _nameController.text.trim(),
        'category': _categories[_selectedCategoryIndex],
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'date': _dateController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'storageType': _selectedType == ReportType.found
            ? _selectedStorageType
            : 'student',
        'storageLabel': storageLabel,
        'holderName': _holderNameController.text.trim(),
        'mapsUrl': _mapsUrlController.text.trim(), // Link Maps Opsional
        'image': _selectedImage?.path,
        'createdAt': DateTime.now(),
      };

      AppToast.success(
        context,
        title: 'Laporan Diterbitkan!',
        message:
            'Laporan "${_nameController.text.trim()}" berhasil dipublikasikan ke civitas kampus.',
      );

      // Kembali ke layar sebelumnya dengan membawa data laporan baru
      Navigator.pop(context, reportData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Scrollable Form Area
          SafeArea(
            bottom: false,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenInset,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 1. Title & Teal Underline Bar
                    _buildHeaderTitle(),

                    const SizedBox(height: 22),

                    // 2. Toggle Tab: Barang Hilang vs Barang Ditemukan
                    _buildReportTypeToggle(),

                    const SizedBox(height: 20),

                    // 3. Upload Foto Box (Dotted / Dashed Border)
                    _buildUploadPhotoBox(),

                    const SizedBox(height: 20),

                    // 4. Form Field: Nama / Judul barang
                    _buildInputField(
                      label: 'Nama barang',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      hintText: _selectedType == ReportType.lost
                          ? 'Dompet kulit hitam'
                          : 'Kunci Motor Honda Vario Hitam',
                      errorText: _nameError,
                    ),

                    const SizedBox(height: 16),

                    // 5. Form Field: Kategori Chips
                    _buildCategoryChips(),

                    const SizedBox(height: 16),

                    // 6. Form Field: Nomor Telepon / WhatsApp
                    _buildInputField(
                      label: 'Nomor Telepon / WhatsApp',
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      hintText: 'Contoh: 081234567890',
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.slate600,
                        size: 20,
                      ),
                      helperText:
                          'Digunakan civitas akademika untuk menghubungi Anda via WhatsApp.',
                    ),

                    // 7. Form Khusus "Barang Ditemukan": Status Penitipan Barang
                    if (_selectedType == ReportType.found) ...[
                      const SizedBox(height: 18),
                      _buildStorageTypeSection(),
                      const SizedBox(height: 14),

                      // Jika dititipkan di Pos Satpam atau Loket/Posko
                      if (_selectedStorageType != 'student') ...[
                        _buildStorageLocationDetails(),
                      ] else ...[
                        // Jika dipegang sendiri oleh penemu
                        _buildSelfKeptNotice(),
                      ],
                    ],

                    const SizedBox(height: 16),

                    // 8. Form Field: Lokasi Kejadian (Tempat Hilang / Ditemukan)
                    _buildInputField(
                      label: _selectedType == ReportType.lost
                          ? 'Lokasi Terakhir Terlihat'
                          : 'Lokasi Penemuan',
                      controller: _locationController,
                      focusNode: _locationFocusNode,
                      hintText: _selectedType == ReportType.lost
                          ? 'Gedung Perkuliahan, Lt. 2'
                          : 'Gazebo Depan Gedung E1 FT Ketintang',
                      errorText: _locationError,
                    ),

                    const SizedBox(height: 16),

                    // 9. Form Field: Hari/Tanggal
                    _buildInputField(
                      label: 'Hari/Tanggal',
                      controller: _dateController,
                      focusNode: _dateFocusNode,
                      hintText: _selectedType == ReportType.lost
                          ? '26 Oktober 2026'
                          : '20 Oktober 2026',
                      errorText: _dateError,
                      readOnly: true,
                      onTap: _selectDate,
                      suffixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.slate600,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 10. Form Field: Deskripsi
                    _buildInputField(
                      label: 'Deskripsi',
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      hintText: 'Warna, Ukuran, ciri rahasia/identitas khusus...',
                      errorText: _descriptionError,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 26),

                    // 11. Tombol Publish
                    _buildPublishButton(),

                    // Jarak bottom spacer agar tidak tertutup floating navbar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          // Floating Glassy Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentNavIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    SmoothPageRoute(child: const SearchScreen()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    SmoothPageRoute(child: const FoundScreen()),
                  );
                } else {
                  setState(() => _currentNavIndex = index);
                }
              },
              onPostTap: () {
                // Sudah berada di layar Buat Laporan
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: HEADER TITLE & TEAL UNDERLINE
  // ===========================================================================
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.green950,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 124,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.teal600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: TOGGLE TAB (BARANG HILANG vs BARANG DITEMUKAN)
  // ===========================================================================
  Widget _buildReportTypeToggle() {
    final isLostActive = _selectedType == ReportType.lost;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Tab 1: Barang Hilang
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedType != ReportType.lost) {
                  setState(() {
                    _selectedType = ReportType.lost;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLostActive ? AppColors.coral500 : const Color(0xFFEBE6DC),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLostActive
                      ? [
                          BoxShadow(
                            color: AppColors.coral500.withValues(alpha: 0.35),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Barang Hilang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: isLostActive ? FontWeight.w700 : FontWeight.w600,
                    color: isLostActive ? Colors.white : AppColors.green950,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tab 2: Barang Ditemukan
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedType != ReportType.found) {
                  setState(() {
                    _selectedType = ReportType.found;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isLostActive ? AppColors.coral500 : const Color(0xFFEBE6DC),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !isLostActive
                      ? [
                          BoxShadow(
                            color: AppColors.coral500.withValues(alpha: 0.35),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Barang Ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: !isLostActive ? FontWeight.w700 : FontWeight.w600,
                    color: !isLostActive ? Colors.white : AppColors.green950,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: UPLOAD FOTO BOX DENGAN DASHED BORDER
  // ===========================================================================
  Widget _buildUploadPhotoBox() {
    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.sage400,
          strokeWidth: 1.6,
          dashPattern: const [6, 4],
          radius: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 106,
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _selectedImage != null
              ? _buildImagePreview()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColors.teal600,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unggah foto barang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green950,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? Image.network(
                  _selectedImage!.path,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
          Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.mint300,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Foto Terunggah (Ketuk ubah)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: STATUS PENITIPAN BARANG (SATPAМ / SENDIRI / LOKET)
  // ===========================================================================
  Widget _buildStorageTypeSection() {
    final storageOptions = [
      {
        'id': 'satpam',
        'label': 'Di Pos Satpam',
        'icon': Icons.shield_outlined,
      },
      {
        'id': 'student',
        'label': 'Dipegang Penemu',
        'icon': Icons.backpack_outlined,
      },
      {
        'id': 'official',
        'label': 'Di Loket / Posko',
        'icon': Icons.account_balance_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Status Penitipan Barang',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green950,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mint200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Temuan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Pilih di mana barang temuan ini saat ini diamankan:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.slate700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: storageOptions.map((opt) {
              final isSelected = _selectedStorageType == opt['id'];
              final icon = opt['icon'] as IconData;
              final label = opt['label'] as String;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStorageType = opt['id'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.actionPrimary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radius99),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.actionPrimary
                            : AppColors.borderDefault,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.actionPrimary
                                    .withValues(alpha: 0.25),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.slate700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.green950,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: DETAIL TEMPAT PENITIPAN & LINK GOOGLE MAPS OPSIONAL
  // ===========================================================================
  Widget _buildStorageLocationDetails() {
    final isSatpam = _selectedStorageType == 'satpam';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sage100,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSatpam ? Icons.shield_outlined : Icons.account_balance_outlined,
                size: 18,
                color: AppColors.teal600,
              ),
              const SizedBox(width: 8),
              Text(
                isSatpam ? 'Detail Pos Satpam' : 'Detail Loket / Posko',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama Pos / Tempat
          _buildInputField(
            label: isSatpam
                ? 'Nama Pos Satpam'
                : 'Nama Tempat / Loket Penitipan',
            controller: _storageLocationController,
            focusNode: _storageLocationFocusNode,
            hintText: isSatpam
                ? 'Misal: Pos Satpam FT Ketintang (Depan Gerbang)'
                : 'Misal: Meja Layanan Perpustakaan Lt. 1',
            errorText: _storageLocationError,
          ),

          const SizedBox(height: 12),

          // Nama Petugas / Penjaga (Opsional)
          _buildInputField(
            label: 'Nama Petugas / Penjaga (Opsional)',
            controller: _holderNameController,
            focusNode: _holderNameFocusNode,
            hintText: isSatpam
                ? 'Misal: Pak Joko (Satpam Jaga FT)'
                : 'Misal: Ibu Ratna (Staf Layanan)',
          ),

          const SizedBox(height: 12),

          // Link Google Maps Lokasi (OPSIONAL)
          _buildInputField(
            label: 'Link Google Maps Lokasi (Opsional)',
            controller: _mapsUrlController,
            focusNode: _mapsUrlFocusNode,
            hintText: 'https://maps.app.goo.gl/... (Opsional)',
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.teal600,
              size: 20,
            ),
            helperText:
                'Status opsional: Bisa diisi untuk tombol petunjuk rute menuju lokasi barang.',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: NOTICE JIKA DIPEGANG SENDIRI OLEH PENEMU
  // ===========================================================================
  Widget _buildSelfKeptNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mint300.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.teal600.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.teal600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barang Disimpan Sendiri oleh Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pemilik barang yang kehilangan dapat menghubungi nomor WhatsApp Anda untuk mencocokkan ciri-ciri barang dan membuat janji serah terima.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: INPUT FIELD DENGAN PESAN VALIDASI EXACT
  // ===========================================================================
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    String? errorText,
    String? helperText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Field
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.green950,
          ),
        ),
        const SizedBox(height: 7),

        // Input Box
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError ? const Color(0xFFDC2626) : AppColors.borderDefault,
                width: hasError ? 1.6 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.green950,
              ),
              decoration: InputDecoration(
                hintText: hasError ? errorText : hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: hasError ? FontWeight.w700 : FontWeight.w400,
                  color: hasError ? const Color(0xFFDC2626) : AppColors.slate600,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 12 : 14,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ),

        // Helper Text Opsional
        if (helperText != null && !hasError) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.slate600,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: KATEGORI FILTER CHIPS
  // ===========================================================================
  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.green950,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedCategoryIndex == index;
              final categoryName = _categories[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green950 : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radius99),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.green950
                            : AppColors.borderDefault,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.green950.withValues(alpha: 0.25),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      categoryName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.green950,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: TOMBOL PUBLISH
  // ===========================================================================
  Widget _buildPublishButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _publishButtonScale = 0.96),
      onTapUp: (_) {
        setState(() => _publishButtonScale = 1.0);
        _validateAndPublish();
      },
      onTapCancel: () => setState(() => _publishButtonScale = 1.0),
      child: Transform.scale(
        scale: _publishButtonScale,
        child: Container(
          width: double.infinity,
          height: AppDimens.buttonPrimaryHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.teal600,
            borderRadius: BorderRadius.circular(AppDimens.radius18),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal600.withValues(alpha: 0.35),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: _isPublishing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Publish',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: DASHED BORDER UNTUK KOTAK UNGGAH FOTO
// =============================================================================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashPattern);

    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, List<double> pattern) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      int patternIndex = 0;

      while (distance < metric.length) {
        final length = pattern[patternIndex % pattern.length];
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
        patternIndex++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
