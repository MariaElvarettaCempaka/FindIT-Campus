import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../core/campus_locations.dart';
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
  final String initialCampus;

  const PostReportScreen({
    super.key,
    this.initialType = ReportType.lost,
    this.initialCampus = 'Ketintang',
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

  // Preset Rekomendasi Pos Satpam UNESA (Ketintang & Lidah Wetan)
  final List<String> _unesaSatpamPresets = const [
    'Pos Satpam FT Ketintang',
    'Pos Satpam Rektorat Ketintang',
    'Pos Satpam Gerbang Utama',
    'Pos Satpam FEB / FISIPOL',
    'Pos Satpam Gerbang Lidah Wetan',
    'Pos Satpam FBS / FIP Lidah Wetan',
    'Pos Satpam Danau UNESA',
  ];

  // State Perkiraan Sesi / Jam Penemuan (Khusus Barang Ditemukan)
  String? _selectedTimeSession;

  // State Kampus & Smart Autocomplete Lokasi (Ketintang & Lidah Wetan)
  late String _selectedCampus;
  List<CampusLocation> _locationSuggestions = [];
  bool _showLocationSuggestions = false;

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

  // Dedicated Scroll Controller untuk fluid hardware-accelerated 60/120 FPS
  final ScrollController _scrollController = ScrollController();

  // Navigasi Bottom Bar (Index 0: Home, 1: Hilang, 2: Ditemukan, 3: Profil)
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCampus = widget.initialCampus;
    _currentNavIndex = widget.initialType == ReportType.found ? 2 : 1;

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
      final text = _locationController.text;
      if (_locationError != null && text.trim().isNotEmpty) {
        setState(() => _locationError = null);
      }

      // Smart Autocomplete & Kampus Auto-Scanner
      if (_locationFocusNode.hasFocus && text.trim().isNotEmpty) {
        final matches = searchCampusLocations(text);
        final detected = detectCampusFromText(text, fallbackCampus: _selectedCampus);
        setState(() {
          _locationSuggestions = matches;
          _showLocationSuggestions = matches.isNotEmpty;
          _selectedCampus = detected;
        });
      } else if (text.trim().isEmpty) {
        setState(() {
          _locationSuggestions = [];
          _showLocationSuggestions = false;
        });
      }
    });

    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showLocationSuggestions = false);
          }
        });
      } else if (_locationController.text.trim().isNotEmpty) {
        final matches = searchCampusLocations(_locationController.text);
        if (matches.isNotEmpty) {
          setState(() {
            _locationSuggestions = matches;
            _showLocationSuggestions = true;
          });
        }
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
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
  // INTERAKSI: APPLE-STYLE BOTTOM SHEET DATE PICKER
  // Menggantikan Dialog Material 3 kaku dengan Apple Modal Sheet elegan
  // ===========================================================================
  Future<void> _selectDate() async {
    final now = DateTime.now();
    DateTime tempSelected = now;

    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime selected = tempSelected;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F12312E),
                    offset: Offset(0, -6),
                    blurRadius: 28,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(sheetContext).padding.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Apple Pill Drag Handle
                  Center(
                    child: Container(
                      width: 42,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.sage100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Header: Title + Subtitle + Close Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.teal600.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.teal600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Tanggal Kejadian',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green950,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kapan barang hilang atau ditemukan?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.sand100.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 6),

                  // 3. Apple-styled Calendar Date Picker
                  Theme(
                    data: Theme.of(sheetContext).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.teal600,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.green950,
                      ),
                      datePickerTheme: DatePickerThemeData(
                        weekdayStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal600,
                        ),
                        dayStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green950,
                        ),
                        yearStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green950,
                        ),
                        todayForegroundColor:
                            WidgetStateProperty.all(AppColors.teal600),
                        todayBackgroundColor: WidgetStateProperty.all(
                          AppColors.teal600.withValues(alpha: 0.10),
                        ),
                        todayBorder: const BorderSide(
                          color: AppColors.teal600,
                          width: 1.5,
                        ),
                        dayBackgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.teal600;
                          }
                          return Colors.transparent;
                        }),
                        dayForegroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return AppColors.green950;
                        }),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: selected,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 2),
                      onDateChanged: (newDate) {
                        setSheetState(() {
                          selected = newDate;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Action Buttons (Apple Pill Style)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.slate700,
                            side: const BorderSide(color: AppColors.sage100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx, selected),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: Text(
                            'Pilih Tanggal Ini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
  // INTERAKSI: TIME PICKER CUSTOM JAM (KHUSUS BARANG DITEMUKAN)
  // ===========================================================================
  Future<void> _selectCustomTime() async {
    final nowTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: nowTime,
      helpText: 'PILIH JAM PENEMUAN',
      cancelText: 'Batal',
      confirmText: 'Pilih Jam',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.green950,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: AppColors.teal600.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              hourMinuteColor: AppColors.teal600.withValues(alpha: 0.10),
              hourMinuteTextColor: AppColors.teal600,
              dayPeriodColor: AppColors.teal600.withValues(alpha: 0.12),
              dayPeriodTextColor: AppColors.teal600,
              dialHandColor: AppColors.teal600,
              dialBackgroundColor: const Color(0xFFF6FAF8),
              dialTextColor: AppColors.green950,
              entryModeIconColor: AppColors.teal600,
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.slate600,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              confirmButtonStyle: FilledButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final hour = pickedTime.hour.toString().padLeft(2, '0');
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      setState(() {
        _selectedTimeSession = 'Pukul $hour.$minute WIB';
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
        'campus': _selectedCampus,
        'date': _dateController.text.trim(),
        'timeSession': _selectedTimeSession,
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Scrollable Form Area (Diisolasi dengan RepaintBoundary untuk 60/120 FPS mulus)
          RepaintBoundary(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                AppDimens.screenInset,
                topPadding + 20, // Jarak padding atas yang lega untuk Buat Laporan
                AppDimens.screenInset,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title & Back Button
                  _buildHeaderTitle(),

                  const SizedBox(height: 22),

                  // 2. Toggle Tab: Barang Hilang vs Barang Ditemukan (Asli Punya Teman)
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    reverseDuration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topCenter,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _selectedType == ReportType.found
                        ? KeyedSubtree(
                            key: const ValueKey('found_storage_section'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_storage')),
                  ),

                  const SizedBox(height: 16),

                  // 8. Form Field: Lokasi Kejadian dengan Smart Autocomplete & Kampus Tagging
                  _buildLocationSectionWithSuggestions(),

                  const SizedBox(height: 16),

                  // 9. Form Field: Hari/Tanggal (Apple Modal Bottom Sheet Date Picker)
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

                  // 9b. Khusus Barang Ditemukan: Perkiraan Sesi/Jam Penemuan (Opsional)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    reverseDuration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topCenter,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _selectedType == ReportType.found
                        ? KeyedSubtree(
                            key: const ValueKey('found_time_session'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),
                                _buildTimeSessionSection(),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_time')),
                  ),

                  const SizedBox(height: 16),

                  // 10. Form Field: Deskripsi
                  _buildInputField(
                    label: 'Deskripsi',
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    hintText:
                        'Warna, Ukuran, ciri rahasia/identitas khusus...',
                    errorText: _descriptionError,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // 11. Tombol Publish
                  _buildPublishButton(),

                  // Jarak bottom spacer proporsional agar tombol pas berada di atas floating navbar saat di-scroll mentok
                  const SizedBox(height: 104),
                ],
              ),
            ),
          ),

          // 2. Floating Glassy Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
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
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: HEADER TITLE & BACK BUTTON
  // ===========================================================================
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF12312E).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.green950,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Buat laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.green950,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Container(
            width: 124,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.teal600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET BUILDER: TOGGLE TAB (BARANG HILANG vs BARANG DITEMUKAN)
  // Dikembalikan persis seperti layout dan style asli buatan teman
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
                    _currentNavIndex = 1;
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
                    _currentNavIndex = 2;
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
  // WIDGET BUILDER: SESI / WAKTU PENEMUAN (KHUSUS BARANG DITEMUKAN)
  // ===========================================================================
  Widget _buildTimeSessionSection() {
    final sessions = [
      {'id': 'pagi', 'label': 'Pagi (07.00 - 11.00)', 'icon': Icons.wb_sunny_outlined},
      {'id': 'siang', 'label': 'Siang (11.00 - 15.00)', 'icon': Icons.wb_cloudy_outlined},
      {'id': 'sore', 'label': 'Sore (15.00 - 18.00)', 'icon': Icons.wb_twilight_rounded},
      {'id': 'malam', 'label': 'Malam (> 18.00)', 'icon': Icons.nightlight_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Perkiraan Waktu Penemuan',
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
                color: const Color(0xFFE8F5F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Opsional',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih rentang waktu saat Anda menemukan barang ini:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppColors.slate700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...sessions.map((sess) {
                final isSelected = _selectedTimeSession == sess['label'];
                final icon = sess['icon'] as IconData;
                final label = sess['label'] as String;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTimeSession = null;
                        } else {
                          _selectedTimeSession = label;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.teal600
                            : Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal600
                              : const Color(0xFFDEE8E2),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.teal600.withValues(alpha: 0.25),
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
                            size: 15,
                            color: isSelected ? Colors.white : AppColors.teal600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.green950,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Tombol Pilih Jam Khusus
              GestureDetector(
                onTap: _selectCustomTime,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8.5),
                  decoration: BoxDecoration(
                    color: (_selectedTimeSession != null &&
                            _selectedTimeSession!.startsWith('Pukul'))
                        ? AppColors.teal600
                        : const Color(0xFFF4F8F6),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: (_selectedTimeSession != null &&
                              _selectedTimeSession!.startsWith('Pukul'))
                          ? AppColors.teal600
                          : const Color(0xFFDEE8E2),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: (_selectedTimeSession != null &&
                                _selectedTimeSession!.startsWith('Pukul'))
                            ? Colors.white
                            : AppColors.teal600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (_selectedTimeSession != null &&
                                _selectedTimeSession!.startsWith('Pukul'))
                            ? _selectedTimeSession!
                            : 'Pilih Jam...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: (_selectedTimeSession != null &&
                                  _selectedTimeSession!.startsWith('Pukul'))
                              ? Colors.white
                              : AppColors.green950,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

          // Pilihan Cepat Pos Satpam Kampus UNESA (Apple-style Quick Chips)
          if (isSatpam) ...[
            const SizedBox(height: 8),
            Text(
              'Rekomendasi Pos Satpam UNESA:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _unesaSatpamPresets.map((preset) {
                  final isSelected =
                      _storageLocationController.text.trim() == preset;

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _storageLocationController.text = preset;
                          _storageLocationError = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.teal600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.teal600
                                : const Color(0xFFDEE8E2),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.teal600
                                        .withValues(alpha: 0.22),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.shield_outlined,
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.teal600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              preset,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
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
  // WIDGET BUILDER: LOKASI DENGAN SMART AUTOCOMPLETE & TAGGING KAMPUS
  // ===========================================================================
  Widget _buildLocationSectionWithSuggestions() {
    final label = _selectedType == ReportType.lost
        ? 'Lokasi Terakhir Terlihat'
        : 'Lokasi Penemuan';
    final isKetintang = _selectedCampus == 'Ketintang';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green950,
              ),
            ),
            // Pill Kampus Terdeteksi (Bisa ditap untuk beralih manual Ketintang/Lidah)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCampus = isKetintang ? 'Lidah Wetan' : 'Ketintang';
                });
                AppToast.info(
                  context,
                  title: 'Kampus Dipilih',
                  message: 'Laporan diarahkan ke UNESA $_selectedCampus.',
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isKetintang
                      ? const Color(0xFFE8F5F2)
                      : const Color(0xFFFFF1EB),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isKetintang
                        ? AppColors.teal600.withValues(alpha: 0.35)
                        : AppColors.coral500.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 13,
                      color: isKetintang
                          ? AppColors.teal600
                          : AppColors.coral500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UNESA $_selectedCampus',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isKetintang
                            ? AppColors.teal600
                            : AppColors.coral500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 13,
                      color: isKetintang
                          ? AppColors.teal600
                          : AppColors.coral500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Ketik nama gedung/tempat, atau pilih dari rekomendasi:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppColors.slate700,
          ),
        ),
        const SizedBox(height: 8),

        // Input Field Lokasi
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _locationError != null
                  ? AppColors.coral500
                  : (_locationFocusNode.hasFocus
                      ? AppColors.teal600
                      : const Color(0xFFDEE8E2)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12312E).withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextFormField(
            controller: _locationController,
            focusNode: _locationFocusNode,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.green950,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              hintText: _selectedType == ReportType.lost
                  ? 'Contoh: Gedung E1 FT, Kantin, atau Lab Komputer'
                  : 'Contoh: Gazebo Depan Gedung E1 FT Ketintang',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate600,
              ),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.teal600,
                size: 20,
              ),
              suffixIcon: _locationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        setState(() {
                          _locationController.clear();
                          _locationSuggestions = [];
                          _showLocationSuggestions = false;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Error text jika kosong
        if (_locationError != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _locationError!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.coral500,
              ),
            ),
          ),
        ],

        // Suggestions Dropdown Card
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _showLocationSuggestions && _locationSuggestions.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.teal600.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF17695D).withValues(alpha: 0.10),
                        offset: const Offset(0, 6),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: AppColors.teal600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Rekomendasi Area Kampus UNESA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEF2F0)),
                        ..._locationSuggestions.take(4).map((loc) {
                          final isKet = loc.campus == 'Ketintang';
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _locationController.text = loc.name;
                                  _selectedCampus = loc.campus;
                                  _showLocationSuggestions = false;
                                  _locationError = null;
                                });
                                _locationFocusNode.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: isKet
                                            ? const Color(0xFFE8F5F2)
                                            : const Color(0xFFFFF1EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.place_rounded,
                                        size: 15,
                                        color: isKet
                                            ? AppColors.teal600
                                            : AppColors.coral500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.green950,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${loc.area} • UNESA ${loc.campus}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppColors.slate600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: isKet
                                            ? const Color(0xFFE8F5F2)
                                            : const Color(0xFFFFF1EB),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        loc.campus,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isKet
                                              ? AppColors.teal600
                                              : AppColors.coral500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
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
